"""
Template Seeder Service

Unified service for loading and validating templates from JSON files.
Replaces old updatetemplates.py and seed_templates_db.py commands.
"""
import json
import logging
from pathlib import Path
from typing import Dict, List, Any
from django.db import transaction
from django.utils.text import slugify
from apps.templates.models import Template, Category, Tag

logger = logging.getLogger(__name__)


class TemplateSeederService:
    """Unified service for template seeding and validation."""

    def __init__(self):
        self.stats = {
            'created': 0,
            'updated': 0,
            'skipped': 0,
            'errors': 0,
            'categories_created': 0,
            'tags_created': 0
        }

    def seed_from_directory(
        self,
        source_dir: Path,
        batch_size: int = 100,
        clear_existing: bool = False
    ) -> Dict[str, Any]:
        """
        Seed templates from JSON files in directory.

        Args:
            source_dir: Path to directory containing JSON files
            batch_size: Batch size for bulk operations
            clear_existing: Whether to clear existing templates

        Returns:
            Dictionary with seeding statistics
        """
        if clear_existing:
            self._clear_templates()

        json_files = list(source_dir.glob('*.json'))
        logger.info(f'Found {len(json_files)} JSON files in {source_dir}')

        for json_file in json_files:
            self._process_file(json_file, batch_size)

        logger.info(f'Seeding complete: {self.stats}')
        return {
            **self.stats,
            'total_files': len(json_files)
        }

    def _process_file(self, file_path: Path, batch_size: int):
        """Process a single JSON file."""
        try:
            logger.info(f'Processing {file_path.name}...')

            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Handle both list and single object
            templates = data if isinstance(data, list) else [data]

            # Process in batches
            for i in range(0, len(templates), batch_size):
                batch = templates[i:i + batch_size]
                self._process_batch(batch)

            logger.info(
                f'Processed {file_path.name}: '
                f'{len(templates)} templates'
            )

        except json.JSONDecodeError as e:
            logger.error(f'JSON decode error in {file_path}: {e}')
            self.stats['errors'] += 1
        except Exception as e:
            logger.error(f'Error processing {file_path}: {e}')
            self.stats['errors'] += 1

    @transaction.atomic
    def _process_batch(self, templates: List[Dict]):
        """Process a batch of templates."""
        for template_data in templates:
            try:
                self._create_or_update_template(template_data)
            except Exception as e:
                title = template_data.get('title', 'Unknown')
                logger.error(f'Error creating template "{title}": {e}')
                self.stats['errors'] += 1

    def _create_or_update_template(self, data: Dict):
        """Create or update a single template."""
        # Validate required fields
        required_fields = ['title', 'description', 'content', 'category']
        missing_fields = [f for f in required_fields if f not in data]

        if missing_fields:
            raise ValueError(
                f'Missing required fields: {missing_fields} in {data}'
            )

        # Get or create category
        category_name = data['category']
        category, created = Category.objects.get_or_create(
            name=category_name,
            defaults={
                'slug': slugify(category_name),
                'description': f'{category_name} templates',
                'icon': data.get('category_icon', 'folder'),
                'color': data.get('category_color', '#5865F2')
            }
        )
        if created:
            self.stats['categories_created'] += 1
            logger.debug(f'Created category: {category_name}')

        # Get or create tags
        tags = []
        for tag_name in data.get('tags', []):
            tag, created = Tag.objects.get_or_create(
                name=tag_name,
                defaults={'slug': slugify(tag_name)}
            )
            if created:
                self.stats['tags_created'] += 1
            tags.append(tag)

        # Create or update template
        template, created = Template.objects.update_or_create(
            title=data['title'],
            defaults={
                'description': data.get('description', ''),
                'content': data.get('content', ''),
                'category': category,
                'variables': data.get('variables', []),
                'example_output': data.get('example_output', ''),
                'is_public': data.get('is_public', True),
                'is_featured': data.get('is_featured', False),
                'is_premium': data.get('is_premium', False),
                'is_verified': data.get('is_verified', False),
                'ai_model': data.get('ai_model', ''),
                'complexity_score': data.get('complexity_score', 0.5),
                'effectiveness_score': data.get('effectiveness_score', 0.0),
            }
        )

        # Set tags (many-to-many relationship)
        if tags:
            template.tags.set(tags)

        if created:
            self.stats['created'] += 1
            logger.debug(f'Created template: {template.title}')
        else:
            self.stats['updated'] += 1
            logger.debug(f'Updated template: {template.title}')

    def _clear_templates(self):
        """Clear existing templates."""
        count = Template.objects.count()
        Template.objects.all().delete()
        logger.warning(f'Cleared {count} existing templates')

    def seed_from_json(self, json_data: List[Dict]) -> Dict[str, Any]:
        """
        Seed templates from JSON data directly.

        Args:
            json_data: List of template dictionaries

        Returns:
            Dictionary with seeding statistics
        """
        self._process_batch(json_data)
        return self.stats

    def validate_template_data(self, data: Dict) -> List[str]:
        """
        Validate template data structure.

        Args:
            data: Template data dictionary

        Returns:
            List of validation errors (empty if valid)
        """
        errors = []

        # Required fields
        required = ['title', 'description', 'content', 'category']
        for field in required:
            if field not in data or not data[field]:
                errors.append(f'Missing or empty required field: {field}')

        # Field types
        if 'variables' in data and not isinstance(data['variables'], list):
            errors.append('Field "variables" must be a list')

        if 'tags' in data and not isinstance(data['tags'], list):
            errors.append('Field "tags" must be a list')

        # Numeric fields
        numeric_fields = ['complexity_score', 'effectiveness_score']
        for field in numeric_fields:
            if field in data:
                try:
                    value = float(data[field])
                    if not 0 <= value <= 1:
                        errors.append(f'{field} must be between 0 and 1')
                except (ValueError, TypeError):
                    errors.append(f'{field} must be a number')

        return errors
