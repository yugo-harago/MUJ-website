<template>
  <div class="health-check-container">
    <div class="card shadow border-secondary">
      <div class="card-header bg-dark text-white">
        <h5 class="mb-0">
          <i class="bi bi-gear-fill me-2"></i>
          System Health Check - Admin Panel
        </h5>
      </div>
      <div class="card-body bg-light">
        
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-secondary" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
          <p class="mt-3 text-muted fw-semibold">Checking system status...</p>
        </div>

        <div v-else-if="error" class="alert alert-danger d-flex align-items-center" role="alert">
          <i class="bi bi-exclamation-triangle-fill me-2"></i>
          <div>{{ error }}</div>
        </div>

        <div v-else class="health-info">
          <div class="row mb-4 align-items-center">
            <div class="col-sm-4">
              <label class="fw-bold text-secondary mb-0">Environment:</label>
            </div>
            <div class="col-sm-8">
              <span 
                class="badge fs-6 px-3 py-2" 
                :class="environment === 'PROD' ? 'bg-success' : 'bg-primary'"
              >
                {{ environment }}
              </span>
            </div>
          </div>
          
          <div class="row align-items-center">
            <div class="col-sm-4">
              <label class="fw-bold text-secondary mb-0">Version:</label>
            </div>
            <div class="col-sm-8">
              <span class="badge bg-secondary fs-6 px-3 py-2">{{ version }}</span>
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
  max-width: 700px;
  margin: 0 auto;
}

.card {
  border-radius: 8px;
  border-width: 2px;
}

.card-header {
  border-bottom: 2px solid #6c757d;
}

.health-info {
  font-size: 1.1rem;
}

.health-info .row {
  padding: 0.5rem 0;
}
</style>
