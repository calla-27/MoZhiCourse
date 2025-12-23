<template>
  <div id="app">
    <!-- 全局导航栏，只在需要的页面显示 -->
    <HeaderNav v-if="shouldShowNav" />
    <router-view />
    <!-- 全局页脚，只在需要的页面显示 -->
    <Footer v-if="shouldShowFooter" />
  </div>
</template>

<script>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import HeaderNav from '@/components/layout/HeaderNav.vue'
import Footer from '@/components/layout/Footer.vue'  // 导入页脚组件

export default {
  name: 'App',
  components: {
    HeaderNav,
    Footer  // 注册页脚组件
  },
  setup() {
    const route = useRoute()
    
    // 定义不需要显示导航栏的页面
    const noNavPages = ['/login', '/register']
    
    // 定义需要显示页脚的页面（只有这四个页面需要页脚）
    const footerPages = ['/', '/community', '/personal', '/teacher']
    
    // 计算是否应该显示导航栏
    const shouldShowNav = computed(() => {
      return !noNavPages.includes(route.path)
    })
    
    // 计算是否应该显示页脚
    const shouldShowFooter = computed(() => {
      // 检查当前路径是否以页脚页面开头
      return footerPages.some(page => route.path.startsWith(page))
    })
    
    return {
      shouldShowNav,
      shouldShowFooter
    }
  }
}
</script>

<style>
/* 全局样式 */
:root {
  --primary: #1a73e8;
  --primary-light: #e8f0fe;
  --secondary: #34a853;
  --warning: #f9ab00;
  --danger: #ea4335;
  --dark: #202124;
  --light: #f8f9fa;
  --gray: #5f6368;
  --border: #dadce0;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
}

body {
  background-color: var(--light);
  color: var(--dark);
  min-height: 100vh;
  /* 允许页面纵向滚动 */
  overflow-y: auto;
}

#app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* 确保页面内容不被导航栏遮挡 */
.search-results,
.community,
.course-detail,
.course-video,
.personal-center {
  padding-top: 20px;
}
</style>