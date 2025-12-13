// 测试课程详情API
const fetch = require('node-fetch');

async function testCourseAPI() {
  try {
    // 测试获取课程详情
    console.log('🔍 测试课程详情API...');
    
    // 假设课程ID为1，你可以根据实际情况修改
    const courseId = 1;
    const response = await fetch(`http://localhost:4000/api/courses/${courseId}`);
    const data = await response.json();
    
    console.log('📚 API响应状态:', response.status);
    console.log('📚 API响应数据:', JSON.stringify(data, null, 2));
    
    if (data.success && data.data) {
      console.log('✅ 课程数据结构:');
      console.log('- course_name:', data.data.course_name);
      console.log('- course_desc:', data.data.course_desc);
      console.log('- difficulty_level:', data.data.difficulty_level);
      console.log('- category_id:', data.data.category_id);
      console.log('- is_online:', data.data.is_online);
    } else {
      console.log('❌ API调用失败或无数据');
    }
    
  } catch (error) {
    console.error('❌ 测试失败:', error.message);
  }
}

testCourseAPI();