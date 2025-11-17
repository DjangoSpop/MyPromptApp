"""
Management command to seed templates from JSON files.

Unified command that replaces old updatetemplates.py and seed_templates_db.py.

Usage:
    python manage.py seed_templates
    python manage.py seed_templates --source data/templates
    python manage.py seed_templates --clear
    python manage.py seed_templates --batch-size 50
"""
import logging
from pathlib import Path
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from apps.templates.services import TemplateSeederService

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = 'Unified template seeding command - loads and validates all templates'

    def add_arguments(self, parser):
        parser.add_argument(
            '--source',
            type=str,
            default='data/templates',
            help='Source directory for template JSON files (default: data/templates)'
        )
        parser.add_argument(
            '--batch-size',
            type=int,
            default=100,
            help='Batch size for bulk operations (default: 100)'
        )
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Clear existing templates before seeding'
        )
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Validate templates without saving to database'
        )

    def handle(self, *args, **options):
        source = Path(options['source'])
        batch_size = options['batch_size']
        clear = options['clear']
        dry_run = options['dry_run']

        self.stdout.write(
            self.style.WARNING(
                f'\n🚀 Starting template seeding from: {source}\n'
            )
        )

        # Check if source directory exists
        if not source.exists():
            raise CommandError(f'Source directory not found: {source}')

        if not source.is_dir():
            raise CommandError(f'Source path is not a directory: {source}')

        # Initialize seeder
        seeder = TemplateSeederService()

        if dry_run:
            self.stdout.write(
                self.style.NOTICE('Running in DRY RUN mode - no changes will be saved\n')
            )
            self._dry_run(seeder, source)
            return

        # Run seeding
        try:
            with transaction.atomic():
                import time
                start_time = time.time()

                result = seeder.seed_from_directory(
                    source_dir=source,
                    batch_size=batch_size,
                    clear_existing=clear
                )

                duration = time.time() - start_time

                # Display results
                self.stdout.write(
                    self.style.SUCCESS(
                        f'\n✅ Seeding complete!\n'
                        f'\n📊 Statistics:'
                        f'\n   📁 Files processed: {result["total_files"]}'
                        f'\n   ✨ Templates created: {result["created"]}'
                        f'\n   🔄 Templates updated: {result["updated"]}'
                        f'\n   ⏭️  Templates skipped: {result["skipped"]}'
                        f'\n   ❌ Errors: {result["errors"]}'
                        f'\n   📂 Categories created: {result["categories_created"]}'
                        f'\n   🏷️  Tags created: {result["tags_created"]}'
                        f'\n   ⏱️  Duration: {duration:.2f}s'
                        f'\n'
                    )
                )

                if result["errors"] > 0:
                    self.stdout.write(
                        self.style.WARNING(
                            f'⚠️  Warning: {result["errors"]} errors occurred during seeding.'
                            f'\nCheck logs for details.'
                        )
                    )

        except Exception as e:
            self.stderr.write(
                self.style.ERROR(f'❌ Seeding failed: {str(e)}')
            )
            logger.exception('Template seeding failed')
            raise CommandError('Seeding failed. Check logs for details.')

    def _dry_run(self, seeder: TemplateSeederService, source_dir: Path):
        """Run validation without saving."""
        json_files = list(source_dir.glob('*.json'))
        total_templates = 0
        total_errors = 0

        for json_file in json_files:
            self.stdout.write(f'\n📄 Validating {json_file.name}...')

            try:
                import json
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)

                templates = data if isinstance(data, list) else [data]
                total_templates += len(templates)

                for i, template in enumerate(templates, 1):
                    errors = seeder.validate_template_data(template)
                    if errors:
                        total_errors += len(errors)
                        self.stdout.write(
                            self.style.ERROR(
                                f'   Template {i} ("{template.get("title", "Unknown")}"):'
                            )
                        )
                        for error in errors:
                            self.stdout.write(f'      - {error}')
                    else:
                        self.stdout.write(
                            self.style.SUCCESS(
                                f'   ✅ Template {i} valid: {template.get("title", "Unknown")}'
                            )
                        )

            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f'   Error reading file: {e}')
                )
                total_errors += 1

        self.stdout.write(
            self.style.SUCCESS(
                f'\n📊 Dry Run Summary:'
                f'\n   Templates validated: {total_templates}'
                f'\n   Validation errors: {total_errors}'
            )
        )
