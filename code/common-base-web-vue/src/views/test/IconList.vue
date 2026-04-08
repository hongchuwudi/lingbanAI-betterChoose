<template>
  <div class="p-4">
    <h1>图标列表已输出到控制台</h1>
    <p>请打开浏览器开发者工具查看</p>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import * as Icons from '@icon-park/vue-next'

onMounted(() => {
  // 获取所有导出名称
  const allExports = Object.keys(Icons)
  
  // 过滤出图标组件（通常以大写字母开头，且不是内部配置）
  const iconNames = allExports.filter(name => 
    /^[A-Z]/.test(name) && 
    name !== 'DEFAULT_ICON_CONFIGS' && 
    name !== 'IconProvider'
  )
  
  console.log(`共 ${iconNames.length} 个图标：`)
  console.table(iconNames) // 表格形式，清晰易读
  
  // 也可以逐个打印详细信息
  iconNames.forEach(name => {
    console.log(`图标: ${name}`)
    // 如果需要更多信息，可以尝试打印组件，但通常只有名称
  })
})
</script>