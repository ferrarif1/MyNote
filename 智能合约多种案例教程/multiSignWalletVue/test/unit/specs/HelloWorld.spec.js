import Vue from 'vue'
import metaMask from '@/components/MetaMask.vue'

describe('MetaMask.vue', () => {
  it('should render correct contents', () => {
    const Constructor = Vue.extend(metaMask)
    const vm = new Constructor().$mount()
    expect(vm.$el.querySelector('.hello h1').textContent)
      .toEqual('Welcome to Your Vue.js App')
  })
})
