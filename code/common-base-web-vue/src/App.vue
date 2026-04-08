<template>
  <div class="min-h-screen bg-base-200">
    <!-- 极简导航栏：仅显示标题和主题切换 -->
    <nav class="navbar bg-base-100 shadow-lg sticky top-0 z-50">
      <div class="container mx-auto flex justify-between items-center">
        <div class="text-xl font-bold">主题切换测试</div>
        <ThemeSwitcher />
      </div>
    </nav>

    <main class="container mx-auto p-4">
      <router-view />
    </main>

    <!-- 主题切换面板（可选，通常用于展示更多主题选项） -->
    <ThemePanel />
  </div>
</template>

<script setup>
import ThemeSwitcher from '@/components/ThemeSwitcher.vue'
import ThemePanel from '@/components/ThemePanel.vue'
</script>