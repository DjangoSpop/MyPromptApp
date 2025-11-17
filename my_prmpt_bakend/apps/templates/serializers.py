"""
Serializers for Template models.
"""
from rest_framework import serializers
from .models import (
    Category, Tag, Template,
    TemplateFavorite, TemplateRating, TemplateUsage
)


class CategorySerializer(serializers.ModelSerializer):
    """Serializer for Category model."""

    class Meta:
        model = Category
        fields = [
            'id', 'name', 'slug', 'description', 'icon',
            'color', 'order', 'is_active', 'template_count'
        ]
        read_only_fields = ['id', 'template_count']


class TagSerializer(serializers.ModelSerializer):
    """Serializer for Tag model."""

    class Meta:
        model = Tag
        fields = [
            'id', 'name', 'slug', 'usage_count', 'is_featured'
        ]
        read_only_fields = ['id', 'usage_count']


class TemplateListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for template lists."""

    category_name = serializers.CharField(source='category.name', read_only=True)
    tag_names = serializers.SerializerMethodField()
    author_name = serializers.CharField(source='author.display_name', read_only=True)

    class Meta:
        model = Template
        fields = [
            'id', 'title', 'description', 'category_name', 'tag_names',
            'author_name', 'is_featured', 'is_premium',
            'rating_avg', 'usage_count', 'view_count',
            'created_at'
        ]

    def get_tag_names(self, obj):
        return [tag.name for tag in obj.tags.all()[:5]]


class TemplateDetailSerializer(serializers.ModelSerializer):
    """Detailed serializer for single template view."""

    category = CategorySerializer(read_only=True)
    tags = TagSerializer(many=True, read_only=True)
    author_name = serializers.CharField(source='author.display_name', read_only=True)
    is_favorited = serializers.SerializerMethodField()
    user_rating = serializers.SerializerMethodField()

    class Meta:
        model = Template
        fields = [
            'id', 'title', 'description', 'category', 'tags',
            'content', 'variables', 'example_output',
            'author_name', 'is_public', 'is_featured',
            'is_premium', 'is_verified',
            'ai_model', 'complexity_score', 'effectiveness_score',
            'view_count', 'usage_count', 'favorite_count',
            'rating_avg', 'rating_count',
            'is_favorited', 'user_rating',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'view_count', 'usage_count', 'favorite_count',
            'rating_avg', 'rating_count', 'created_at', 'updated_at'
        ]

    def get_is_favorited(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return TemplateFavorite.objects.filter(
                user=request.user,
                template=obj
            ).exists()
        return False

    def get_user_rating(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            rating = TemplateRating.objects.filter(
                user=request.user,
                template=obj
            ).first()
            return rating.rating if rating else None
        return None


class TemplateCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating templates."""

    class Meta:
        model = Template
        fields = [
            'title', 'description', 'category', 'tags',
            'content', 'variables', 'example_output',
            'is_public', 'ai_model', 'complexity_score'
        ]

    def create(self, validated_data):
        tags = validated_data.pop('tags', [])
        request = self.context.get('request')
        template = Template.objects.create(
            author=request.user if request else None,
            **validated_data
        )
        template.tags.set(tags)
        return template


class TemplateRatingSerializer(serializers.ModelSerializer):
    """Serializer for template ratings."""

    class Meta:
        model = TemplateRating
        fields = ['id', 'template', 'rating', 'review', 'created_at']
        read_only_fields = ['id', 'created_at']


class TemplateUsageSerializer(serializers.ModelSerializer):
    """Serializer for template usage tracking."""

    class Meta:
        model = TemplateUsage
        fields = ['id', 'template', 'input_data', 'success', 'created_at']
        read_only_fields = ['id', 'created_at']
