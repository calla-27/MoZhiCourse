<template>
  <div class="modal" :class="{active:modelValue}" @click.self="close">
    <div class="modal-content">
      <div class="modal-header">
        <h3 class="modal-title">账户设置</h3>
        <button class="close-modal" @click="close">&times;</button>
      </div>
      <form @submit.prevent="save">
        <div class="form-group"><label class="form-label">用户名</label><input v-model="form.name" type="text" class="form-input"></div>
        <div class="form-group"><label class="form-label">邮箱地址</label><input v-model="form.email" type="email" class="form-input"></div>
        <div class="form-group"><label class="form-label">职业</label><input v-model="form.job" type="text" class="form-input"></div>
        <div class="form-group"><label class="form-label">学习目标</label>
          <select v-model="form.goal" class="form-input">
            <option>考公</option><option>考研</option><option>兴趣爱好</option><option>职业晋升</option>
          </select>
        </div>
        <h3 class="modal-title" style="margin-top:30px">修改密码</h3>
        <div class="form-group"><label class="form-label">新密码</label><input v-model="form.pwd" type="password" class="form-input"></div>
        <div class="form-group"><label class="form-label">确认新密码</label><input v-model="form.pwd2" type="password" class="form-input"></div>
        <button type="submit" class="btn btn-primary" style="width:100%">保存设置</button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { useUserStore } from '../stores/user'
const user = useUserStore()
const form = reactive({
  name:user.name,
  email:'zhangsan@email.com',
  job:'前端开发工程师',
  goal:'职业晋升',
  pwd:'',
  pwd2:''
})
defineProps<{modelValue:boolean}>()
const emit = defineEmits<{ 'update:modelValue':[v:boolean] }>()
function close(){ emit('update:modelValue',false) }
function save(){ user.name=form.name; close() }
</script>

<!-- <style scoped>
/* 同 NameModal */
.modal{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:1000;display:none;align-items:center;justify-content:center}.modal.active{display:flex}.modal-content{background:white;border-radius:12px;padding:25px;width:90%;max-width:450px;box-shadow:0 5px 25px rgba(0,0,0,.2)}.modal-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:15px}.close-modal{background:none;border:none;font-size:1.3rem;cursor:pointer;color:#5f6368}.form-group{margin-bottom:20px}.form-label{display:block;margin-bottom:6px;font-weight:500;color:#202124}.form-input{width:100%;padding:10px 12px;border:1px solid #dadce0;border-radius:6px;font-size:.95rem;transition:border-color .3s}.form-input:focus{outline:none;border-color:#1a73e8}.btn-primary{background:#1a73e8;color:white;border:none;padding:10px 25px;border-radius:6px;font-size:.95rem;cursor:pointer;transition:all .3s}.btn-primary:hover{background:#0d5bb9}
</style> -->

<style scoped src="../assets/student.css"></style>