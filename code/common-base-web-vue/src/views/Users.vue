<template>
  <div class="space-y-6">
    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-xl font-bold">用户管理</h2>
        <p class="text-sm text-base-content/50 mt-1">管理所有注册用户</p>
      </div>
      <div class="flex items-center gap-3">
        <div class="join">
          <input
            v-model="searchQuery"
            class="input input-bordered input-sm join-item w-52"
            placeholder="搜索用户..."
          />
          <button class="btn btn-sm btn-primary join-item">
            <component :is="SearchIcon" theme="outline" size="16" />
          </button>
        </div>
        <button class="btn btn-sm btn-primary gap-2" @click="showAddModal = true">
          <component :is="PlusIcon" theme="outline" size="16" />
          添加用户
        </button>
      </div>
    </div>

    <div class="card bg-base-100 border border-base-content/5">
      <div class="card-body p-0">
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr class="border-b border-base-content/5">
                <th>
                  <label>
                    <input type="checkbox" class="checkbox checkbox-sm checkbox-primary" />
                  </label>
                </th>
                <th>用户</th>
                <th>邮箱</th>
                <th>角色</th>
                <th>状态</th>
                <th>注册时间</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in filteredUsers" :key="user.id" class="hover">
                <th>
                  <label>
                    <input type="checkbox" class="checkbox checkbox-sm checkbox-primary" />
                  </label>
                </th>
                <td>
                  <div class="flex items-center gap-3">
                    <div class="avatar placeholder">
                      <div
                        class="w-9 h-9 rounded-full flex items-center justify-center"
                        :class="user.online ? 'bg-primary/10 text-primary' : 'bg-base-200 text-base-content/40'"
                      >
                        <span class="text-sm font-bold">{{ user.name[0] }}</span>
                      </div>
                    </div>
                    <div>
                      <p class="font-medium text-sm">{{ user.name }}</p>
                      <p class="text-xs text-base-content/40">ID: {{ user.id }}</p>
                    </div>
                  </div>
                </td>
                <td class="text-sm">{{ user.email }}</td>
                <td>
                  <span
                    class="badge badge-sm"
                    :class="user.role === '管理员' ? 'badge-primary' : 'badge-ghost'"
                  >
                    {{ user.role }}
                  </span>
                </td>
                <td>
                  <div class="flex items-center gap-1.5">
                    <div
                      class="w-2 h-2 rounded-full"
                      :class="user.online ? 'bg-success' : 'bg-base-content/20'"
                    ></div>
                    <span class="text-sm" :class="user.online ? 'text-success' : 'text-base-content/40'">
                      {{ user.online ? '在线' : '离线' }}
                    </span>
                  </div>
                </td>
                <td class="text-sm text-base-content/50">{{ user.createdAt }}</td>
                <td>
                  <div class="flex items-center gap-1">
                    <button class="btn btn-ghost btn-xs" @click="editUser(user)">
                      <component :is="EditIcon" theme="outline" size="14" />
                    </button>
                    <button class="btn btn-ghost btn-xs text-error" @click="deleteUser(user)">
                      <component :is="DeleteIcon" theme="outline" size="14" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="flex items-center justify-between p-4 border-t border-base-content/5">
          <p class="text-sm text-base-content/50">共 {{ filteredUsers.length }} 条记录</p>
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

    <dialog :class="['modal', { 'modal-open': showAddModal }]">
      <div class="modal-box">
        <h3 class="font-bold text-lg mb-4">添加用户</h3>
        <div class="space-y-4">
          <div class="form-control">
            <label class="label"><span class="label-text">用户名</span></label>
            <input v-model="newUser.name" class="input input-bordered w-full" placeholder="请输入用户名" />
          </div>
          <div class="form-control">
            <label class="label"><span class="label-text">邮箱</span></label>
            <input v-model="newUser.email" class="input input-bordered w-full" placeholder="请输入邮箱" />
          </div>
          <div class="form-control">
            <label class="label"><span class="label-text">角色</span></label>
            <select v-model="newUser.role" class="select select-bordered w-full">
              <option value="用户">普通用户</option>
              <option value="管理员">管理员</option>
            </select>
          </div>
        </div>
        <div class="modal-action">
          <button class="btn btn-ghost btn-sm" @click="showAddModal = false">取消</button>
          <button class="btn btn-primary btn-sm" @click="addUser">确认添加</button>
        </div>
      </div>
      <form method="dialog" class="modal-backdrop" @click="showAddModal = false">
        <button>close</button>
      </form>
    </dialog>
  </div>
</template>

<script setup>
import { ref, computed, reactive } from 'vue'
import {
  Search as SearchIcon,
  Plus as PlusIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
} from '@icon-park/vue-next'

const searchQuery = ref('')
const showAddModal = ref(false)

const newUser = reactive({ name: '', email: '', role: '用户' })

const users = ref([
  { id: 1001, name: '张三', email: 'zhangsan@example.com', role: '管理员', online: true, createdAt: '2024-01-15' },
  { id: 1002, name: '李四', email: 'lisi@example.com', role: '用户', online: true, createdAt: '2024-02-20' },
  { id: 1003, name: '王五', email: 'wangwu@example.com', role: '用户', online: false, createdAt: '2024-03-10' },
  { id: 1004, name: '赵六', email: 'zhaoliu@example.com', role: '用户', online: true, createdAt: '2024-04-05' },
  { id: 1005, name: '钱七', email: 'qianqi@example.com', role: '用户', online: false, createdAt: '2024-05-18' },
  { id: 1006, name: '孙八', email: 'sunba@example.com', role: '管理员', online: true, createdAt: '2024-06-22' },
  { id: 1007, name: '周九', email: 'zhoujiu@example.com', role: '用户', online: false, createdAt: '2024-07-30' },
  { id: 1008, name: '吴十', email: 'wushi@example.com', role: '用户', online: true, createdAt: '2024-08-14' },
])

const filteredUsers = computed(() => {
  if (!searchQuery.value) return users.value
  const q = searchQuery.value.toLowerCase()
  return users.value.filter(
    (u) => u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q)
  )
})

const editUser = (user) => {
  console.log('编辑用户:', user.name)
}

const deleteUser = (user) => {
  users.value = users.value.filter((u) => u.id !== user.id)
}

const addUser = () => {
  if (!newUser.name || !newUser.email) return
  users.value.unshift({
    id: Date.now(),
    name: newUser.name,
    email: newUser.email,
    role: newUser.role,
    online: false,
    createdAt: new Date().toISOString().split('T')[0],
  })
  newUser.name = ''
  newUser.email = ''
  newUser.role = '用户'
  showAddModal.value = false
}
</script>
