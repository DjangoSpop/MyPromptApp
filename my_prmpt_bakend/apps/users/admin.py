"""
Admin configuration for User models.
"""
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _
from .models import User, UserProfile, UserStreak


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Custom admin for User model."""

    list_display = [
        'email', 'username', 'display_name', 'level', 'xp',
        'is_premium', 'templates_created', 'is_staff', 'date_joined'
    ]
    list_filter = [
        'is_staff', 'is_superuser', 'is_active',
        'is_premium', 'level', 'preferred_language'
    ]
    search_fields = ['email', 'username', 'display_name']
    ordering = ['-date_joined']

    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        (_('Personal info'), {
            'fields': ('username', 'display_name', 'avatar_url')
        }),
        (_('Gamification'), {
            'fields': ('level', 'xp', 'templates_created', 'templates_used')
        }),
        (_('Premium'), {
            'fields': ('is_premium', 'premium_until')
        }),
        (_('Preferences'), {
            'fields': ('preferred_language', 'theme')
        }),
        (_('Permissions'), {
            'fields': (
                'is_active', 'is_staff', 'is_superuser',
                'groups', 'user_permissions'
            ),
        }),
        (_('Important dates'), {
            'fields': ('last_login', 'last_login_at', 'date_joined')
        }),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': (
                'email', 'username', 'password1', 'password2',
                'is_staff', 'is_superuser'
            ),
        }),
    )


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    """Admin for UserProfile model."""

    list_display = ['user', 'occupation', 'location', 'is_public', 'created_at']
    list_filter = ['is_public', 'show_email']
    search_fields = ['user__email', 'user__username', 'bio', 'occupation']
    raw_id_fields = ['user']


@admin.register(UserStreak)
class UserStreakAdmin(admin.ModelAdmin):
    """Admin for UserStreak model."""

    list_display = [
        'user', 'current_streak', 'longest_streak',
        'last_activity_date', 'updated_at'
    ]
    list_filter = ['last_activity_date']
    search_fields = ['user__email', 'user__username']
    raw_id_fields = ['user']
