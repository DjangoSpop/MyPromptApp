"""
Serializers for User models.
"""
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import UserProfile, UserStreak

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """Serializer for User model."""

    xp_progress = serializers.FloatField(read_only=True)
    xp_to_next_level = serializers.IntegerField(read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'email', 'username', 'display_name', 'avatar_url',
            'level', 'xp', 'xp_progress', 'xp_to_next_level',
            'is_premium', 'premium_until',
            'templates_created', 'templates_used',
            'preferred_language', 'theme',
            'date_joined', 'last_login_at'
        ]
        read_only_fields = [
            'id', 'level', 'xp', 'templates_created', 'templates_used',
            'date_joined', 'last_login_at'
        ]


class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for UserProfile model."""

    user = UserSerializer(read_only=True)

    class Meta:
        model = UserProfile
        fields = [
            'user', 'bio', 'website', 'location', 'occupation',
            'twitter_url', 'linkedin_url', 'github_url',
            'is_public', 'show_email'
        ]


class UserStreakSerializer(serializers.ModelSerializer):
    """Serializer for UserStreak model."""

    class Meta:
        model = UserStreak
        fields = [
            'current_streak', 'longest_streak', 'last_activity_date'
        ]
        read_only_fields = fields


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration."""

    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['email', 'username', 'password', 'password_confirm']

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Passwords do not match")
        return data

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(
            email=validated_data['email'],
            username=validated_data['username'],
            password=validated_data['password']
        )
        # Create profile and streak
        UserProfile.objects.create(user=user)
        UserStreak.objects.create(user=user)
        return user
