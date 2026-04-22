<template>
  <div class="flex h-screen overflow-hidden">
    <aside
      class="flex flex-col border-r border-base-content/5 bg-base-100 transition-all duration-300 ease-in-out"
      :class="sidebarCollapsed ? 'w-[72px]' : 'w-60'"
    >
      <div class="flex h-16 items-center justify-between px-4 border-b border-base-content/5">
        <div v-if="!sidebarCollapsed" class="flex items-center gap-2.5 overflow-hidden">
          <div class="w-8 h-8 rounded-lg bg-primary flex items-center justify-center flex-shrink-0">
            <span class="text-primary-content text-sm font-bold">灵</span>
          </div>
          <span class="text-lg font-bold whitespace-nowrap">灵伴AI</span>
        </div>
        <div v-else class="w-8 h-8 rounded-lg bg-primary flex items-center justify-center mx-auto">
          <span class="text-primary-content text-sm font-bold">灵</span>
        </div>
      </div>

      <nav class="flex-1 py-3 overflow-y-auto scrollable">
        <div v-for="group in menuGroups" :key="group.label" class="mb-2">
          <div
            v-if="!sidebarCollapsed"
            class="px-4 py-2 text-[11px] font-semibold uppercase tracking-wider text-base-content/40"
          >
            {{ group.label }}
          </div>
          <div v-else class="my-2 mx-3 border-t border-base-content/5"></div>

          <router-link
            v-for="item in group.items"
            :key="item.path"
            :to="item.path"
            class="flex items-center gap-3 mx-2 px-3 py-2.5 rounded-lg transition-all duration-200 group/item"
            :class="[
              isActive(item.path)
                ? 'bg-primary/10 text-primary'
                : 'text-base-content/60 hover:bg-base-200 hover:text-base-content'
            ]"
          >
            <component
              :is="item.icon"
              theme="outline"
              :size="20"
              :fill="isActive(item.path) ? 'currentColor' : 'none'"
              class="flex-shrink-0"
            />
            <span
              v-if="!sidebarCollapsed"
              class="text-sm font-medium whitespace-nowrap"
            >
              {{ item.name }}
            </span>
            <span
              v-if="item.badge && !sidebarCollapsed"
              class="ml-auto badge badge-sm badge-primary"
            >
              {{ item.badge }}
            </span>
          </router-link>
        </div>
      </nav>

      <div class="p-3 border-t border-base-content/5">
        <button
          @click="sidebarCollapsed = !sidebarCollapsed"
          class="btn btn-ghost btn-sm w-full justify-center"
        >
          <component
            :is="sidebarCollapsed ? ExpandRight : FoldOne"
            theme="outline"
            size="18"
          />
        </button>
      </div>
    </aside>

    <div class="flex-1 flex flex-col overflow-hidden">
      <header class="h-16 flex items-center justify-between px-6 border-b border-base-content/5 bg-base-100/80 backdrop-blur-md">
        <div class="flex items-center gap-3">
          <h1 class="text-lg font-semibold">{{ currentPageTitle }}</h1>
        </div>

        <div class="flex items-center gap-3">
          <ThemeSwitcher />

          <div class="dropdown dropdown-end">
            <div tabindex="0" class="btn btn-ghost btn-circle avatar">
              <div class="w-9 h-9 rounded-full bg-primary/20 flex items-center justify-center">
                <span class="text-primary text-sm font-bold">管</span>
              </div>
            </div>
            <ul class="dropdown-content z-[1] menu p-2 shadow-xl bg-base-100 rounded-box w-52 border border-base-content/5">
              <li class="menu-title"><span>管理员</span></li>
              <li><a @click="$router.push('/settings')">
                <component :is="SettingsIcon" theme="outline" size="16" />系统设置
              </a></li>
              <li><a class="text-error" @click="handleLogout">
                <component :is="LogoutIcon" theme="outline" size="16" />退出登录
              </a></li>
            </ul>
          </div>
        </div>
      </header>

      <main class="flex-1 overflow-y-auto scrollable bg-base-200/50 p-6">
        <router-view v-slot="{ Component }">
          <transition name="page" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  DashboardOne,
  People,
  MessageOne,
  SettingTwo,
  SoundOne,
  ExpandRight,
  FoldOne,
  Logout as LogoutIcon,
  Settings as SettingsIcon,
} from '@icon-park/vue-next'
import ThemeSwitcher from '@/components/ThemeSwitcher.vue'

const route = useRoute()
const router = useRouter()
const sidebarCollapsed = ref(false)

const menuGroups = [
  {
    label: '概览',
    items: [
      { name: '仪表盘', path: '/dashboard', icon: DashboardOne },
    ],
  },
  {
    label: '管理',
    items: [
      { name: '用户管理', path: '/users', icon: People },
      { name: 'AI对话', path: '/conversations', icon: MessageOne, badge: '新' },
      { name: '语音服务', path: '/voice', icon: SoundOne },
    ],
  },
  {
    label: '系统',
    items: [
      { name: '系统设置', path: '/settings', icon: SettingTwo },
    ],
  },
]

const isActive = (path) => route.path === path || route.path.startsWith(path + '/')

const currentPageTitle = computed(() => {
  for (const group of menuGroups) {
    for (const item of group.items) {
      if (isActive(item.path)) return item.name
    }
  }
  return '灵伴AI'
})

const handleLogout = () => {
  localStorage.removeItem('token')
  router.push('/login')
}
</script>
