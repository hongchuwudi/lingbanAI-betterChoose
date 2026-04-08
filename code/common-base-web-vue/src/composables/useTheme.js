import { ref, computed, onMounted } from 'vue'
import {
  SunOne,      // 太阳 - 简约白
  Moon,        // 月亮 - 高级黑
  Cherry,      // 樱桃 - 少女粉
  Leaf,        // 叶子 - 清新绿
  Water,       // 水滴 - 海洋蓝
  CupOne,      // 杯子 - 纸杯蛋糕
  Tree,        // 树木 - 森林绿
  Sunset       // 日落 - 日落橙
} from '@icon-park/vue-next'

// 使用 DaisyUI 内置主题，配合 IconPark 图标
export const themes = [
  {
    id: 'light',
    name: '简约白',
    icon: SunOne,
    color: '#3b82f6',
    description: '清新明亮，适合日间使用'
  },
  {
    id: 'dark',
    name: '高级黑',
    icon: Moon,
    color: '#6366f1',
    description: '深邃护眼，适合夜间使用'
  },
  {
    id: 'valentine',
    name: '少女粉',
    icon: Cherry,
    color: '#ec489a',
    description: '温柔甜美，少女心满满'
  },
  {
    id: 'emerald',
    name: '清新绿',
    icon: Leaf,
    color: '#10b981',
    description: '自然舒适，护眼清新'
  },
  {
    id: 'aqua',
    name: '海洋蓝',
    icon: Water,
    color: '#06b6d4',
    description: '宁静致远，专业稳重'
  },
  {
    id: 'cupcake',
    name: '纸杯蛋糕',
    icon: CupOne,
    color: '#f59e0b',
    description: '柔和温暖的色调'
  },
  {
    id: 'forest',
    name: '森林绿',
    icon: Tree,
    color: '#059669',
    description: '深绿色系，护眼舒适'
  },
  {
    id: 'sunset',
    name: '日落橙',
    icon: Sunset,
    color: '#f97316',
    description: '温暖的橙色系'
  },
]

export function useTheme() {
  const currentTheme = ref('light')

  // 切换主题
  const setTheme = (themeId) => {
    console.log('切换主题:', themeId)
    if (!themes.find(t => t.id === themeId)) return

    currentTheme.value = themeId
    document.documentElement.setAttribute('data-theme', themeId)
    localStorage.setItem('theme', themeId)
    console.log('主题设置完成，当前主题:', document.documentElement.getAttribute('data-theme'))
    // 检查当前主题
    console.log('当前data-theme:', document.documentElement.getAttribute('data-theme'))
    // 检查 CSS 变量是否存在
    console.log('--p 变量值:', getComputedStyle(document.documentElement).getPropertyValue('--p'))
  }

  // 获取当前主题信息
  const currentThemeInfo = computed(() => {
    return themes.find(t => t.id === currentTheme.value) || themes[0]
  })

  // 随机主题
  const randomTheme = () => {
    const randomIndex = Math.floor(Math.random() * themes.length)
    setTheme(themes[randomIndex].id)
  }

  // 初始化主题
  const initTheme = () => {
    const savedTheme = localStorage.getItem('theme')
    const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches

    if (savedTheme && themes.find(t => t.id === savedTheme)) {
      setTheme(savedTheme)
    } else if (systemPrefersDark) {
      setTheme('dark')
    } else {
      setTheme('light')
    }
  }

  // 监听系统主题变化
  const watchSystemTheme = () => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    const handler = (e) => {
      if (!localStorage.getItem('theme')) {
        setTheme(e.matches ? 'dark' : 'light')
      }
    }
    mediaQuery.addEventListener('change', handler)
    return () => mediaQuery.removeEventListener('change', handler)
  }

  onMounted(() => {
    initTheme()
    watchSystemTheme()
  })

  return {
    currentTheme,
    currentThemeInfo,
    themes,
    setTheme,
    randomTheme,
    initTheme,
  }
}