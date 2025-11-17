"""
API views for User models.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import get_user_model

from .models import UserProfile, UserStreak
from .serializers import (
    UserSerializer, UserProfileSerializer,
    UserStreakSerializer, UserRegistrationSerializer
)

User = get_user_model()


class UserViewSet(viewsets.GenericViewSet):
    """
    ViewSet for user operations.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_permissions(self):
        if self.action == 'register':
            return [AllowAny()]
        return [IsAuthenticated()]

    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def register(self, request):
        """Register a new user."""
        serializer = UserRegistrationSerializer(data=request.data)

        if serializer.is_valid():
            user = serializer.save()
            return Response(
                UserSerializer(user).data,
                status=status.HTTP_201_CREATED
            )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def me(self, request):
        """Get current user profile."""
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def profile(self, request):
        """Get current user's full profile."""
        profile, _ = UserProfile.objects.get_or_create(user=request.user)
        streak, _ = UserStreak.objects.get_or_create(user=request.user)

        return Response({
            'user': UserSerializer(request.user).data,
            'profile': UserProfileSerializer(profile).data,
            'streak': UserStreakSerializer(streak).data
        })

    @action(detail=False, methods=['patch'])
    def update_profile(self, request):
        """Update user profile."""
        profile, _ = UserProfile.objects.get_or_create(user=request.user)
        serializer = UserProfileSerializer(profile, data=request.data, partial=True)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'])
    def log_activity(self, request):
        """Log user activity to update streak."""
        streak, _ = UserStreak.objects.get_or_create(user=request.user)
        streak.update_streak()

        # Award XP for daily login
        if streak.current_streak > 1:
            request.user.add_xp(10)  # 10 XP for daily streak

        return Response(UserStreakSerializer(streak).data)
