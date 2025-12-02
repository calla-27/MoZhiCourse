<template>
  <div class="modal" :class="{active:modelValue}" @click.self="close">
    <div class="modal-content">
      <div class="modal-header">
        <h3 class="modal-title">更换头像</h3>
        <button class="close-modal" @click="close">&times;</button>
      </div>
      <div class="avatar-upload">
        <div class="avatar-preview"><img v-if="preview" :src="preview" alt="预览"/><span v-else>预览</span></div>
        <label for="avatar-file" class="upload-btn"><i class="fas fa-upload"></i> 选择图片</label>
        <input id="avatar-file" type="file" accept="image/*" @change="onFile">
      </div>
      <button class="btn btn-primary" style="width:100%" @click="save">保存头像</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useUserStore } from '../stores/user'
import http from '../api/http'

const user = useUserStore()
const preview = ref('')
defineProps<{modelValue:boolean}>()
const emit = defineEmits<{ 'update:modelValue':[v:boolean] }>()
function close(){ emit('update:modelValue',false) }
function onFile(e:Event){
  const file = (e.target as HTMLInputElement).files?.[0]
  if(!file) return
  const reader = new FileReader()
  reader.onload = r=> preview.value = r.target?.result as string
  reader.readAsDataURL(file)
}
function save(){
  if(preview.value) user.avatar = preview.value
  close()
}
async function upload(file: File) {
  const fd = new FormData()
  fd.append('avatar', file)
  const { data } = await http.post('/user/avatar', fd, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
  // data.avatar 即为新地址
  emit('update:modelValue', false)
  location.reload()   // 简单刷新即可
}
</script>

<style scoped>
.modal{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:1000;display:none;align-items:center;justify-content:center}
.modal.active{display:flex}
.modal-content{background:white;border-radius:12px;padding:25px;width:90%;max-width:450px;box-shadow:0 5px 25px rgba(0,0,0,.2)}
.modal-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:15px}
.modal-title{font-size:1.3rem;font-weight:600}
.close-modal{background:none;border:none;font-size:1.3rem;cursor:pointer;color:#5f6368}
.avatar-upload{text-align:center;margin-bottom:15px}
.avatar-preview{width:100px;height:100px;border-radius:50%;margin:0 auto 12px;background:#f8f9fa;display:flex;align-items:center;justify-content:center;overflow:hidden;border:2px dashed #dadce0}
.avatar-preview img{width:100%;height:100%;object-fit:cover}
.upload-btn{display:inline-block;padding:8px 16px;background:#e8f0fe;color:#1a73e8;border-radius:6px;cursor:pointer;transition:all .3s}
.upload-btn:hover{background:#1a73e8;color:white}
#avatar-file{display:none}
.btn-primary{background:#1a73e8;color:white;border:none;padding:10px 25px;border-radius:6px;font-size:.95rem;cursor:pointer;transition:all .3s}
.btn-primary:hover{background:#0d5bb9}
</style>
