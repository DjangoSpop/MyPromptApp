"""
Custom exceptions for the promptcraft application.
"""
from rest_framework import status
from rest_framework.exceptions import APIException
from rest_framework.views import exception_handler


class ServiceUnavailable(APIException):
    """Service is temporarily unavailable."""
    status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    default_detail = 'Service temporarily unavailable, please try again later.'
    default_code = 'service_unavailable'


class ResourceNotFound(APIException):
    """Requested resource was not found."""
    status_code = status.HTTP_404_NOT_FOUND
    default_detail = 'The requested resource was not found.'
    default_code = 'resource_not_found'


class ValidationError(APIException):
    """Data validation failed."""
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = 'Invalid data provided.'
    default_code = 'validation_error'


class PermissionDenied(APIException):
    """User does not have permission to perform this action."""
    status_code = status.HTTP_403_FORBIDDEN
    default_detail = 'You do not have permission to perform this action.'
    default_code = 'permission_denied'


class RateLimitExceeded(APIException):
    """API rate limit exceeded."""
    status_code = status.HTTP_429_TOO_MANY_REQUESTS
    default_detail = 'Request rate limit exceeded. Please try again later.'
    default_code = 'rate_limit_exceeded'


def custom_exception_handler(exc, context):
    """
    Custom exception handler for DRF.

    Formats all exceptions with a consistent structure.
    """
    # Call REST framework's default exception handler first
    response = exception_handler(exc, context)

    if response is not None:
        # Customize the response data
        custom_response_data = {
            'error': {
                'code': getattr(exc, 'default_code', 'error'),
                'message': str(exc),
                'details': response.data if isinstance(response.data, dict) else {'detail': response.data}
            }
        }
        response.data = custom_response_data

    return response
