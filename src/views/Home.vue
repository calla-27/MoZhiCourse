<template>
  <div class="home">
    <!-- 搜索区域 -->
    <section class="search-section">
      <div class="search-container">
        <h1>探索优质在线课程</h1>
        <p>AI驱动的个性化学习推荐，助你快速成长</p>
        <div class="search-box">
          <input
            type="text"
            class="search-input"
            placeholder="搜索课程、技能或知识点..."
            v-model="searchKeyword"
            @keyup.enter="handleSearch"
          />
          <button class="search-btn" @click="handleSearch">
            <i class="fas fa-search"></i>
          </button>
        </div>
      </div>
    </section>

    <div class="container">
      <!-- 加载状态 -->
      <div v-if="courseStore.loading" class="loading-section">
        <div class="loading-spinner"></div>
        <p>加载中...</p>
      </div>
      <!-- 课程分类 - 始终显示，即使没有数据也显示空状态 -->
      <section class="module-section">
        <div class="module-header">
          <h2 class="section-title">
            <i class="fas fa-th-large"></i> 课程分类
          </h2>
          <a href="#" class="view-all">查看全部</a>
        </div>
        <div class="categories-grid" v-if="categories.length > 0">
          <div
            v-for="category in categories"
            :key="category.category_id"
            class="category-card"
            @click="handleCategoryClick(category.category_id)"
          >
            <div class="category-icon">
              <i :class="category.category_icon || 'fas fa-folder'"></i>
            </div>
            <h3 class="category-title">{{ category.category_name }}</h3>
            <p class="category-count">{{ category.course_count || 0 }} 课程</p>
          </div>
        </div>
        <div v-else class="empty-state">
          <p>暂无分类数据</p>
        </div>
      </section>

      <!-- 课程筛选器 -->
      <section class="module-section">
        <div class="filters">
          <button
            v-for="filter in filters"
            :key="filter.id"
            class="filter-btn"
            :class="{ active: activeFilter === filter.id }"
            @click="handleFilterClick(filter.id)"
          >
            {{ filter.name }}
          </button>
        </div>
      </section>

      <!-- 明星讲师 - 始终显示 -->
      <section class="module-section">
        <div class="module-header">
          <h2 class="section-title">
            <i class="fas fa-user-tie"></i> 明星讲师
          </h2>
          <a href="#" class="view-all">查看全部</a>
        </div>
        <div class="instructors-grid" v-if="instructors.length > 0">
          <div
            v-for="instructor in instructors"
            :key="instructor.user_id"
            class="instructor-card"
          >
            <div class="instructor-avatar">
              {{ getAvatarText(instructor.user_name) }}
            </div>
            <div class="instructor-info">
              <h3>{{ instructor.user_name }}</h3>
              <p>{{ instructor.occupation }}</p>
            </div>
          </div>
        </div>
        <div v-else class="empty-state">
          <p>暂无讲师信息</p>
        </div>
      </section>

      <!-- 推荐课程 - 始终显示 -->
      <section class="module-section">
        <div class="module-header">
          <h2 class="section-title"><i class="fas fa-fire"></i> 为你推荐</h2>
          <a href="#" class="view-all">查看全部</a>
        </div>
        <div class="courses-grid" v-if="recommendedCourses.length > 0">
          <div
            v-for="course in recommendedCourses"
            :key="course.course_id"
            @click="handleCourseClick(course)"
            style="cursor: pointer;"
          >
            <CourseCard
              :course="formatCourseData(course)"
            />
          </div>
        </div>
        <div v-else class="empty-state">
          <p>暂无推荐课程</p>
        </div>
      </section>

      <!-- 热门课程 - 始终显示 -->
      <section class="module-section">
        <div class="module-header">
          <h2 class="section-title">
            <i class="fas fa-chart-line"></i> 热门课程
          </h2>
          <a href="#" class="view-all">查看全部</a>
        </div>
        <div class="courses-grid" v-if="popularCourses.length > 0">
          <div
            v-for="course in popularCourses"
            :key="course.course_id"
            @click="handleCourseClick(course)"
            style="cursor: pointer;"
          >
            <CourseCard
              :course="formatCourseData(course)"
            />
          </div>
        </div>
        <div v-else class="empty-state">
          <p>暂无热门课程</p>
        </div>
      </section>

      <!-- 新上线课程 - 始终显示 -->
      <section class="module-section">
        <div class="module-header">
          <h2 class="section-title">
            <i class="fas fa-rocket"></i> 新上线课程
          </h2>
          <a href="#" class="view-all">查看全部</a>
        </div>
        <div class="courses-grid" v-if="newCourses.length > 0">
          <div
            v-for="course in newCourses"
            :key="course.course_id"
            @click="handleCourseClick(course)"
            style="cursor: pointer;"
          >
            <CourseCard
              :course="formatCourseData(course)"
            />
          </div>
        </div>
        <div v-else class="empty-state">
          <p>暂无新课程</p>
        </div>
      </section>

      <!-- 空状态 -->
      <div
        v-if="!courseStore.loading && categories.length === 0"
        class="empty-state"
      >
        <p>暂无数据</p>
      </div>
    </div>
    <div class="data-analysis-section" style="margin: 40px 0; padding: 0 20px">
      <h2 style="text-align: center; margin-bottom: 30px; color: #303133">
        我的学习分析
      </h2>

      <div
        class="charts-container"
        style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px"
      >
        <div
          class="chart-card"
          style="
            background: white;
            padding: 24px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
          "
        >
          <LearningStyleChart />
        </div>

        <div
          class="chart-card"
          style="
            background: white;
            padding: 24px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
          "
        >
          <StudyTrendChart />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import LearningStyleChart from "@/components/charts/LearningStyleChart.vue";
import StudyTrendChart from "@/components/charts/StudyTrendChart.vue";

import { ref, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import { useCourseStore } from "@/stores/course";
import CourseCard from "@/components/course/CourseCard.vue";
import { trackStudySession } from '@/utils/tracking';

const router = useRouter();
const courseStore = useCourseStore();

const searchKeyword = ref("");
const activeFilter = ref("all");

// 使用计算属性获取store中的数据，确保是数组
const categories = computed(() =>
  Array.isArray(courseStore.categories) ? courseStore.categories : []
);
const instructors = computed(() =>
  Array.isArray(courseStore.instructors) ? courseStore.instructors : []
);
const recommendedCourses = computed(() =>
  Array.isArray(courseStore.recommendedCourses)
    ? courseStore.recommendedCourses
    : []
);
const popularCourses = computed(() =>
  Array.isArray(courseStore.popularCourses) ? courseStore.popularCourses : []
);
const newCourses = computed(() =>
  Array.isArray(courseStore.newCourses) ? courseStore.newCourses : []
);

// 筛选器数据 - 添加安全检查
const filters = computed(() => {
  const catList = Array.isArray(categories.value) ? categories.value : [];
  return [
    { id: "all", name: "全部" },
    ...catList.map((cat) => ({
      id: cat.category_id || cat.id,
      name: cat.category_name || cat.name,
    })),
  ];
});

onMounted(() => {
  trackStudySession.pageView('home')
})

onMounted(async () => {
  try {
    courseStore.loading = true;

    // 使用后端实际存在的接口
    await Promise.all([
      courseStore.fetchRecommendedCourses(6),
      courseStore.fetchPopularCourses(6),
      courseStore.fetchNewCourses(6),
      courseStore.fetchCategories(),
      courseStore.fetchInstructors(4),
    ]);
  } catch (error) {
    console.error("首页数据加载失败:", error);
  } finally {
    courseStore.loading = false;
  }
});

// 课程点击事件 - 添加埋点
const handleCourseClick = (course) => {
  // 课程点击埋点
  trackStudySession.courseClick(course.course_id, course.title)
  
  // 跳转到课程详情页
  router.push(`/course/${course.course_id}`)
}

// 搜索处理
const handleSearch = () => {
  if (searchKeyword.value.trim()) {
    router.push({
      path: "/search",
      query: { q: searchKeyword.value.trim() },
    });
  }
};

// 分类点击
const handleCategoryClick = (categoryId) => {
  activeFilter.value = categoryId;
  handleFilterClick(categoryId);
};

// 筛选处理
const handleFilterClick = async (filterId) => {
  activeFilter.value = filterId;
  try {
    if (filterId === "all") {
      await courseStore.fetchCourses();
    } else {
      await courseStore.fetchCourses({ category: filterId });
    }
    // 更新推荐课程为筛选结果
    courseStore.recommendedCourses = courseStore.courses;
  } catch (error) {
    console.error("筛选课程失败:", error);
  }
};

// 工具函数：获取头像文字
const getAvatarText = (name) => {
  return name ? name.charAt(0) : "用";
};

// 格式化课程数据，适配CourseCard组件
const formatCourseData = (course) => {
  return {
    id: course.course_id,
    title: course.title,
    description: course.description,
    instructor: course.instructor || course.teacherName,
    students: formatStudentCount(course.studentCount),
    rating: course.rating,
    difficulty: course.difficulty || "初级",
    image: course.coverImage || getDefaultGradient(course.course_id),
  };
};

// 格式化学生数量
const formatStudentCount = (count) => {
  if (!count) return "0";
  if (count >= 1000) {
    return (count / 1000).toFixed(1) + "k";
  }
  return count.toString();
};

// 默认渐变背景
const getDefaultGradient = (id) => {
  const gradients = [
    "linear-gradient(135deg, #667eea, #764ba2)",
    "linear-gradient(135deg, #f093fb, #f5576c)",
    "linear-gradient(135deg, #4facfe, #00f2fe)",
    "linear-gradient(135deg, #43e97b, #38f9d7)",
    "linear-gradient(135deg, #fa709a, #fee140)",
  ];
  return gradients[id % gradients.length];
};
</script>

<style scoped>
/* 原有的样式保持不变，只添加加载状态样式 */

.loading-section {
  text-align: center;
  padding: 60px 0;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #1a73e8;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.empty-state {
  text-align: center;
  padding: 60px 0;
  color: #5f6368;
}

/* 原有的其他样式保持不变 */
.home {
  min-height: 100vh;
}

.search-section {
  background: linear-gradient(135deg, #1a73e8, #6c8ef5);
  color: white;
  padding: 60px 0;
  margin-bottom: 40px;
}

.search-container {
  text-align: center;
  max-width: 800px;
  margin: 0 auto;
  padding: 0 20px;
}

.search-container h1 {
  font-size: 2.5rem;
  margin-bottom: 20px;
}

.search-container p {
  font-size: 1.1rem;
  margin-bottom: 30px;
  opacity: 0.9;
}

.search-box {
  max-width: 600px;
  margin: 0 auto;
  position: relative;
}

.search-input {
  width: 100%;
  padding: 15px 50px 15px 20px;
  border: none;
  border-radius: 30px;
  font-size: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.search-btn {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  background: #1a73e8;
  border: none;
  color: white;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.module-section {
  margin-bottom: 50px;
}

.module-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-title {
  font-size: 1.5rem;
  color: #202124;
  display: flex;
  align-items: center;
  gap: 10px;
}

.view-all {
  color: #1a73e8;
  text-decoration: none;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 5px;
}

.categories-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
}

.category-card {
  background: white;
  border-radius: 12px;
  padding: 25px 20px;
  text-align: center;
  box-shadow: 0 3px 15px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
}

.category-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.category-icon {
  font-size: 2.5rem;
  margin-bottom: 15px;
  color: #1a73e8;
}

.category-title {
  font-size: 1.1rem;
  font-weight: 600;
  margin-bottom: 5px;
}

.category-count {
  color: #5f6368;
  font-size: 0.9rem;
}

.instructors-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 25px;
}

.instructor-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  box-shadow: 0 3px 15px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
}

.instructor-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.instructor-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: #1a73e8;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 1.2rem;
}

.instructor-info h3 {
  font-size: 1.1rem;
  margin-bottom: 5px;
}

.instructor-info p {
  color: #5f6368;
  font-size: 0.9rem;
}

.courses-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 25px;
}

.filters {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: center;
}

.filter-btn {
  padding: 10px 20px;
  border: 1px solid #dadce0;
  background: white;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.9rem;
  white-space: nowrap;
}

.filter-btn.active,
.filter-btn:hover {
  background: #1a73e8;
  color: white;
  border-color: #1a73e8;
}

@media (max-width: 768px) {
  .search-container h1 {
    font-size: 2rem;
  }

  .categories-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .instructors-grid,
  .courses-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .charts-container {
    grid-template-columns: 1fr !important;
  }
}
</style>