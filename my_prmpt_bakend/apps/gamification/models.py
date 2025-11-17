"""
Gamification models for the promptcraft application.

This module contains models for achievements, badges, challenges,
and user rewards.
"""
from django.db import models
from django.utils.translation import gettext_lazy as _
from apps.core.models import TimeStampedModel
from apps.users.models import User


class Achievement(TimeStampedModel):
    """
    Achievement definition.

    Achievements are earned by completing specific tasks or milestones.
    """
    name = models.CharField(
        _('name'),
        max_length=100,
        unique=True,
        help_text=_('Achievement name')
    )
    slug = models.SlugField(
        _('slug'),
        max_length=100,
        unique=True,
        help_text=_('URL-friendly identifier')
    )
    description = models.TextField(
        _('description'),
        help_text=_('Achievement description')
    )
    icon = models.CharField(
        _('icon'),
        max_length=50,
        help_text=_('Icon identifier')
    )
    category = models.CharField(
        _('category'),
        max_length=50,
        choices=[
            ('templates', 'Templates'),
            ('usage', 'Usage'),
            ('social', 'Social'),
            ('streak', 'Streak'),
            ('premium', 'Premium'),
        ],
        help_text=_('Achievement category')
    )

    # Requirements
    requirement_type = models.CharField(
        _('requirement type'),
        max_length=50,
        choices=[
            ('template_created', 'Templates Created'),
            ('template_used', 'Templates Used'),
            ('days_streak', 'Days Streak'),
            ('rating_given', 'Ratings Given'),
            ('level_reached', 'Level Reached'),
        ],
        help_text=_('Type of requirement')
    )
    requirement_count = models.IntegerField(
        _('requirement count'),
        default=1,
        help_text=_('Number required to unlock')
    )

    # Rewards
    xp_reward = models.IntegerField(
        _('XP reward'),
        default=0,
        help_text=_('XP points awarded')
    )
    is_hidden = models.BooleanField(
        _('hidden'),
        default=False,
        help_text=_('Whether achievement is hidden until unlocked')
    )
    is_premium_only = models.BooleanField(
        _('premium only'),
        default=False,
        help_text=_('Whether achievement is only for premium users')
    )

    # Metadata
    times_earned = models.IntegerField(
        _('times earned'),
        default=0,
        help_text=_('Number of times this achievement has been earned')
    )

    class Meta:
        db_table = 'achievements'
        verbose_name = _('achievement')
        verbose_name_plural = _('achievements')
        ordering = ['category', 'requirement_count']

    def __str__(self):
        return self.name


class UserAchievement(TimeStampedModel):
    """
    User's earned achievements.
    """
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='achievements',
        help_text=_('User who earned the achievement')
    )
    achievement = models.ForeignKey(
        Achievement,
        on_delete=models.CASCADE,
        related_name='user_achievements',
        help_text=_('Earned achievement')
    )
    progress = models.IntegerField(
        _('progress'),
        default=0,
        help_text=_('Current progress towards achievement')
    )
    is_completed = models.BooleanField(
        _('completed'),
        default=False,
        help_text=_('Whether achievement is completed')
    )
    completed_at = models.DateTimeField(
        _('completed at'),
        null=True,
        blank=True,
        help_text=_('When achievement was completed')
    )

    class Meta:
        db_table = 'user_achievements'
        verbose_name = _('user achievement')
        verbose_name_plural = _('user achievements')
        unique_together = ('user', 'achievement')
        ordering = ['-completed_at', '-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.achievement.name}"

    def check_completion(self):
        """Check if achievement is completed and award XP."""
        if not self.is_completed and self.progress >= self.achievement.requirement_count:
            from django.utils import timezone
            self.is_completed = True
            self.completed_at = timezone.now()
            self.save()

            # Award XP to user
            self.user.add_xp(self.achievement.xp_reward)

            # Update achievement stats
            Achievement.objects.filter(pk=self.achievement.pk).update(
                times_earned=models.F('times_earned') + 1
            )

            return True
        return False


class Badge(TimeStampedModel):
    """
    Badge definitions.

    Badges are visual rewards displayed on user profiles.
    """
    name = models.CharField(
        _('name'),
        max_length=100,
        unique=True,
        help_text=_('Badge name')
    )
    slug = models.SlugField(
        _('slug'),
        max_length=100,
        unique=True,
        help_text=_('URL-friendly identifier')
    )
    description = models.TextField(
        _('description'),
        help_text=_('Badge description')
    )
    image_url = models.URLField(
        _('image URL'),
        help_text=_('Badge image URL')
    )
    rarity = models.CharField(
        _('rarity'),
        max_length=20,
        choices=[
            ('common', 'Common'),
            ('rare', 'Rare'),
            ('epic', 'Epic'),
            ('legendary', 'Legendary'),
        ],
        default='common',
        help_text=_('Badge rarity')
    )
    is_active = models.BooleanField(
        _('active'),
        default=True,
        help_text=_('Whether badge is currently active')
    )

    class Meta:
        db_table = 'badges'
        verbose_name = _('badge')
        verbose_name_plural = _('badges')
        ordering = ['name']

    def __str__(self):
        return self.name


class UserBadge(TimeStampedModel):
    """User's earned badges."""

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='badges',
        help_text=_('User who earned the badge')
    )
    badge = models.ForeignKey(
        Badge,
        on_delete=models.CASCADE,
        related_name='user_badges',
        help_text=_('Earned badge')
    )
    is_displayed = models.BooleanField(
        _('displayed'),
        default=True,
        help_text=_('Whether badge is displayed on profile')
    )

    class Meta:
        db_table = 'user_badges'
        verbose_name = _('user badge')
        verbose_name_plural = _('user badges')
        unique_together = ('user', 'badge')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.badge.name}"


class Challenge(TimeStampedModel):
    """
    Time-limited challenges.

    Challenges are special tasks with deadlines that award bonus rewards.
    """
    name = models.CharField(
        _('name'),
        max_length=100,
        help_text=_('Challenge name')
    )
    description = models.TextField(
        _('description'),
        help_text=_('Challenge description')
    )
    requirement_type = models.CharField(
        _('requirement type'),
        max_length=50,
        choices=[
            ('template_created', 'Templates Created'),
            ('template_used', 'Templates Used'),
            ('days_active', 'Days Active'),
            ('rating_given', 'Ratings Given'),
        ],
        help_text=_('Type of requirement')
    )
    requirement_count = models.IntegerField(
        _('requirement count'),
        help_text=_('Number required to complete')
    )

    # Timing
    start_date = models.DateTimeField(
        _('start date'),
        help_text=_('Challenge start date')
    )
    end_date = models.DateTimeField(
        _('end date'),
        help_text=_('Challenge end date')
    )

    # Rewards
    xp_reward = models.IntegerField(
        _('XP reward'),
        default=0,
        help_text=_('XP points awarded')
    )
    badge_reward = models.ForeignKey(
        Badge,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='challenges',
        help_text=_('Badge awarded for completion')
    )

    is_active = models.BooleanField(
        _('active'),
        default=True,
        help_text=_('Whether challenge is active')
    )

    class Meta:
        db_table = 'challenges'
        verbose_name = _('challenge')
        verbose_name_plural = _('challenges')
        ordering = ['-start_date']

    def __str__(self):
        return self.name


class UserChallenge(TimeStampedModel):
    """User's challenge participation."""

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='challenges',
        help_text=_('Participating user')
    )
    challenge = models.ForeignKey(
        Challenge,
        on_delete=models.CASCADE,
        related_name='participants',
        help_text=_('Challenge')
    )
    progress = models.IntegerField(
        _('progress'),
        default=0,
        help_text=_('Current progress')
    )
    is_completed = models.BooleanField(
        _('completed'),
        default=False,
        help_text=_('Whether challenge is completed')
    )
    completed_at = models.DateTimeField(
        _('completed at'),
        null=True,
        blank=True,
        help_text=_('When challenge was completed')
    )

    class Meta:
        db_table = 'user_challenges'
        verbose_name = _('user challenge')
        verbose_name_plural = _('user challenges')
        unique_together = ('user', 'challenge')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.challenge.name}"

    def check_completion(self):
        """Check if challenge is completed and award rewards."""
        if not self.is_completed and self.progress >= self.challenge.requirement_count:
            from django.utils import timezone
            self.is_completed = True
            self.completed_at = timezone.now()
            self.save()

            # Award XP
            self.user.add_xp(self.challenge.xp_reward)

            # Award badge if specified
            if self.challenge.badge_reward:
                UserBadge.objects.get_or_create(
                    user=self.user,
                    badge=self.challenge.badge_reward
                )

            return True
        return False
