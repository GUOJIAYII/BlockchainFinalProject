<template>
  <div id="app">
    <navigation-bar></navigation-bar>
    <router-view />
  </div>
</template>

<script>
// import HelloWorld from './components/HelloWorld.vue'
// import Login from './pages/Login.vue'
import NavigationBar from './components/NavigationBar.vue'

export default {
  name: 'app',
  components: {
    // HelloWorld,
    // Login,
    NavigationBar
  }
}
</script>

<style lang="scss">
@import '@primer/css/index.scss';

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>
