import axios from 'axios';

const apiClient = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

export const getHealthCheck = async () => {
  try {
    const response = await apiClient.get('/health-check/');
    return response.data;
  } catch (error) {
    if (error.response) {
      throw new Error(`Server error: ${error.response.status}`);
    } else if (error.request) {
      throw new Error('Network error: Unable to reach the server');
    } else {
      throw new Error('Request error: ' + error.message);
    }
  }
};
