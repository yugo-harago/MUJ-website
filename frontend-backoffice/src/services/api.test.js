import { describe, it, expect, vi, beforeEach } from 'vitest';
import axios from 'axios';
import { getHealthCheck } from './api';

vi.mock('axios');

describe('API Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('getHealthCheck returns data on successful request', async () => {
    const mockData = {
      environment: 'DEV',
      version: '0.1.0',
      status: 'ok'
    };

    axios.create.mockReturnValue({
      get: vi.fn().mockResolvedValue({ data: mockData })
    });

    const result = await getHealthCheck();
    expect(result).toEqual(mockData);
  });

  it('getHealthCheck throws error on network failure', async () => {
    axios.create.mockReturnValue({
      get: vi.fn().mockRejectedValue({ request: {} })
    });

    await expect(getHealthCheck()).rejects.toThrow('Network error');
  });

  it('getHealthCheck throws error on server error', async () => {
    axios.create.mockReturnValue({
      get: vi.fn().mockRejectedValue({ response: { status: 500 } })
    });

    await expect(getHealthCheck()).rejects.toThrow('Server error: 500');
  });
});
