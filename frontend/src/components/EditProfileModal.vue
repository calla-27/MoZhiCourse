<template>
  <div class="modal" :class="{ active: modelValue }" @click.self="close">
    <div class="modal-content">
      <div class="modal-header">
        <h3>编辑个人资料</h3>
        <button class="close-btn" @click="close">&times;</button>
      </div>
      <div class="form-group">
        <label>昵称</label>
        <input v-model="form.userName" type="text" class="form-input" placeholder="请输入昵称" />
      </div>
      <div class="form-group">
        <label>邮箱</label>
        <input v-model="form.email" type="email" class="form-input" placeholder="请输入邮箱" />
      </div>
      <div class="form-group">
        <label>个性签名</label>
        <textarea v-model="form.userIntro" class="form-input" rows="3" placeholder="写点什么介绍自己吧～" />
      </div>
      <button class="btn btn-primary" @click="save" :disabled="saving">
        {{ saving ? '保存中...' : '保存' }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { reactive, watch, ref } from 'vue'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  userName: { type: String, default: '' },
  email: { type: String, default: '' },
  userIntro: { type: String, default: '' }
})

const emit = defineEmits(['update:modelValue', 'save'])

const form = reactive({
  userName: '',
  email: '',
  userIntro: ''
})

const saving = ref(false)

watch(
  () => props.modelValue,
  (val) => {
    if (val) {
      form.userName = props.userName || ''
      form.email = props.email || ''
      form.userIntro = props.userIntro || ''
    }
  }
)

function close() {
  if (saving.value) return
  emit('update:modelValue', false)
}

async function save() {
  if (!form.userName.trim()) {
    alert('昵称不能为空')
    return
  }
  saving.value = true
  try {
    await emit('save', { ...form })
    emit('update:modelValue', false)
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
}

.modal.active {
  opacity: 1;
  visibility: visible;
}

.modal-content {
  background: white;
  border-radius: 12px;
  padding: 1.8rem;
  width: 90%;
  max-width: 420px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.2rem;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.4rem;
  cursor: pointer;
  color: #666;
}

.form-group {
  margin-bottom: 1rem;
  text-align: left;
}

.form-group label {
  display: block;
  margin-bottom: 0.4rem;
  font-weight: 500;
}

.form-input {
  width: 100%;
  padding: 0.6rem 0.8rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 0.95rem;
}

.btn {
  width: 100%;
  padding: 0.7rem 1.2rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
}

.btn-primary {
  background: #1a73e8;
  color: white;
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>
