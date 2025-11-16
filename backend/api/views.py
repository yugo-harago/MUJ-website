from django.conf import settings
from rest_framework.decorators import api_view
from rest_framework.response import Response


@api_view(['GET'])
def health_check(request):
    """
    Health-check endpoint that returns environment and version information.
    """
    return Response({
        'status': 'ok',
        'environment': settings.ENVIRONMENT,
        'version': settings.VERSION
    })
