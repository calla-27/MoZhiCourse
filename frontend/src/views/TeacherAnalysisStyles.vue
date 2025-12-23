<!-- 这个文件包含多种统计卡片样式供你选择 -->
<style>
/* 样式方案一：简约现代风格（当前使用的） */
.stat-card-style1 {
  background: #ffffff;
  padding: 28px 24px;
  border-radius: 12px;
  border: 1px solid #e8e8e8;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  transition: all 0.2s ease;
  position: relative;
  overflow: hidden;
}

.stat-card-style1::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
  background: #4a6cf7;
  transition: all 0.3s ease;
}

.stat-card-style1:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.08);
  border-color: #d9d9d9;
}

/* 样式方案二：卡片阴影风格 */
.stat-card-style2 {
  background: #ffffff;
  padding: 32px 28px;
  border-radius: 16px;
  box-shadow: 
    0 4px 12px rgba(0,0,0,0.05),
    0 0 0 1px rgba(0,0,0,0.02);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  border-top: 3px solid transparent;
}

.stat-card-style2:nth-child(1) { border-top-color: #667eea; }
.stat-card-style2:nth-child(2) { border-top-color: #764ba2; }
.stat-card-style2:nth-child(3) { border-top-color: #f093fb; }
.stat-card-style2:nth-child(4) { border-top-color: #4facfe; }

.stat-card-style2:hover {
  transform: translateY(-4px);
  box-shadow: 
    0 12px 32px rgba(0,0,0,0.1),
    0 0 0 1px rgba(0,0,0,0.03);
}

/* 样式方案三：渐变背景风格 */
.stat-card-style3 {
  padding: 30px 26px;
  border-radius: 20px;
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
  color: white;
  border: none;
}

.stat-card-style3:nth-child(1) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
.stat-card-style3:nth-child(2) {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}
.stat-card-style3:nth-child(3) {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}
.stat-card-style3:nth-child(4) {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.stat-card-style3::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255,255,255,0.1);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.stat-card-style3:hover::before {
  opacity: 1;
}

.stat-card-style3:hover {
  transform: translateY(-6px) scale(1.02);
  box-shadow: 0 20px 40px rgba(0,0,0,0.2);
}

.stat-card-style3 .stat-label {
  color: rgba(255,255,255,0.9);
}

.stat-card-style3 .stat-value {
  color: white;
}

.stat-card-style3 .stat-trend {
  color: rgba(255,255,255,0.8);
}

/* 样式方案四：极简线条风格 */
.stat-card-style4 {
  background: #fafafa;
  padding: 24px 20px;
  border-radius: 8px;
  border: 2px solid #f0f0f0;
  transition: all 0.2s ease;
  position: relative;
}

.stat-card-style4:hover {
  background: #ffffff;
  border-color: #d9d9d9;
  transform: translateY(-1px);
}

.stat-card-style4 .stat-label {
  color: #595959;
  font-size: 13px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-weight: 600;
}

.stat-card-style4 .stat-value {
  font-size: 28px;
  font-weight: 800;
  color: #262626;
  font-family: 'SF Mono', 'Monaco', 'Consolas', monospace;
}

/* 样式方案五：玻璃拟态风格 */
.stat-card-style5 {
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.18);
  padding: 30px 25px;
  border-radius: 15px;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  transition: all 0.3s ease;
}

.stat-card-style5:hover {
  background: rgba(255, 255, 255, 0.35);
  transform: translateY(-3px);
  box-shadow: 0 15px 35px 0 rgba(31, 38, 135, 0.4);
}

.stat-card-style5 .stat-label {
  color: #4a5568;
  font-weight: 600;
}

.stat-card-style5 .stat-value {
  color: #2d3748;
  text-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

/* 样式方案六：数据仪表盘风格 */
.stat-card-style6 {
  background: #ffffff;
  padding: 25px;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  position: relative;
  transition: all 0.2s ease;
}

.stat-card-style6::before {
  content: '';
  position: absolute;
  top: 12px;
  right: 12px;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #10b981;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.stat-card-style6:hover {
  border-color: #cbd5e0;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.stat-card-style6 .stat-label {
  color: #64748b;
  font-size: 12px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 12px;
}

.stat-card-style6 .stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 8px;
  font-family: system-ui, -apple-system, sans-serif;
}

.stat-card-style6 .stat-trend {
  font-size: 12px;
  color: #10b981;
  font-weight: 600;
  background: #ecfdf5;
  padding: 4px 8px;
  border-radius: 12px;
  display: inline-block;
}
</style>