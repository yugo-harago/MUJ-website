from django.test import TestCase, override_settings
from django.urls import reverse
from rest_framework.test import APIClient
from django.conf import settings


class HealthCheckTestCase(TestCase):
    """Test cases for the health-check endpoint"""

    def setUp(self):
        self.client = APIClient()
        self.url = reverse('health-check')

    def test_health_check_success(self):
        """Test that health-check endpoint returns successful response"""
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, 200)
        self.assertIn('status', response.data)
        self.assertEqual(response.data['status'], 'ok')

    def test_health_check_json_format(self):
        """Test that health-check returns correct JSON format"""
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, 200)
        self.assertIn('status', response.data)
        self.assertIn('environment', response.data)
        self.assertIn('version', response.data)

    def test_environment_variable_reading(self):
        """Test that health-check reads environment variable correctly"""
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['environment'], settings.ENVIRONMENT)

    @override_settings(ENVIRONMENT='PROD')
    def test_environment_prod(self):
        """Test health-check with PROD environment"""
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['environment'], 'PROD')

    def test_version_retrieval(self):
        """Test that health-check returns correct version"""
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['version'], settings.VERSION)
        self.assertEqual(response.data['version'], '0.1.0')
