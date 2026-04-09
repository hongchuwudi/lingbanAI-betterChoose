<template>
  <div class="min-h-screen flex items-center justify-center bg-base-200 p-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <div class="w-16 h-16 rounded-2xl bg-primary mx-auto mb-4 flex items-center justify-center shadow-lg shadow-primary/25">
          <span class="text-primary-content text-2xl font-bold">灵</span>
        </div>
        <h1 class="text-2xl font-bold">灵伴AI 管理后台</h1>
        <p class="text-base-content/50 mt-2 text-sm">登录以管理您的应用</p>
      </div>

      <div class="card bg-base-100 shadow-xl border border-base-content/5">
        <div class="card-body p-6">
          <form @submit.prevent="handleLogin" class="space-y-4">
            <div class="form-control">
              <label class="label">
                <span class="label-text font-medium">账号</span>
              </label>
              <input
                v-model="form.username"
                type="text"
                placeholder="请输入管理员账号"
                class="input input-bordered w-full focus:input-primary"
                autocomplete="username"
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text font-medium">密码</span>
              </label>
              <input
                v-model="form.password"
                type="password"
                placeholder="请输入密码"
                class="input input-bordered w-full focus:input-primary"
                autocomplete="current-password"
              />
            </div>

            <div class="form-control">
              <label class="label cursor-pointer justify-start gap-3">
                <input v-model="form.remember" type="checkbox" class="checkbox checkbox-sm checkbox-primary" />
                <span class="label-text">记住我</span>
              </label>
            </div>

            <button
              type="submit"
              class="btn btn-primary w-full"
              :disabled="loading"
            >
              <span v-if="loading" class="loading loading-spinner loading-sm"></span>
              {{ loading ? '登录中...' : '登 录' }}
            </button>
          </form>
        </div>
      </div>

      <div class="text-center mt-6">
        <ThemeSwitcher />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores'
import ThemeSwitcher from '@/components/ThemeSwitcher.vue'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)

const form = reactive({
  username: '',
  password: '',
  remember: false,
})

const handleLogin = async () => {
  if (!form.username || !form.password) return

  loading.value = true
  try {
    userStore.setToken('mock-admin-token')
    router.push('/dashboard')
  } finally {
    loading.value = false
  }
}
</script>
