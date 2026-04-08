<template>
  <div class="hero min-h-[60vh] bg-gradient-to-br from-primary/20 to-secondary/20 rounded-box">
    <div class="hero-content text-center">
      <div class="max-w-md">
        <h1 class="text-4xl font-bold">主题切换演示</h1>
        <p class="py-6 text-lg text-base-content/80">
          当前主题：<span class="font-bold text-primary">{{ currentThemeInfo.name }}</span>
        </p>
        <p class="text-sm text-base-content/60">点击右上角图标切换主题，或打开右侧面板查看更多选项。</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useTheme } from '@/composables/useTheme'

const { currentThemeInfo } = useTheme()
</script>