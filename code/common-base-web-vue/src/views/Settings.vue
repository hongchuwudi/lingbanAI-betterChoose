<template>
  <div class="space-y-6">
    <div>
      <h2 class="text-xl font-bold">系统设置</h2>
      <p class="text-sm text-base-content/50 mt-1">配置系统参数和服务</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-4">
        <div class="card bg-base-100 border border-base-content/5">
          <div class="card-body p-5">
            <h3 class="font-semibold mb-4 flex items-center gap-2">
              <component :is="AiIcon" theme="outline" size="20" class="text-primary" />
              AI 模型配置
            </h3>
            <div class="space-y-4">
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">默认对话模型</span></label>
                <select v-model="settings.aiModel" class="select select-bordered w-full">
                  <option value="gpt-4">GPT-4</option>
                  <option value="gpt-4o">GPT-4o</option>
                  <option value="gpt-3.5-turbo">GPT-3.5 Turbo</option>
                </select>
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">API Key</span></label>
                <input
                  v-model="settings.apiKey"
                  type="password"
                  class="input input-bordered w-full"
                  placeholder="sk-..."
                />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">最大上下文轮次</span></label>
                <input v-model="settings.maxContext" type="number" class="input input-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">系统提示词</span></label>
                <textarea
                  v-model="settings.systemPrompt"
                  class="textarea textarea-bordered w-full h-24"
                  placeholder="请输入系统提示词..."
                ></textarea>
              </div>
            </div>
          </div>
        </div>

        <div class="card bg-base-100 border border-base-content/5">
          <div class="card-body p-5">
            <h3 class="font-semibold mb-4 flex items-center gap-2">
              <component :is="SoundIcon" theme="outline" size="20" class="text-secondary" />
              语音服务配置
            </h3>
            <div class="space-y-4">
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">TTS 模型</span></label>
                <select v-model="settings.ttsModel" class="select select-bordered w-full">
                  <option value="cosyvoice-v1">CosyVoice v1</option>
                  <option value="sambert-v1">Sambert v1</option>
                </select>
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">默认音色</span></label>
                <select v-model="settings.ttsVoice" class="select select-bordered w-full">
                  <option value="longhua">龙华</option>
                  <option value="longshuo">龙硕</option>
                  <option value="longyue">龙悦</option>
                </select>
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">ASR 模型</span></label>
                <select v-model="settings.asrModel" class="select select-bordered w-full">
                  <option value="paraformer-v2">Paraformer v2</option>
                  <option value="paraformer-v1">Paraformer v1</option>
                </select>
              </div>
              <div class="form-control">
                <label class="label cursor-pointer justify-start gap-3">
                  <input v-model="settings.streamTts" type="checkbox" class="checkbox checkbox-sm checkbox-primary" />
                  <span class="label-text">启用流式语音合成</span>
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="space-y-4">
        <div class="card bg-base-100 border border-base-content/5">
          <div class="card-body p-5">
            <h3 class="font-semibold mb-4 flex items-center gap-2">
              <component :is="StorageIcon" theme="outline" size="20" class="text-warning" />
              存储信息
            </h3>
            <div class="space-y-3">
              <div>
                <div class="flex justify-between text-sm mb-1">
                  <span class="text-base-content/60">OSS 存储</span>
                  <span class="font-medium">6.8 / 50 GB</span>
                </div>
                <progress class="progress progress-primary w-full" value="13.6" max="100"></progress>
              </div>
              <div>
                <div class="flex justify-between text-sm mb-1">
                  <span class="text-base-content/60">数据库</span>
                  <span class="font-medium">1.2 / 10 GB</span>
                </div>
                <progress class="progress progress-secondary w-full" value="12" max="100"></progress>
              </div>
              <div class="divider my-1"></div>
              <div class="flex justify-between text-sm">
                <span class="text-base-content/60">语音文件</span>
                <span class="font-medium">4.7 GB</span>
              </div>
              <div class="flex justify-between text-sm">
                <span class="text-base-content/60">图片文件</span>
                <span class="font-medium">2.1 GB</span>
              </div>
            </div>
          </div>
        </div>

        <div class="card bg-base-100 border border-base-content/5">
          <div class="card-body p-5">
            <h3 class="font-semibold mb-4 flex items-center gap-2">
              <component :is="InfoIcon" theme="outline" size="20" class="text-info" />
              系统信息
            </h3>
            <div class="space-y-2 text-sm">
              <div class="flex justify-between">
                <span class="text-base-content/60">版本</span>
                <span class="font-mono">v1.0.0</span>
              </div>
              <div class="flex justify-between">
                <span class="text-base-content/60">运行时间</span>
                <span>15天 8小时</span>
              </div>
              <div class="flex justify-between">
                <span class="text-base-content/60">JDK</span>
                <span class="font-mono">17.0.8</span>
              </div>
              <div class="flex justify-between">
                <span class="text-base-content/60">Spring Boot</span>
                <span class="font-mono">3.3.0</span>
              </div>
            </div>
          </div>
        </div>

        <button class="btn btn-primary w-full gap-2" @click="saveSettings">
          <component :is="SaveIcon" theme="outline" size="18" />
          保存设置
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
import {
  AiCenter as AiIcon,
  SoundOne as SoundIcon,
  Database as StorageIcon,
  Information as InfoIcon,
  Save as SaveIcon,
} from '@icon-park/vue-next'

const settings = reactive({
  aiModel: 'gpt-4',
  apiKey: '',
  maxContext: 20,
  systemPrompt: '你是一个智能助手，名叫灵伴。请用简洁友好的方式回答用户的问题。',
  ttsModel: 'cosyvoice-v1',
  ttsVoice: 'longhua',
  asrModel: 'paraformer-v2',
  streamTts: true,
})

const saveSettings = () => {
  console.log('保存设置:', settings)
}
</script>
