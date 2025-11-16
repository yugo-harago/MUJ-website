<template>
  <div class="health-check-container">
    <div class="card shadow-sm">
      <div class="card-body">
        <h5 class="card-title mb-4">System Health Check</h5>
        
        <div v-if="loading" class="text-center">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
          <p class="mt-2 text-muted">Checking system status...</p>
        </div>

        <div v-else-if="error" class="alert alert-danger" role="alert">
          <i class="bi bi-exclamation-triangle-fill me-2"></i>
          {{ error }}
        </div>

        <div v-else class="health-info">
          <div class="row mb-3">
            <div class="col-sm-4 fw-bold">Environment:</div>
            <div class="col-sm-8">
              <span 
                class="badge" 
                :class="environment === 'PROD' ? 'bg-success' : 'bg-primary'"
              >
                {{ environment }}
              </span>
            </div>
          </div>
          
          <div class="row">
            <div class="col-sm-4 fw-bold">Version:</div>
            <div class="col-sm-8">
              <span class="text-muted">{{ version }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getHealthCheck } from '../services/api';

export default {
  name: 'HealthCheck',
  data() {
    return {
      environment: '',
      version: '',
      loading: true,
      error: null
    };
  },
  mounted() {
    this.fetchHealthCheck();
  },
  methods: {
    async fetchHealthCheck() {
      try {
        this.loading = true;
        this.error = null;
        const data = await getHealthCheck();
        this.environment = data.environment;
        this.version = data.version;
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.health-check-container {
  max-width: 600px;
  margin: 0 auto;
}

.card {
  border-radius: 10px;
}

.health-info {
  font-size: 1.1rem;
}
</style>
