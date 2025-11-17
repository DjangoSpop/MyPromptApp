"""
User models for the promptcraft application.

This module contains the custom User model and related profile models.
"""
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _
from apps.core.models import TimeStampedModel


class User(AbstractUser):
    """
    Custom User model extending Django's AbstractUser.

    Adds additional fields for gamification, premium features,
    and user preferences.
    """
    email = models.EmailField(
        _('email address'),
        unique=True,
        help_text=_('User email address (unique)')
    )
    display_name = models.CharField(
        _('display name'),
        max_length=100,
        blank=True,
        help_text=_('Public display name')
    )
    avatar_url = models.URLField(
        _('avatar URL'),
        max_length=500,
        blank=True,
        help_text=_('URL to user avatar image')
    )

    # Gamification fields
    level = models.IntegerField(
        _('level'),
        default=1,
        help_text=_('User level based on XP')
    )
    xp = models.IntegerField(
        _('experience points'),
        default=0,
        help_text=_('Total experience points earned')
    )

    # Premium & Subscription
    is_premium = models.BooleanField(
        _('premium user'),
        default=False,
        help_text=_('Whether user has premium subscription')
    )
    premium_until = models.DateTimeField(
        _('premium until'),
        null=True,
        blank=True,
        help_text=_('Premium subscription expiry date')
    )

    # Usage metrics
    templates_created = models.IntegerField(
        _('templates created'),
        default=0,
        help_text=_('Number of templates created by user')
    )
    templates_used = models.IntegerField(
        _('templates used'),
        default=0,
        help_text=_('Number of times user has used templates')
    )

    # Preferences
    preferred_language = models.CharField(
        _('preferred language'),
        max_length=10,
        default='en',
        choices=[
            ('en', 'English'),
            ('ar', 'Arabic'),
        ],
        help_text=_('User interface language preference')
    )
    theme = models.CharField(
        _('theme'),
        max_length=10,
        default='dark',
        choices=[
            ('light', 'Light'),
            ('dark', 'Dark'),
            ('auto', 'Auto'),
        ],
        help_text=_('UI theme preference')
    )

    # Timestamps
    last_login_at = models.DateTimeField(
        _('last login'),
        null=True,
        blank=True,
        help_text=_('Last login timestamp')
    )

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        verbose_name = _('user')
        verbose_name_plural = _('users')
        ordering = ['-date_joined']

    def __str__(self):
        return self.email

    @property
    def xp_progress(self):
        """Calculate XP progress to next level (0.0 to 1.0)."""
        xp_in_current_level = self.xp % 100
        return xp_in_current_level / 100.0

    @property
    def xp_to_next_level(self):
        """Calculate XP needed for next level."""
        xp_in_current_level = self.xp % 100
        return 100 - xp_in_current_level

    def add_xp(self, amount):
        """
        Add XP to user and update level if needed.

        Args:
            amount: XP points to add

        Returns:
            bool: True if user leveled up
        """
        old_level = self.level
        self.xp += amount
        self.level = (self.xp // 100) + 1
        self.save(update_fields=['xp', 'level'])
        return self.level > old_level

    def increment_templates_created(self):
        """Increment templates created counter."""
        self.templates_created = models.F('templates_created') + 1
        self.save(update_fields=['templates_created'])

    def increment_templates_used(self):
        """Increment templates used counter."""
        self.templates_used = models.F('templates_used') + 1
        self.save(update_fields=['templates_used'])


class UserProfile(TimeStampedModel):
    """
    Extended user profile with additional information.
    """
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='profile',
        help_text=_('User this profile belongs to')
    )
    bio = models.TextField(
        _('bio'),
        blank=True,
        max_length=500,
        help_text=_('User biography (max 500 characters)')
    )
    website = models.URLField(
        _('website'),
        blank=True,
        help_text=_('User website or portfolio URL')
    )
    location = models.CharField(
        _('location'),
        max_length=100,
        blank=True,
        help_text=_('User location (city, country)')
    )
    occupation = models.CharField(
        _('occupation'),
        max_length=100,
        blank=True,
        help_text=_('User occupation or job title')
    )

    # Social links
    twitter_url = models.URLField(_('Twitter URL'), blank=True)
    linkedin_url = models.URLField(_('LinkedIn URL'), blank=True)
    github_url = models.URLField(_('GitHub URL'), blank=True)

    # Privacy settings
    is_public = models.BooleanField(
        _('public profile'),
        default=True,
        help_text=_('Whether profile is publicly visible')
    )
    show_email = models.BooleanField(
        _('show email'),
        default=False,
        help_text=_('Whether email is visible on public profile')
    )

    class Meta:
        db_table = 'user_profiles'
        verbose_name = _('user profile')
        verbose_name_plural = _('user profiles')

    def __str__(self):
        return f"Profile of {self.user.email}"


class UserStreak(TimeStampedModel):
    """
    Track user daily activity streaks for gamification.
    """
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='streak',
        help_text=_('User this streak belongs to')
    )
    current_streak = models.IntegerField(
        _('current streak'),
        default=0,
        help_text=_('Current consecutive days active')
    )
    longest_streak = models.IntegerField(
        _('longest streak'),
        default=0,
        help_text=_('Longest streak ever achieved')
    )
    last_activity_date = models.DateField(
        _('last activity date'),
        null=True,
        blank=True,
        help_text=_('Date of last activity')
    )

    class Meta:
        db_table = 'user_streaks'
        verbose_name = _('user streak')
        verbose_name_plural = _('user streaks')

    def __str__(self):
        return f"{self.user.email} - {self.current_streak} days"

    def update_streak(self):
        """Update streak based on current activity."""
        from django.utils import timezone
        today = timezone.now().date()

        if self.last_activity_date is None:
            # First activity
            self.current_streak = 1
            self.longest_streak = 1
        elif self.last_activity_date == today:
            # Already logged today, no change
            return
        elif (today - self.last_activity_date).days == 1:
            # Consecutive day, increment streak
            self.current_streak += 1
            if self.current_streak > self.longest_streak:
                self.longest_streak = self.current_streak
        else:
            # Streak broken
            self.current_streak = 1

        self.last_activity_date = today
        self.save()
