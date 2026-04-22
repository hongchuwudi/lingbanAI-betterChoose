<template>
  <div class="space-y-6">
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div
        v-for="stat in stats"
        :key="stat.label"
        class="card bg-base-100 border border-base-content/5 card-hover"
      >
        <div class="card-body p-5">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-base-content/50 font-medium">{{ stat.label }}</p>
              <p class="text-2xl font-bold mt-1">{{ stat.value }}</p>
            </div>
            <div
              class="w-12 h-12 rounded-xl flex items-center justify-center"
              :class="stat.bgClass"
            >
              <component :is="stat.icon" theme="filled" size="24" :fill="stat.color" />
            </div>
          </div>
          <div class="flex items-center gap-1 mt-3">
            <component
              :is="stat.trend > 0 ? UpIcon : DownIcon"
              theme="outline"
              size="14"
              :class="stat.trend > 0 ? 'text-success' : 'text-error'"
            />
            <span
              class="text-xs font-medium"
              :class="stat.trend > 0 ? 'text-success' : 'text-error'"
            >
              {{ Math.abs(stat.trend) }}%
            </span>
            <span class="text-xs text-base-content/40">较上周</span>
          </div>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
      <div class="lg:col-span-2 card bg-base-100 border border-base-content/5">
        <div class="card-body p-5">
          <div class="flex items-center justify-between mb-4">
            <h3 class="font-semibold">对话趋势</h3>
            <div class="join">
              <button
                v-for="period in ['7天', '30天', '90天']"
                :key="period"
                class="btn btn-xs join-item"
                :class="selectedPeriod === period ? 'btn-primary' : 'btn-ghost'"
                @click="selectedPeriod = period"
              >
                {{ period }}
              </button>
            </div>
          </div>
          <div ref="chartRef" class="w-full h-64"></div>
        </div>
      </div>

      <div class="card bg-base-100 border border-base-content/5">
        <div class="card-body p-5">
          <h3 class="font-semibold mb-4">活跃用户</h3>
          <div class="space-y-3">
            <div
              v-for="user in activeUsers"
              :key="user.name"
              class="flex items-center gap-3 p-2 rounded-lg hover:bg-base-200 transition-colors"
            >
              <div class="avatar placeholder">
                <div class="bg-primary/10 text-primary w-9 h-9 rounded-full flex items-center justify-center">
                  <span class="text-sm font-bold">{{ user.name[0] }}</span>
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium truncate">{{ user.name }}</p>
                <p class="text-xs text-base-content/40">{{ user.lastActive }}</p>
              </div>
              <div class="text-right">
                <p class="text-sm font-semibold">{{ user.messages }}</p>
                <p class="text-xs text-base-content/40">条消息</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="card bg-base-100 border border-base-content/5">
      <div class="card-body p-5">
        <div class="flex items-center justify-between mb-4">
          <h3 class="font-semibold">最近对话</h3>
          <router-link to="/conversations" class="btn btn-ghost btn-sm text-primary">
            查看全部 →
          </router-link>
        </div>
        <div class="overflow-x-auto">
          <table class="table table-sm">
            <thead>
              <tr class="border-b border-base-content/5">
                <th>用户</th>
                <th>内容</th>
                <th>模型</th>
                <th>时间</th>
                <th>状态</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="conv in recentConversations" :key="conv.id" class="hover">
                <td>
                  <div class="flex items-center gap-2">
                    <div class="avatar placeholder">
                      <div class="bg-primary/10 text-primary w-7 h-7 rounded-full flex items-center justify-center">
                        <span class="text-xs font-bold">{{ conv.user[0] }}</span>
                      </div>
                    </div>
                    <span class="text-sm font-medium">{{ conv.user }}</span>
                  </div>
                </td>
                <td class="max-w-xs truncate text-sm text-base-content/70">{{ conv.content }}</td>
                <td><span class="badge badge-sm badge-outline">{{ conv.model }}</span></td>
                <td class="text-sm text-base-content/50">{{ conv.time }}</td>
                <td>
                  <span
                    class="badge badge-sm"
                    :class="conv.status === '完成' ? 'badge-success' : 'badge-warning'"
                  >
                    {{ conv.status }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import {
  MessageOne,
  People,
  SoundOne,
  Timer,
  Up as UpIcon,
  Down as DownIcon,
} from '@icon-park/vue-next'
import * as echarts from 'echarts'

const chartRef = ref(null)
let chartInstance = null
const selectedPeriod = ref('7天')

const stats = [
  {
    label: '今日对话',
    value: '1,284',
    icon: MessageOne,
    color: '#6366f1',
    bgClass: 'bg-indigo-500/10',
    trend: 12.5,
  },
  {
    label: '活跃用户',
    value: '368',
    icon: People,
    color: '#10b981',
    bgClass: 'bg-emerald-500/10',
    trend: 8.2,
  },
  {
    label: '语音调用',
    value: '526',
    icon: SoundOne,
    color: '#f59e0b',
    bgClass: 'bg-amber-500/10',
    trend: -3.1,
  },
  {
    label: '平均响应',
    value: '1.2s',
    icon: Timer,
    color: '#ef4444',
    bgClass: 'bg-red-500/10',
    trend: 5.4,
  },
]

const activeUsers = [
  { name: '张三', lastActive: '2分钟前', messages: 156 },
  { name: '李四', lastActive: '5分钟前', messages: 89 },
  { name: '王五', lastActive: '12分钟前', messages: 234 },
  { name: '赵六', lastActive: '30分钟前', messages: 67 },
  { name: '钱七', lastActive: '1小时前', messages: 112 },
]

const recentConversations = [
  { id: 1, user: '张三', content: '帮我分析一下最近的销售数据趋势', model: 'GPT-4', time: '2分钟前', status: '完成' },
  { id: 2, user: '李四', content: '请帮我写一份项目周报', model: 'GPT-4', time: '8分钟前', status: '完成' },
  { id: 3, user: '王五', content: '这段代码有什么问题？', model: 'GPT-4', time: '15分钟前', status: '进行中' },
  { id: 4, user: '赵六', content: '帮我翻译这篇英文文档', model: 'GPT-3.5', time: '30分钟前', status: '完成' },
  { id: 5, user: '钱七', content: '推荐一些学习资源', model: 'GPT-4', time: '1小时前', status: '完成' },
]

const initChart = () => {
  if (!chartRef.value) return
  chartInstance = echarts.init(chartRef.value)

  const option = {
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(255,255,255,0.95)',
      borderColor: '#e5e7eb',
      textStyle: { color: '#374151', fontSize: 12 },
    },
    grid: { left: '3%', right: '4%', bottom: '3%', top: '8%', containLabel: true },
    xAxis: {
      type: 'category',
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
      axisLine: { lineStyle: { color: '#e5e7eb' } },
      axisLabel: { color: '#9ca3af', fontSize: 11 },
      axisTick: { show: false },
    },
    yAxis: {
      type: 'value',
      axisLine: { show: false },
      axisLabel: { color: '#9ca3af', fontSize: 11 },
      splitLine: { lineStyle: { color: '#f3f4f6', type: 'dashed' } },
    },
    series: [
      {
        name: '对话数',
        type: 'line',
        smooth: true,
        symbol: 'circle',
        symbolSize: 6,
        lineStyle: { width: 2.5, color: '#6366f1' },
        itemStyle: { color: '#6366f1', borderWidth: 2, borderColor: '#fff' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(99,102,241,0.25)' },
            { offset: 1, color: 'rgba(99,102,241,0.02)' },
          ]),
        },
        data: [820, 932, 901, 1290, 1130, 1020, 1284],
      },
      {
        name: '语音调用',
        type: 'line',
        smooth: true,
        symbol: 'circle',
        symbolSize: 6,
        lineStyle: { width: 2.5, color: '#f59e0b' },
        itemStyle: { color: '#f59e0b', borderWidth: 2, borderColor: '#fff' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(245,158,11,0.15)' },
            { offset: 1, color: 'rgba(245,158,11,0.02)' },
          ]),
        },
        data: [320, 402, 351, 534, 490, 430, 526],
      },
    ],
  }

  chartInstance.setOption(option)
}

const handleResize = () => chartInstance?.resize()

onMounted(() => {
  initChart()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  chartInstance?.dispose()
})
</script>
