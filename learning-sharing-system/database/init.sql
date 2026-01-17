-- 创建数据库
CREATE DATABASE IF NOT EXISTS learning_system 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_unicode_ci;

USE learning_system;

-- 用户表
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    wechat_openid VARCHAR(100) UNIQUE,
    wechat_unionid VARCHAR(100),
    nickname VARCHAR(100),
    avatar_url VARCHAR(500),
    user_type ENUM('admin', 'teacher', 'student') DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_openid (wechat_openid),
    INDEX idx_user_type (user_type)
);

-- 学习营表
CREATE TABLE camps (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    cover_image VARCHAR(500),
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_active (is_active)
);

-- 营成员关联表
CREATE TABLE camp_members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camp_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('teacher', 'student') NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_camp_user (camp_id, user_id),
    FOREIGN KEY (camp_id) REFERENCES camps(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_camp_id (camp_id),
    INDEX idx_user_id (user_id)
);

-- 老师布置作业表
CREATE TABLE teacher_assignments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camp_id INT NOT NULL,
    teacher_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    requirement TEXT,
    deadline DATETIME,
    total_points DECIMAL(5,2),
    attachment_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('active', 'draft', 'completed') DEFAULT 'active',
    FOREIGN KEY (camp_id) REFERENCES camps(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_camp (camp_id),
    INDEX idx_deadline (deadline)
);

-- 作业提交表
CREATE TABLE assignments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camp_id INT NOT NULL,
    student_id INT NOT NULL,
    teacher_assignment_id INT,
    title VARCHAR(200),
    content TEXT,
    score DECIMAL(5,2),
    status ENUM('submitted', 'reviewed', 'returned') DEFAULT 'submitted',
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (camp_id) REFERENCES camps(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_assignment_id) REFERENCES teacher_assignments(id) ON DELETE SET NULL,
    INDEX idx_camp_student (camp_id, student_id)
);

-- 作业文件表
CREATE TABLE assignment_files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    assignment_id INT NOT NULL,
    file_type ENUM('video', 'image', 'document', 'other'),
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(200),
    file_size INT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE
);

-- 评价表
CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    assignment_id INT NOT NULL,
    teacher_id INT NOT NULL,
    content TEXT NOT NULL,
    is_public_to_all BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 互动文件表
CREATE TABLE interaction_files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camp_id INT NOT NULL,
    uploader_id INT NOT NULL,
    file_type ENUM('video', 'image', 'document', 'other'),
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(200),
    description TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (camp_id) REFERENCES camps(id) ON DELETE CASCADE,
    FOREIGN KEY (uploader_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 消息通知表
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type ENUM('new_assignment', 'new_file', 'new_review', 'new_reply', 'system'),
    title VARCHAR(200),
    content TEXT,
    related_id INT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 插入测试数据
INSERT INTO users (wechat_openid, nickname, user_type) VALUES 
('admin_test', '系统管理员', 'admin'),
('teacher_test', '张老师', 'teacher'),
('student_test', '李学员', 'student'),
('student2_test', '王学员', 'student');

INSERT INTO camps (name, description, created_by, start_date, end_date) VALUES 
('Python入门营', '学习Python基础编程，从零开始掌握编程技能', 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY)),
('Web开发实战', '全栈开发实战课程，学习前后端开发', 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 60 DAY));

INSERT INTO camp_members (camp_id, user_id, role) VALUES 
(1, 2, 'teacher'),
(1, 3, 'student'),
(1, 4, 'student'),
(2, 2, 'teacher'),
(2, 3, 'student');

INSERT INTO teacher_assignments (camp_id, teacher_id, title, description, requirement, deadline, total_points) VALUES 
(1, 2, '第一周作业：Python基础', '完成以下Python基础练习题', '1. 编写一个计算器程序\n2. 实现冒泡排序\n3. 读写文件操作', DATE_ADD(NOW(), INTERVAL 7 DAY), 100),
(1, 2, '第二周作业：数据结构', '学习并实现常用数据结构', '1. 实现栈和队列\n2. 实现链表\n3. 二叉树遍历', DATE_ADD(NOW(), INTERVAL 14 DAY), 100);

INSERT INTO assignments (camp_id, student_id, teacher_assignment_id, title, content, status) VALUES 
(1, 3, 1, '我的Python作业', '我已经完成了所有的练习题，这是我的代码...', 'submitted'),
(1, 4, 1, '王学员的作业', '这是我对第一周作业的解答...', 'reviewed');

INSERT INTO reviews (assignment_id, teacher_id, content, is_public_to_all) VALUES 
(2, 2, '作业完成得很好，代码结构清晰，继续加油！', true);

-- 显示创建的表
SHOW TABLES;

-- 显示各表数据量
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'camps', COUNT(*) FROM camps
UNION ALL
SELECT 'camp_members', COUNT(*) FROM camp_members
UNION ALL
SELECT 'teacher_assignments', COUNT(*) FROM teacher_assignments
UNION ALL
SELECT 'assignments', COUNT(*) FROM assignments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews;