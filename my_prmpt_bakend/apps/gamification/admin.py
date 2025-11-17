"""
Admin configuration for Gamification models.
"""
from django.contrib import admin
from .models import (
    Achievement, UserAchievement,
    Badge, UserBadge,
    Challenge, UserChallenge
)


@admin.register(Achievement)
class AchievementAdmin(admin.ModelAdmin):
    """Admin for Achievement model."""

    list_display = [
        'name', 'category', 'requirement_type',
        'requirement_count', 'xp_reward', 'times_earned'
    ]
    list_filter = ['category', 'requirement_type', 'is_hidden', 'is_premium_only']
    search_fields = ['name', 'description']
    prepopulated_fields = {'slug': ('name',)}


@admin.register(UserAchievement)
class UserAchievementAdmin(admin.ModelAdmin):
    """Admin for UserAchievement model."""

    list_display = [
        'user', 'achievement', 'progress',
        'is_completed', 'completed_at'
    ]
    list_filter = ['is_completed', 'created_at']
    search_fields = [
        'user__email', 'user__username',
        'achievement__name'
    ]
    raw_id_fields = ['user', 'achievement']


@admin.register(Badge)
class BadgeAdmin(admin.ModelAdmin):
    """Admin for Badge model."""

    list_display = ['name', 'rarity', 'is_active']
    list_filter = ['rarity', 'is_active']
    search_fields = ['name', 'description']
    prepopulated_fields = {'slug': ('name',)}


@admin.register(UserBadge)
class UserBadgeAdmin(admin.ModelAdmin):
    """Admin for UserBadge model."""

    list_display = ['user', 'badge', 'is_displayed', 'created_at']
    list_filter = ['is_displayed', 'created_at']
    search_fields = ['user__email', 'user__username', 'badge__name']
    raw_id_fields = ['user', 'badge']


@admin.register(Challenge)
class ChallengeAdmin(admin.ModelAdmin):
    """Admin for Challenge model."""

    list_display = [
        'name', 'requirement_type', 'requirement_count',
        'start_date', 'end_date', 'is_active'
    ]
    list_filter = ['is_active', 'requirement_type', 'start_date']
    search_fields = ['name', 'description']
    raw_id_fields = ['badge_reward']


@admin.register(UserChallenge)
class UserChallengeAdmin(admin.ModelAdmin):
    """Admin for UserChallenge model."""

    list_display = [
        'user', 'challenge', 'progress',
        'is_completed', 'completed_at'
    ]
    list_filter = ['is_completed', 'created_at']
    search_fields = ['user__email', 'user__username', 'challenge__name']
    raw_id_fields = ['user', 'challenge']
