import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/Login.vue'),
      meta: { requiresAuth: false },
    },
    {
      path: '/',
      component: () => import('@/layouts/AdminLayout.vue'),
      redirect: '/dashboard',
      children: [
        {
          path: 'dashboard',
          name: 'dashboard',
          component: () => import('@/views/Dashboard.vue'),
          meta: { title: '仪表盘' },
        },
        {
          path: 'users',
          name: 'users',
          component: () => import('@/views/Users.vue'),
          meta: { title: '用户管理' },
        },
        {
          path: 'conversations',
          name: 'conversations',
          component: () => import('@/views/Conversations.vue'),
          meta: { title: 'AI对话管理' },
        },
        {
          path: 'voice',
          name: 'voice',
          component: () => import('@/views/Voice.vue'),
          meta: { title: '语音服务' },
        },
        {
          path: 'settings',
          name: 'settings',
          component: () => import('@/views/Settings.vue'),
          meta: { title: '系统设置' },
        },
      ],
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/dashboard',
    },
  ],
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')

  if (to.path === '/login') {
    next(token ? '/dashboard' : undefined)
    return
  }

  if (!token) {
    next('/login')
    return
  }

  next()
})

export default router
