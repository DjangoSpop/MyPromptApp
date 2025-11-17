"""
API views for Template models.
"""
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly, IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q

from .models import (
    Category, Tag, Template,
    TemplateFavorite, TemplateRating, TemplateUsage
)
from .serializers import (
    CategorySerializer, TagSerializer,
    TemplateListSerializer, TemplateDetailSerializer,
    TemplateCreateSerializer, TemplateRatingSerializer,
    TemplateUsageSerializer
)
from apps.core.permissions import IsOwnerOrReadOnly


class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for browsing categories.

    list: Get all categories
    retrieve: Get single category details
    """
    queryset = Category.objects.filter(is_active=True)
    serializer_class = CategorySerializer
    lookup_field = 'slug'


class TagViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for browsing tags.

    list: Get all tags
    retrieve: Get single tag details
    """
    queryset = Tag.objects.all()
    serializer_class = TagSerializer
    lookup_field = 'slug'


class TemplateViewSet(viewsets.ModelViewSet):
    """
    ViewSet for template CRUD operations.

    list: Get all public templates
    retrieve: Get single template details
    create: Create new template
    update: Update existing template
    destroy: Delete template
    """
    queryset = Template.objects.filter(is_deleted=False, is_public=True)
    permission_classes = [IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'is_featured', 'is_premium', 'ai_model']
    search_fields = ['title', 'description', 'content']
    ordering_fields = ['created_at', 'usage_count', 'rating_avg', 'view_count']
    ordering = ['-created_at']

    def get_serializer_class(self):
        if self.action == 'list':
            return TemplateListSerializer
        elif self.action == 'create':
            return TemplateCreateSerializer
        return TemplateDetailSerializer

    def get_queryset(self):
        queryset = super().get_queryset()

        # Filter by tags
        tags = self.request.query_params.getlist('tags')
        if tags:
            queryset = queryset.filter(tags__slug__in=tags).distinct()

        # My templates
        if self.request.query_params.get('my_templates') == 'true':
            if self.request.user.is_authenticated:
                queryset = Template.objects.filter(
                    author=self.request.user,
                    is_deleted=False
                )

        # Favorites
        if self.request.query_params.get('favorites') == 'true':
            if self.request.user.is_authenticated:
                favorited_ids = TemplateFavorite.objects.filter(
                    user=self.request.user
                ).values_list('template_id', flat=True)
                queryset = queryset.filter(id__in=favorited_ids)

        return queryset

    def retrieve(self, request, *args, **kwargs):
        """Override to increment view count."""
        instance = self.get_object()
        instance.increment_view_count()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def favorite(self, request, pk=None):
        """Toggle favorite status for template."""
        template = self.get_object()
        favorite, created = TemplateFavorite.objects.get_or_create(
            user=request.user,
            template=template
        )

        if not created:
            favorite.delete()
            Template.objects.filter(pk=template.pk).update(
                favorite_count=models.F('favorite_count') - 1
            )
            return Response({'status': 'unfavorited'})
        else:
            Template.objects.filter(pk=template.pk).update(
                favorite_count=models.F('favorite_count') + 1
            )
            return Response({'status': 'favorited'})

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def rate(self, request, pk=None):
        """Rate a template."""
        template = self.get_object()
        serializer = TemplateRatingSerializer(data=request.data)

        if serializer.is_valid():
            rating, created = TemplateRating.objects.update_or_create(
                user=request.user,
                template=template,
                defaults={'rating': serializer.validated_data['rating'],
                         'review': serializer.validated_data.get('review', '')}
            )
            # Rating model save() will trigger template.update_rating()
            return Response(TemplateRatingSerializer(rating).data)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def use(self, request, pk=None):
        """Track template usage."""
        template = self.get_object()

        # Record usage
        TemplateUsage.objects.create(
            user=request.user,
            template=template,
            input_data=request.data.get('input_data', {}),
            success=request.data.get('success', True)
        )

        # Increment counters
        template.increment_usage_count()
        request.user.increment_templates_used()

        # Award XP
        request.user.add_xp(5)  # 5 XP for using a template

        return Response({'status': 'usage_recorded'})

    @action(detail=False, methods=['get'])
    def trending(self, request):
        """Get trending templates based on recent usage."""
        from django.utils import timezone
        from datetime import timedelta

        seven_days_ago = timezone.now() - timedelta(days=7)
        trending = self.get_queryset().filter(
            usages__created_at__gte=seven_days_ago
        ).order_by('-usage_count')[:20]

        serializer = self.get_serializer(trending, many=True)
        return Response(serializer.data)
