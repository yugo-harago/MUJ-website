<template>
  <div id="app">
    <nav class="navbar navbar-dark bg-secondary mb-4 shadow">
      <div class="container">
        <span class="navbar-brand mb-0 h1">
          <i class="bi bi-shield-lock-fill me-2"></i>
          MUT - Mission Unusual Tokyo
        </span>
        <span class="badge bg-dark text-white px-3 py-2">Backoffice Admin</span>
      </div>
    </nav>

    <div class="container">
      <div class="row">
        <div class="col-12">
          <div class="text-center mb-4">
            <h1 class="display-4 text-secondary">
              <i class="bi bi-gear-wide-connected me-3"></i>
              Backoffice Administration
            </h1>
            <p class="lead text-muted">Mission Unusual Tokyo Admin Panel</p>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-12">
          <HealthCheck />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import HealthCheck from './components/HealthCheck.vue';

export default {
  name: 'App',
  components: {
    HealthCheck
  }
};
</script>

<style>
#app {
  min-height: 100vh;
  background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%);
}

body {
  margin: 0;
  padding: 0;
}
</style>
