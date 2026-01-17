import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ConfigProvider, Layout, message } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import 'antd/dist/reset.css';

import LoginPage from './pages/LoginPage';
import AdminDashboard from './pages/admin/Dashboard';
import TeacherDashboard from './pages/teacher/Dashboard';
import StudentDashboard from './pages/student/Dashboard';

const { Content } = Layout;

function App() {
  const [user, setUser] = useState(() => {
    const saved = localStorage.getItem('user');
    return saved ? JSON.parse(saved) : null;
  });

  const handleLogin = (userData) => {
    setUser(userData);
    localStorage.setItem('user', JSON.stringify(userData));
    localStorage.setItem('token', userData.token);
    message.success('登录成功！');
  };

  const handleLogout = () => {
    setUser(null);
    localStorage.removeItem('user');
    localStorage.removeItem('token');
    message.success('已退出登录');
  };

  return (
    <ConfigProvider locale={zhCN}>
      <Router>
        <Layout style={{ minHeight: '100vh' }}>
          <Content>
            <Routes>
              {/* 登录页面 */}
              <Route path="/login" element={
                user ? <Navigate to={`/${user.userType}`} /> : 
                <LoginPage onLogin={handleLogin} />
              } />
              
              {/* 管理员页面 */}
              <Route path="/admin/*" element={
                user?.userType === 'admin' ? 
                <AdminDashboard user={user} onLogout={handleLogout} /> : 
                <Navigate to="/login" />
              } />
              
              {/* 老师页面 */}
              <Route path="/teacher/*" element={
                user?.userType === 'teacher' ? 
                <TeacherDashboard user={user} onLogout={handleLogout} /> : 
                <Navigate to="/login" />
              } />
              
              {/* 学员页面 */}
              <Route path="/student/*" element={
                user?.userType === 'student' ? 
                <StudentDashboard user={user} onLogout={handleLogout} /> : 
                <Navigate to="/login" />
              } />
              
              {/* 默认重定向 */}
              <Route path="/" element={<Navigate to="/login" />} />
              <Route path="*" element={<Navigate to="/login" />} />
            </Routes>
          </Content>
        </Layout>
      </Router>
    </ConfigProvider>
  );
}

export default App;