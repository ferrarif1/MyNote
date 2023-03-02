import Vue from 'vue'
import Router from 'vue-router'
import MetaMask from '@/components/MetaMask.vue'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'MetaMask',
      component: MetaMask
    }
  ]
})
