"""
URL configuration for Templates app.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CategoryViewSet, TagViewSet, TemplateViewSet

router = DefaultRouter()
router.register(r'categories', CategoryViewSet, basename='category')
router.register(r'tags', TagViewSet, basename='tag')
router.register(r'', TemplateViewSet, basename='template')

urlpatterns = [
    path('', include(router.urls)),
]
