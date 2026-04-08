<template>
  <div class="fixed bottom-4 right-4 z-50">
    <div class="dropdown dropdown-top dropdown-end">
      <div tabindex="0" role="button" class="btn btn-primary btn-circle shadow-lg">
        <component :is="PaletteIcon" theme="outline" size="24" />
      </div>
      <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow-2xl bg-base-100 rounded-box w-64 gap-2">
        <li v-for="theme in themes" :key="theme.id" class="p-1">
          <button 
            @click="setTheme(theme.id)"
            class="flex items-center gap-3 p-2 rounded-lg transition-all"
            :class="{ 'bg-primary/10 text-primary': currentTheme === theme.id }"
          >
            <div 
              class="w-8 h-8 rounded-full shadow-md" 
              :style="{ backgroundColor: theme.color }"
            ></div>
            <div class="flex-1 text-left">
              <div class="font-medium">{{ theme.name }}</div>
              <div class="text-xs opacity-70">{{ theme.description }}</div>
            </div>
            <component 
              v-if="currentTheme === theme.id"
              :is="CheckOneIcon"
              theme="outline"
              size="18"
              class="text-primary"
            />
          </button>
        </li>
        <div class="divider my-1"></div>
        <li>
          <button @click="randomTheme" class="btn btn-ghost btn-sm justify-center gap-2">
            <component :is="ShuffleIcon" theme="outline" size="16" />
            随机主题
          </button>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { Theme, Check, ShuffleOne } from '@icon-park/vue-next'
import { useTheme } from '@/composables/useTheme'

const PaletteIcon = Theme
const CheckOneIcon = Check
const ShuffleIcon = ShuffleOne

const { currentTheme, themes, setTheme, randomTheme } = useTheme()
</script>