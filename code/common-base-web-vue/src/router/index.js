import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/Home.vue'),
    },
    // 添加更多路由示例
    {
      path: '/about',
      name: 'about',
      component: () => import('@/views/About.vue'),
    },
    // 添加图标列表页面路由
    {
      path: '/icon-list',
      name: 'icon-list',
      component: () => import('@/views/test/IconList.vue'),
    },
  ],
})

export default router