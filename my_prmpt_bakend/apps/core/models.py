"""
Core models for the promptcraft application.

This module contains base models and mixins that are used across
all other apps in the project.
"""
from django.db import models
from django.utils.translation import gettext_lazy as _


class TimeStampedModel(models.Model):
    """
    Abstract base model that provides timestamp fields.

    All models should inherit from this to automatically track
    creation and modification times.
    """
    created_at = models.DateTimeField(
        _('created at'),
        auto_now_add=True,
        help_text=_('Timestamp when the record was created')
    )
    updated_at = models.DateTimeField(
        _('updated at'),
        auto_now=True,
        help_text=_('Timestamp when the record was last updated')
    )

    class Meta:
        abstract = True
        ordering = ['-created_at']


class SoftDeleteModel(models.Model):
    """
    Abstract base model that provides soft delete functionality.

    Instead of permanently deleting records, they are marked as deleted.
    """
    is_deleted = models.BooleanField(
        _('is deleted'),
        default=False,
        help_text=_('Whether this record has been soft-deleted')
    )
    deleted_at = models.DateTimeField(
        _('deleted at'),
        null=True,
        blank=True,
        help_text=_('Timestamp when the record was deleted')
    )

    class Meta:
        abstract = True

    def soft_delete(self):
        """Mark this record as deleted."""
        from django.utils import timezone
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save(update_fields=['is_deleted', 'deleted_at'])

    def restore(self):
        """Restore a soft-deleted record."""
        self.is_deleted = False
        self.deleted_at = None
        self.save(update_fields=['is_deleted', 'deleted_at'])


class BaseModel(TimeStampedModel, SoftDeleteModel):
    """
    Base model that combines timestamp and soft delete functionality.

    Most models in the application should inherit from this.
    """

    class Meta:
        abstract = True
