"""
Template models for the promptcraft application.

This module contains models for managing AI prompt templates,
categories, tags, and user interactions.
"""
from django.db import models
from django.contrib.postgres.fields import ArrayField
from django.contrib.postgres.indexes import GinIndex
from django.utils.translation import gettext_lazy as _
from django.utils.text import slugify
from apps.core.models import TimeStampedModel, BaseModel
from apps.users.models import User


class Category(TimeStampedModel):
    """Template category for organization."""

    name = models.CharField(
        _('name'),
        max_length=100,
        unique=True,
        help_text=_('Category name')
    )
    slug = models.SlugField(
        _('slug'),
        max_length=100,
        unique=True,
        help_text=_('URL-friendly category identifier')
    )
    description = models.TextField(
        _('description'),
        blank=True,
        help_text=_('Category description')
    )
    icon = models.CharField(
        _('icon'),
        max_length=50,
        blank=True,
        help_text=_('Icon identifier (e.g., material icon name)')
    )
    color = models.CharField(
        _('color'),
        max_length=7,
        default='#5865F2',
        help_text=_('Category color in hex format')
    )
    order = models.IntegerField(
        _('display order'),
        default=0,
        help_text=_('Order for displaying categories')
    )
    is_active = models.BooleanField(
        _('active'),
        default=True,
        help_text=_('Whether category is active')
    )

    # Metadata
    template_count = models.IntegerField(
        _('template count'),
        default=0,
        help_text=_('Number of templates in this category')
    )

    class Meta:
        db_table = 'categories'
        verbose_name = _('category')
        verbose_name_plural = _('categories')
        ordering = ['order', 'name']

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)


class Tag(TimeStampedModel):
    """Tags for template classification."""

    name = models.CharField(
        _('name'),
        max_length=50,
        unique=True,
        help_text=_('Tag name')
    )
    slug = models.SlugField(
        _('slug'),
        max_length=50,
        unique=True,
        help_text=_('URL-friendly tag identifier')
    )
    usage_count = models.IntegerField(
        _('usage count'),
        default=0,
        help_text=_('Number of templates using this tag')
    )
    is_featured = models.BooleanField(
        _('featured'),
        default=False,
        help_text=_('Whether tag is featured')
    )

    class Meta:
        db_table = 'tags'
        verbose_name = _('tag')
        verbose_name_plural = _('tags')
        ordering = ['-usage_count', 'name']

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)


class Template(BaseModel):
    """AI Prompt Template."""

    # Basic Information
    title = models.CharField(
        _('title'),
        max_length=255,
        db_index=True,
        help_text=_('Template title')
    )
    description = models.TextField(
        _('description'),
        help_text=_('Template description')
    )
    category = models.ForeignKey(
        Category,
        on_delete=models.CASCADE,
        related_name='templates',
        help_text=_('Template category')
    )
    tags = models.ManyToManyField(
        Tag,
        related_name='templates',
        blank=True,
        help_text=_('Template tags')
    )

    # Template Content
    content = models.TextField(
        _('content'),
        help_text=_('Template content with placeholders')
    )
    variables = ArrayField(
        models.CharField(max_length=100),
        default=list,
        blank=True,
        help_text=_('List of variable names used in template')
    )
    example_output = models.TextField(
        _('example output'),
        blank=True,
        help_text=_('Example of what this template produces')
    )

    # Authorship & Visibility
    author = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='created_templates',
        help_text=_('Template author')
    )
    is_public = models.BooleanField(
        _('public'),
        default=True,
        help_text=_('Whether template is publicly visible')
    )
    is_featured = models.BooleanField(
        _('featured'),
        default=False,
        help_text=_('Whether template is featured')
    )
    is_premium = models.BooleanField(
        _('premium'),
        default=False,
        help_text=_('Whether template requires premium subscription')
    )
    is_verified = models.BooleanField(
        _('verified'),
        default=False,
        help_text=_('Whether template is verified by admins')
    )

    # AI Metadata
    ai_model = models.CharField(
        _('AI model'),
        max_length=50,
        blank=True,
        help_text=_('Recommended AI model (e.g., gpt-4, claude-3)')
    )
    complexity_score = models.DecimalField(
        _('complexity score'),
        max_digits=3,
        decimal_places=2,
        default=0.0,
        help_text=_('Template complexity (0.0 to 1.0)')
    )
    effectiveness_score = models.DecimalField(
        _('effectiveness score'),
        max_digits=3,
        decimal_places=2,
        default=0.0,
        help_text=_('Template effectiveness based on ratings (0.0 to 1.0)')
    )

    # Engagement Metrics
    view_count = models.IntegerField(
        _('view count'),
        default=0,
        help_text=_('Number of times template was viewed')
    )
    usage_count = models.IntegerField(
        _('usage count'),
        default=0,
        help_text=_('Number of times template was used')
    )
    favorite_count = models.IntegerField(
        _('favorite count'),
        default=0,
        help_text=_('Number of users who favorited this template')
    )
    rating_avg = models.DecimalField(
        _('average rating'),
        max_digits=3,
        decimal_places=2,
        default=0.0,
        help_text=_('Average user rating (0.0 to 5.0)')
    )
    rating_count = models.IntegerField(
        _('rating count'),
        default=0,
        help_text=_('Number of ratings')
    )

    class Meta:
        db_table = 'templates'
        verbose_name = _('template')
        verbose_name_plural = _('templates')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['-created_at']),
            models.Index(fields=['category', '-usage_count']),
            models.Index(fields=['-rating_avg']),
            models.Index(fields=['-view_count']),
        ]

    def __str__(self):
        return self.title

    def increment_view_count(self):
        """Increment view count atomically."""
        self.__class__.objects.filter(pk=self.pk).update(
            view_count=models.F('view_count') + 1
        )

    def increment_usage_count(self):
        """Increment usage count atomically."""
        self.__class__.objects.filter(pk=self.pk).update(
            usage_count=models.F('usage_count') + 1
        )

    def update_rating(self):
        """Recalculate average rating from all ratings."""
        from django.db.models import Avg, Count
        stats = self.ratings.aggregate(
            avg=Avg('rating'),
            count=Count('id')
        )
        self.rating_avg = stats['avg'] or 0.0
        self.rating_count = stats['count'] or 0
        self.save(update_fields=['rating_avg', 'rating_count'])


class TemplateFavorite(TimeStampedModel):
    """User favorite templates."""

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='favorites',
        help_text=_('User who favorited the template')
    )
    template = models.ForeignKey(
        Template,
        on_delete=models.CASCADE,
        related_name='favorited_by',
        help_text=_('Favorited template')
    )

    class Meta:
        db_table = 'template_favorites'
        verbose_name = _('template favorite')
        verbose_name_plural = _('template favorites')
        unique_together = ('user', 'template')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.template.title}"


class TemplateRating(TimeStampedModel):
    """User ratings for templates."""

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='ratings',
        help_text=_('User who rated the template')
    )
    template = models.ForeignKey(
        Template,
        on_delete=models.CASCADE,
        related_name='ratings',
        help_text=_('Rated template')
    )
    rating = models.IntegerField(
        _('rating'),
        choices=[(i, f'{i} Stars') for i in range(1, 6)],
        help_text=_('Rating from 1 to 5 stars')
    )
    review = models.TextField(
        _('review'),
        blank=True,
        help_text=_('Optional review text')
    )

    class Meta:
        db_table = 'template_ratings'
        verbose_name = _('template rating')
        verbose_name_plural = _('template ratings')
        unique_together = ('user', 'template')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.template.title} ({self.rating}★)"

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        # Update template's average rating
        self.template.update_rating()


class TemplateUsage(TimeStampedModel):
    """Track template usage for analytics."""

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='template_usages',
        help_text=_('User who used the template')
    )
    template = models.ForeignKey(
        Template,
        on_delete=models.CASCADE,
        related_name='usages',
        help_text=_('Used template')
    )
    input_data = models.JSONField(
        _('input data'),
        default=dict,
        help_text=_('Variables provided by user')
    )
    success = models.BooleanField(
        _('success'),
        default=True,
        help_text=_('Whether usage was successful')
    )

    class Meta:
        db_table = 'template_usages'
        verbose_name = _('template usage')
        verbose_name_plural = _('template usages')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} used {self.template.title}"
