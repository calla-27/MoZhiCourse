<template>
  <div class="modal" :class="{active:modelValue}" @click.self="close">
    <div class="modal-content">
      <div class="modal-header">
        <h3 class="modal-title">修改用户名</h3>
        <button class="close-modal" @click="close">&times;</button>
      </div>
      <div class="form-group">
        <label class="form-label">新用户名</label>
        <input v-model="draft" type="text" class="form-input" @keydown.enter="save">
      </div>
      <button class="btn btn-primary" style="width:100%" @click="save">保存用户名</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useUserStore } from '../stores/user'
const user = useUserStore()
const draft = ref(user.name)
defineProps<{modelValue:boolean}>()
const emit = defineEmits<{ 'update:modelValue':[v:boolean] }>()
watch(()=>user.name, n=> draft.value=n)
function close(){ emit('update:modelValue',false) }
function save(){ user.name = draft.value||user.name; close() }
</script>

<!-- <style scoped>
/* 与 AvatarModal 相同，省略重复 */
.modal{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:1000;display:none;align-items:center;justify-content:center}.modal.active{display:flex}.modal-content{background:white;border-radius:12px;padding:25px;width:90%;max-width:450px;box-shadow:0 5px 25px rgba(0,0,0,.2)}.modal-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:15px}.close-modal{background:none;border:none;font-size:1.3rem;cursor:pointer;color:#5f6368}.form-group{margin-bottom:20px}.form-label{display:block;margin-bottom:6px;font-weight:500;color:#202124}.form-input{width:100%;padding:10px 12px;border:1px solid #dadce0;border-radius:6px;font-size:.95rem;transition:border-color .3s}.form-input:focus{outline:none;border-color:#1a73e8}.btn-primary{background:#1a73e8;color:white;border:none;padding:10px 25px;border-radius:6px;font-size:.95rem;cursor:pointer;transition:all .3s}.btn-primary:hover{background:#0d5bb9}
</style> -->

<style scoped src="../assets/student.css"></style>