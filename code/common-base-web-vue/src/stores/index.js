import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

// 主 Store
export const useAppStore = defineStore('app', () => {
  // 状态
  const count = ref(0)
  const user = ref(null)
  const loading = ref(false)
  
  // 计算属性
  const doubleCount = computed(() => count.value * 2)
  
  // 方法
  const increment = () => {
    count.value++
  }
  
  const decrement = () => {
    count.value--
  }
  
  const setUser = (userData) => {
    user.value = userData
  }
  
  const setLoading = (status) => {
    loading.value = status
  }
  
  return {
    count,
    user,
    loading,
    doubleCount,
    increment,
    decrement,
    setUser,
    setLoading,
  }
})

// 可以创建其他 Store
export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(null)
  
  const setToken = (newToken) => {
    token.value = newToken
    localStorage.setItem('token', newToken)
  }
  
  const clearToken = () => {
    token.value = ''
    localStorage.removeItem('token')
  }
  
  return {
    token,
    userInfo,
    setToken,
    clearToken,
  }
})