import { describe, it, expect, vi, beforeEach } from 'vitest';
import { mount } from '@vue/test-utils';
import HealthCheck from './HealthCheck.vue';
import * as api from '../services/api';

vi.mock('../services/api');

describe('HealthCheck Component', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders loading state initially', () => {
    api.getHealthCheck.mockImplementation(() => new Promise(() => {}));
    const wrapper = mount(HealthCheck);
    
    expect(wrapper.find('.spinner-border').exists()).toBe(true);
    expect(wrapper.text()).toContain('Checking system status');
  });

  it('renders health check data after successful API call', async () => {
    api.getHealthCheck.mockResolvedValue({
      environment: 'DEV',
      version: '0.1.0'
    });

    const wrapper = mount(HealthCheck);
    await wrapper.vm.$nextTick();
    await new Promise(resolve => setTimeout(resolve, 0));

    expect(wrapper.text()).toContain('DEV');
    expect(wrapper.text()).toContain('0.1.0');
    expect(wrapper.find('.badge.bg-primary').exists()).toBe(true);
  });

  it('displays green badge for PROD environment', async () => {
    api.getHealthCheck.mockResolvedValue({
      environment: 'PROD',
      version: '1.0.0'
    });

    const wrapper = mount(HealthCheck);
    await wrapper.vm.$nextTick();
    await new Promise(resolve => setTimeout(resolve, 0));

    expect(wrapper.find('.badge.bg-success').exists()).toBe(true);
    expect(wrapper.text()).toContain('PROD');
  });

  it('displays error message when API call fails', async () => {
    api.getHealthCheck.mockRejectedValue(new Error('Network error: Unable to reach the server'));

    const wrapper = mount(HealthCheck);
    await wrapper.vm.$nextTick();
    await new Promise(resolve => setTimeout(resolve, 0));

    expect(wrapper.find('.alert-danger').exists()).toBe(true);
    expect(wrapper.text()).toContain('Network error');
  });
});
