import Vue from 'vue'
import App from './App.vue'
import router from './router'
import axios from 'axios'
import VueAxios from 'vue-axios'
import Antd from 'ant-design-vue'
import 'ant-design-vue/dist/antd.css'

Vue.config.productionTip = false
Vue.use(VueAxios, axios)
axios.defaults.baseURL = '/api'

Vue.use(Antd)

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')
