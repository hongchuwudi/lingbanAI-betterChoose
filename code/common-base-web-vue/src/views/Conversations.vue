<template>
  <div class="space-y-6">
    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-xl font-bold">AI对话管理</h2>
        <p class="text-sm text-base-content/50 mt-1">查看和管理所有AI对话记录</p>
      </div>
      <div class="flex items-center gap-3">
        <select v-model="filterModel" class="select select-bordered select-sm">
          <option value="">全部模型</option>
          <option value="GPT-4">GPT-4</option>
          <option value="GPT-3.5">GPT-3.5</option>
        </select>
        <div class="join">
          <input
            v-model="searchQuery"
            class="input input-bordered input-sm join-item w-48"
            placeholder="搜索对话..."
          />
          <button class="btn btn-sm btn-primary join-item">
            <component :is="SearchIcon" theme="outline" size="16" />
          </button>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-4 gap-4">
      <div class="card bg-base-100 border border-base-content/5">
        <div class="card-body p-4">
          <p class="text-sm text-base-content/50">总对话数</p>
          <p class="text-2xl font-bold mt-1">12,847</p>
          <div class="flex items-center gap-1 mt-2">
            <component :is="UpIcon" theme="outline" size="12" class="text-success" />
            <span class="text-xs text-success font-medium">15.3%</span>
          </div>
        </div>
      </div>
      <div class="card bg-base-100 border border-base-content/5">
        <div class="card-body p-4">
          <p class="text-sm text-base-content/50">今日新增</p>
          <p class="text-2xl font-bold mt-1">284</p>
          <div class="flex items-center gap-1 mt-2">
            <component :is="UpIcon" theme="outline" size="12" class="text-success" />
            <span class="text-xs text-success font-medium">8.7%</span>
          </div>
        </div>
      </div>
      <div class="card bg-base-100 border border-base-content/5">
        <div class="card-body p-4">
          <p class="text-sm text-base-content/50">平均轮次</p>
          <p class="text-2xl font-bold mt-1">6.2</p>
          <div class="flex items-center gap-1 mt-2">
            <component :is="DownIcon" theme="outline" size="12" class="text-error" />
            <span class="text-xs text-error font-medium">2.1%</span>
          </div>
        </div>
      </div>
      <div class="card bg-base-100 border border-base-content/5">
        <div class="card-body p-4">
          <p class="text-sm text-base-content/50">Token消耗</p>
          <p class="text-2xl font-bold mt-1">1.2M</p>
          <div class="flex items-center gap-1 mt-2">
            <component :is="UpIcon" theme="outline" size="12" class="text-success" />
            <span class="text-xs text-success font-medium">12.5%</span>
          </div>
        </div>
      </div>
    </div>

    <div class="card bg-base-100 border border-base-content/5">
      <div class="card-body p-0">
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr class="border-b border-base-content/5">
                <th>会话ID</th>
                <th>用户</th>
                <th>最后消息</th>
                <th>模型</th>
                <th>消息数</th>
                <th>Token</th>
                <th>时间</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="conv in filteredConversations" :key="conv.id" class="hover">
                <td>
                  <span class="text-sm font-mono text-base-content/60">#{{ conv.id }}</span>
                </td>
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
                <td class="max-w-[200px] truncate text-sm text-base-content/60">{{ conv.lastMessage }}</td>
                <td><span class="badge badge-sm badge-outline">{{ conv.model }}</span></td>
                <td class="text-sm">{{ conv.messageCount }}</td>
                <td class="text-sm text-base-content/60">{{ conv.tokens }}</td>
                <td class="text-sm text-base-content/40">{{ conv.time }}</td>
                <td>
                  <div class="flex items-center gap-1">
                    <button class="btn btn-ghost btn-xs" @click="viewConversation(conv)">
                      <component :is="ViewIcon" theme="outline" size="14" />
                    </button>
                    <button class="btn btn-ghost btn-xs text-error" @click="deleteConversation(conv)">
                      <component :is="DeleteIcon" theme="outline" size="14" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="flex items-center justify-between p-4 border-t border-base-content/5">
          <p class="text-sm text-base-content/50">共 {{ filteredConversations.length }} 条记录</p>
          <div class="join">
            <button class="btn btn-sm join-item">«</button>
            <button class="btn btn-sm join-item btn-active">1</button>
            <button class="btn btn-sm join-item">2</button>
            <button class="btn btn-sm join-item">3</button>
            <button class="btn btn-sm join-item">»</button>
          </div>
        </div>
      </div>
    </div>

    <dialog :class="['modal', { 'modal-open': showDetailModal }]">
      <div class="modal-box max-w-2xl">
        <h3 class="font-bold text-lg mb-4">对话详情 #{{ selectedConv?.id }}</h3>
        <div v-if="selectedConv" class="space-y-3">
          <div class="flex items-center gap-3 text-sm">
            <span class="text-base-content/50">用户:</span>
            <span class="font-medium">{{ selectedConv.user }}</span>
            <span class="text-base-content/50">模型:</span>
            <span class="badge badge-sm badge-outline">{{ selectedConv.model }}</span>
          </div>
          <div class="divider my-2"></div>
          <div class="space-y-3 max-h-96 overflow-y-auto scrollable">
            <div v-for="(msg, i) in mockMessages" :key="i" class="chat" :class="msg.isUser ? 'chat-end' : 'chat-start'">
              <div class="chat-image avatar placeholder">
                <div
                  class="w-8 h-8 rounded-full flex items-center justify-center"
                  :class="msg.isUser ? 'bg-primary/10 text-primary' : 'bg-secondary/10 text-secondary'"
                >
                  <span class="text-xs font-bold">{{ msg.isUser ? selectedConv.user[0] : 'AI' }}</span>
                </div>
              </div>
              <div
                class="chat-bubble text-sm"
                :class="msg.isUser ? 'chat-bubble-primary' : ''"
              >
                {{ msg.content }}
              </div>
            </div>
          </div>
        </div>
        <div class="modal-action">
          <button class="btn btn-sm" @click="showDetailModal = false">关闭</button>
        </div>
      </div>
      <form method="dialog" class="modal-backdrop" @click="showDetailModal = false">
        <button>close</button>
      </form>
    </dialog>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import {
  Search as SearchIcon,
  Up as UpIcon,
  Down as DownIcon,
  PreviewOpen as ViewIcon,
  Delete as DeleteIcon,
} from '@icon-park/vue-next'

const searchQuery = ref('')
const filterModel = ref('')
const showDetailModal = ref(false)
const selectedConv = ref(null)

const conversations = ref([
  { id: 'A001', user: '张三', lastMessage: '帮我分析一下最近的销售数据趋势', model: 'GPT-4', messageCount: 12, tokens: '4,521', time: '2分钟前' },
  { id: 'A002', user: '李四', lastMessage: '请帮我写一份项目周报', model: 'GPT-4', messageCount: 8, tokens: '2,847', time: '8分钟前' },
  { id: 'A003', user: '王五', lastMessage: '这段代码有什么问题？如何优化？', model: 'GPT-4', messageCount: 15, tokens: '6,234', time: '15分钟前' },
  { id: 'A004', user: '赵六', lastMessage: '帮我翻译这篇英文文档', model: 'GPT-3.5', messageCount: 4, tokens: '1,203', time: '30分钟前' },
  { id: 'A005', user: '钱七', lastMessage: '推荐一些学习资源', model: 'GPT-4', messageCount: 6, tokens: '2,156', time: '1小时前' },
  { id: 'A006', user: '孙八', lastMessage: '帮我写一个Python爬虫', model: 'GPT-4', messageCount: 20, tokens: '8,932', time: '2小时前' },
  { id: 'A007', user: '周九', lastMessage: '这个需求怎么实现？', model: 'GPT-3.5', messageCount: 10, tokens: '3,421', time: '3小时前' },
  { id: 'A008', user: '吴十', lastMessage: '帮我整理一下会议纪要', model: 'GPT-4', messageCount: 3, tokens: '987', time: '5小时前' },
])

const mockMessages = [
  { content: '你好，请帮我分析一下最近的销售数据趋势', isUser: true },
  { content: '好的，我来帮您分析销售数据趋势。请问您有具体的销售数据吗？可以提供一下数据来源或上传相关文件。', isUser: false },
  { content: '这是上个月的数据：总销售额 128 万，环比增长 15%，其中线上渠道占比 62%。', isUser: true },
  { content: '根据您提供的数据，我分析如下：\n\n1. **整体趋势向好**：环比增长 15% 表明业务在稳步提升\n2. **线上渠道优势明显**：62% 的占比说明数字化转型成效显著\n3. **建议**：继续加大线上投入，同时关注线下渠道的优化', isUser: false },
]

const filteredConversations = computed(() => {
  let result = conversations.value
  if (filterModel.value) {
    result = result.filter((c) => c.model === filterModel.value)
  }
  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    result = result.filter(
      (c) => c.user.toLowerCase().includes(q) || c.lastMessage.toLowerCase().includes(q) || c.id.toLowerCase().includes(q)
    )
  }
  return result
})

const viewConversation = (conv) => {
  selectedConv.value = conv
  showDetailModal.value = true
}

const deleteConversation = (conv) => {
  conversations.value = conversations.value.filter((c) => c.id !== conv.id)
}
</script>
