<template>
  <div class="space-y-6">
    <div>
      <h2 class="text-xl font-bold">语音服务</h2>
      <p class="text-sm text-base-content/50 mt-1">管理语音识别与语音合成服务</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div class="card bg-base-100 border border-base-content/5">
        <div class="card-body p-5">
          <div class="flex items-center gap-3 mb-4">
            <div class="w-10 h-10 rounded-xl bg-blue-500/10 flex items-center justify-center">
              <component :is="MicIcon" theme="filled" size="22" fill="#3b82f6" />
            </div>
            <div>
              <h3 class="font-semibold">语音识别 (ASR)</h3>
              <p class="text-xs text-base-content/40">Paraformer-v2</p>
            </div>
            <span class="badge badge-success badge-sm ml-auto">运行中</span>
          </div>

          <div class="grid grid-cols-2 gap-3 mb-4">
            <div class="bg-base-200/50 rounded-lg p-3">
              <p class="text-xs text-base-content/40">今日调用</p>
              <p class="text-lg font-bold">326</p>
            </div>
            <div class="bg-base-200/50 rounded-lg p-3">
              <p class="text-xs text-base-content/40">成功率</p>
              <p class="text-lg font-bold text-success">98.5%</p>
            </div>
            <div class="bg-base-200/50 rounded-lg p-3">
              <p class="text-xs text-base-content/40">平均耗时</p>
              <p class="text-lg font-bold">3.2s</p>
            </div>
            <div class="bg-base-200/50 rounded-lg p-3">
              <p class="text-xs text-base-content/40">存储用量</p>
              <p class="text-lg font-bold">2.1G</p>
            </div>
          </div>

          <div class="flex items-center justify-between text-sm">
            <span class="text-base-content/50">支持格式</span>
            <div class="flex gap-1">
              <span class="badge badge-xs badge-outline">WAV</span>
              <span class="badge badge-xs badge-outline">MP3</span>
              <span class="badge badge-xs badge-outline">M4A</span>
              <span class="badge badge-xs badge-outline">PCM</span>
            </div>
          </div>
        </div>
      </div>

      <div class="card bg-base-100 border border-base-content/5">
        <div class="card-body p-5">
          <div class="flex items-center gap-3 mb-4">
            <div class="w-10 h-10 rounded-xl bg-purple-500/10 flex items-center justify-center">
              <component :is="SpeakerIcon" theme="filled" size="22" fill="#8b5cf6" />
            </div>
            <div>
              <h3 class="font-semibold">语音合成 (TTS)</h3>
              <p class="text-xs text-base-content/40">CosyVoice-v1</p>
            </div>
            <span class="badge badge-success badge-sm ml-auto">运行中</span>
          </div>

          <div class="grid grid-cols-2 gap-3 mb-4">
            <div class="bg-base-200/50 rounded-lg p-3">
              <p class="text-xs text-base-content/40">今日调用</p>
              <p class="text-lg font-bold">526</p>
            </div>
            <div class="bg-base-200/50 rounded-lg p-3">
              <p class="text-xs text-base-content/40">成功率</p>
              <p class="text-lg font-bold text-success">99.1%</p>
            </div>
            <div class="bg-base-200/50 rounded-lg p-3">
              <p class="text-xs text-base-content/40">平均耗时</p>
              <p class="text-lg font-bold">1.8s</p>
            </div>
            <div class="bg-base-200/50 rounded-lg p-3">
              <p class="text-xs text-base-content/40">存储用量</p>
              <p class="text-lg font-bold">4.7G</p>
            </div>
          </div>

          <div class="flex items-center justify-between text-sm">
            <span class="text-base-content/50">当前音色</span>
            <div class="flex gap-1">
              <span class="badge badge-xs badge-primary">龙华</span>
              <span class="badge badge-xs badge-outline">MP3</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="card bg-base-100 border border-base-content/5">
      <div class="card-body p-5">
        <h3 class="font-semibold mb-4">语音文件管理</h3>
        <div class="overflow-x-auto">
          <table class="table table-sm">
            <thead>
              <tr class="border-b border-base-content/5">
                <th>文件名</th>
                <th>类型</th>
                <th>大小</th>
                <th>时长</th>
                <th>上传时间</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="file in voiceFiles" :key="file.name" class="hover">
                <td>
                  <div class="flex items-center gap-2">
                    <component
                      :is="file.type === 'ASR' ? MicIcon : SpeakerIcon"
                      theme="outline"
                      size="16"
                      :class="file.type === 'ASR' ? 'text-blue-500' : 'text-purple-500'"
                    />
                    <span class="text-sm font-mono">{{ file.name }}</span>
                  </div>
                </td>
                <td>
                  <span
                    class="badge badge-xs"
                    :class="file.type === 'ASR' ? 'badge-info' : 'badge-secondary'"
                  >
                    {{ file.type }}
                  </span>
                </td>
                <td class="text-sm text-base-content/60">{{ file.size }}</td>
                <td class="text-sm text-base-content/60">{{ file.duration }}</td>
                <td class="text-sm text-base-content/40">{{ file.time }}</td>
                <td>
                  <div class="flex items-center gap-1">
                    <button class="btn btn-ghost btn-xs">
                      <component :is="PlayIcon" theme="outline" size="14" />
                    </button>
                    <button class="btn btn-ghost btn-xs">
                      <component :is="DownloadIcon" theme="outline" size="14" />
                    </button>
                    <button class="btn btn-ghost btn-xs text-error">
                      <component :is="DeleteIcon" theme="outline" size="14" />
                    </button>
                  </div>
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
import {
  Microphone as MicIcon,
  Speaker as SpeakerIcon,
  PlayOne as PlayIcon,
  Download as DownloadIcon,
  Delete as DeleteIcon,
} from '@icon-park/vue-next'

const voiceFiles = [
  { name: 'asr_1710000001.m4a', type: 'ASR', size: '245 KB', duration: '0:08', time: '2分钟前' },
  { name: 'tts_1710000002.mp3', type: 'TTS', size: '1.2 MB', duration: '0:15', time: '3分钟前' },
  { name: 'asr_1710000003.m4a', type: 'ASR', size: '189 KB', duration: '0:06', time: '10分钟前' },
  { name: 'tts_1710000004.mp3', type: 'TTS', size: '2.1 MB', duration: '0:28', time: '15分钟前' },
  { name: 'asr_1710000005.m4a', type: 'ASR', size: '312 KB', duration: '0:12', time: '30分钟前' },
  { name: 'tts_1710000006.mp3', type: 'TTS', size: '856 KB', duration: '0:11', time: '45分钟前' },
]
</script>
