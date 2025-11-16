<template>
  <div id="app">
    <nav class="navbar navbar-dark bg-dark mb-4">
      <div class="container">
        <span class="navbar-brand mb-0 h1">
          <i class="bi bi-globe me-2"></i>
          MUT - Mission Unusual Tokyo
        </span>
        <span class="badge bg-light text-dark">Client Portal</span>
      </div>
    </nav>

    <div class="container">
      <div class="row">
        <div class="col-12">
          <div class="text-center mb-4">
            <h1 class="display-4">Welcome to MUT</h1>
            <p class="lead text-muted">Mission Unusual Tokyo Client Portal</p>
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
  background-color: #f8f9fa;
}

body {
  margin: 0;
  padding: 0;
}
</style>
