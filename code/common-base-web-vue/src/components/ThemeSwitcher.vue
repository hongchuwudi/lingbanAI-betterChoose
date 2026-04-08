<template>
  <div class="dropdown dropdown-end">
    <div tabindex="0" role="button" class="btn btn-ghost btn-circle">
      <component 
        :is="currentThemeInfo.icon" 
        theme="outline" 
        size="20" 
        fill="currentColor"
      />
    </div>
    <ul class="dropdown-content z-[1] menu p-2 shadow-2xl bg-base-100 rounded-box w-52">
      <li v-for="theme in themes" :key="theme.id" @click="setTheme(theme.id)">
        <a class="gap-2">
          <component 
            :is="theme.icon" 
            theme="outline" 
            size="18" 
            fill="currentColor"
          />
          {{ theme.name }}
        </a>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { useTheme } from '@/composables/useTheme'

const { currentThemeInfo, themes, setTheme } = useTheme()
</script>