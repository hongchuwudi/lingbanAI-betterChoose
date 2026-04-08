<template>
  <div class="container mx-auto p-4">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">关于项目</h2>
        <p>这是一个基于 Vite + Vue 3 的项目模板，集成了常用的开发工具和库。</p>
        <div class="mt-4">
          <h3 class="font-bold">项目特性：</h3>
          <ul class="list-disc list-inside mt-2 space-y-1">
            <li>⚡️ Vite - 极速的开发体验</li>
            <li>🎯 Vue 3 - 渐进式 JavaScript 框架</li>
            <li>📦 Pinia - 直观的状态管理</li>
            <li>🛣️ Vue Router - 官方路由管理器</li>
            <li>🎨 Tailwind CSS - 实用优先的 CSS 框架</li>
            <li>✨ DaisyUI - 漂亮的 Tailwind 组件库</li>
            <li>🌐 Axios - Promise 基于的 HTTP 客户端</li>
            <li>🔌 WebSocket - 实时双向通信</li>
            <li>🗺️ 百度地图 SDK - 地图服务集成</li>
          </ul>
        </div>
        <div class="card-actions justify-end mt-4">
          <router-link to="/" class="btn btn-primary">返回首页</router-link>
        </div>
      </div>
    </div>
  </div>
</template>