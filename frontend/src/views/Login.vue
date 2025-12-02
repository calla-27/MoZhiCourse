<!-- src/views/Login.vue -->
<template>
  <form @submit.prevent="handleLogin">
    <input v-model="phone" placeholder="手机号" />
    <input v-model="pwd" type="password" placeholder="密码" />
    <button>登录</button>
  </form>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { apiLogin } from '../api/auth'

const phone = ref('')
const pwd   = ref('')
const router = useRouter()

async function handleLogin() {
  try {
    console.log('开始登录...');
    const { data } = await apiLogin(phone.value, pwd.value);
    
    // 确认接口返回了正确的数据
    console.log('接口返回数据:', data); 

    localStorage.setItem('token', data.token);
    localStorage.setItem('role', data.user.role);

    console.log('准备跳转到首页...');
    router.push('/'); 
    console.log('跳转指令已发出');
  } catch (error) {
    console.error('登录失败或跳转异常:', error);
    // 在这里可以给用户一个明确的错误提示
  }
}
</script>