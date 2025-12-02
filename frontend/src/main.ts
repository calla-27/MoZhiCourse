import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router/index'
import App from './App.vue'
// import 'font-awesome/css/font-awesome.min.css'
import '@fortawesome/fontawesome-free/css/all.min.css'

createApp(App).use(createPinia()).use(router).mount('#app')