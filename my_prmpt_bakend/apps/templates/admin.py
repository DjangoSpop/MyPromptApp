"""
Admin configuration for Template models.
"""
from django.contrib import admin
from django.utils.translation import gettext_lazy as _
from .models import (
    Category, Tag, Template,
    TemplateFavorite, TemplateRating, TemplateUsage
)


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    """Admin for Category model."""

    list_display = [
        'name', 'slug', 'template_count', 'order',
        'is_active', 'created_at'
    ]
    list_filter = ['is_active', 'created_at']
    search_fields = ['name', 'description']
    prepopulated_fields = {'slug': ('name',)}
    ordering = ['order', 'name']


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    """Admin for Tag model."""

    list_display = [
        'name', 'slug', 'usage_count',
        'is_featured', 'created_at'
    ]
    list_filter = ['is_featured', 'created_at']
    search_fields = ['name']
    prepopulated_fields = {'slug': ('name',)}
    ordering = ['-usage_count']


@admin.register(Template)
class TemplateAdmin(admin.ModelAdmin):
    """Admin for Template model."""

    list_display = [
        'title', 'category', 'author', 'is_public',
        'is_featured', 'is_premium', 'rating_avg',
        'usage_count', 'created_at'
    ]
    list_filter = [
        'is_public', 'is_featured', 'is_premium',
        'is_verified', 'category', 'created_at'
    ]
    search_fields = ['title', 'description', 'content']
    raw_id_fields = ['author']
    filter_horizontal = ['tags']
    readonly_fields = [
        'view_count', 'usage_count', 'favorite_count',
        'rating_avg', 'rating_count', 'created_at', 'updated_at'
    ]

    fieldsets = (
        (_('Basic Information'), {
            'fields': ('title', 'description', 'category', 'tags')
        }),
        (_('Content'), {
            'fields': ('content', 'variables', 'example_output')
        }),
        (_('Authorship & Visibility'), {
            'fields': (
                'author', 'is_public', 'is_featured',
                'is_premium', 'is_verified'
            )
        }),
        (_('AI Metadata'), {
            'fields': ('ai_model', 'complexity_score', 'effectiveness_score')
        }),
        (_('Metrics'), {
            'fields': (
                'view_count', 'usage_count', 'favorite_count',
                'rating_avg', 'rating_count'
            ),
            'classes': ('collapse',)
        }),
        (_('Timestamps'), {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )


@admin.register(TemplateFavorite)
class TemplateFavoriteAdmin(admin.ModelAdmin):
    """Admin for TemplateFavorite model."""

    list_display = ['user', 'template', 'created_at']
    list_filter = ['created_at']
    search_fields = [
        'user__email', 'user__username',
        'template__title'
    ]
    raw_id_fields = ['user', 'template']


@admin.register(TemplateRating)
class TemplateRatingAdmin(admin.ModelAdmin):
    """Admin for TemplateRating model."""

    list_display = [
        'user', 'template', 'rating', 'created_at'
    ]
    list_filter = ['rating', 'created_at']
    search_fields = [
        'user__email', 'user__username',
        'template__title', 'review'
    ]
    raw_id_fields = ['user', 'template']


@admin.register(TemplateUsage)
class TemplateUsageAdmin(admin.ModelAdmin):
    """Admin for TemplateUsage model."""

    list_display = [
        'user', 'template', 'success', 'created_at'
    ]
    list_filter = ['success', 'created_at']
    search_fields = [
        'user__email', 'user__username',
        'template__title'
    ]
    raw_id_fields = ['user', 'template']
    readonly_fields = ['input_data']
