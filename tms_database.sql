-- TMS (Training Management System) Database Schema
-- MySQL Syntax for TMS Project

-- Create database
CREATE DATABASE IF NOT EXISTS tms_db;
USE tms_db;

-- Roles table
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nik VARCHAR(20) NOT NULL UNIQUE,
    fullname VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255) NOT NULL,
    department VARCHAR(50),
    position VARCHAR(50),
    role_id INT,
    status ENUM('active', 'inactive') DEFAULT 'active',
    photo VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- Trainings table
CREATE TABLE trainings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    type ENUM('online', 'offline') NOT NULL,
    category VARCHAR(50),
    duration VARCHAR(50),
    venue VARCHAR(100),
    start_date DATE,
    end_date DATE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- User Trainings table (junction table for user-training relationships)
CREATE TABLE user_trainings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    training_id INT NOT NULL,
    status ENUM('enrolled', 'in_progress', 'completed', 'cancelled') DEFAULT 'enrolled',
    progress_percentage INT DEFAULT 0,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    pre_test_score DECIMAL(5,2) NULL,
    post_test_score DECIMAL(5,2) NULL,
    result_status ENUM('pass', 'fail', 'pending') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (training_id) REFERENCES trainings(id),
    UNIQUE KEY unique_user_training (user_id, training_id)
);

-- Schedules table
CREATE TABLE schedules (
    id INT PRIMARY KEY AUTO_INCREMENT,
    training_id INT NOT NULL,
    schedule_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    venue VARCHAR(100),
    trainer VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (training_id) REFERENCES trainings(id)
);

-- Attendance table
CREATE TABLE attendance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    training_id INT NOT NULL,
    schedule_id INT,
    attendance_date DATE NOT NULL,
    status ENUM('present', 'absent', 'late', 'excused') DEFAULT 'present',
    check_in_time TIME,
    check_out_time TIME,
    notes TEXT,
    recorded_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (training_id) REFERENCES trainings(id),
    FOREIGN KEY (schedule_id) REFERENCES schedules(id),
    FOREIGN KEY (recorded_by) REFERENCES users(id)
);

-- Evaluations table
CREATE TABLE evaluations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    training_id INT NOT NULL,
    evaluator_id INT,
    evaluation_date DATE NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    feedback TEXT,
    competencies TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (training_id) REFERENCES trainings(id),
    FOREIGN KEY (evaluator_id) REFERENCES users(id)
);

-- Competency table
CREATE TABLE competencies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Competencies table
CREATE TABLE user_competencies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    competency_id INT NOT NULL,
    level INT DEFAULT 1,
    achieved_date DATE,
    expiry_date DATE,
    status ENUM('active', 'expired', 'pending') DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (competency_id) REFERENCES competencies(id)
);

-- Reports table
CREATE TABLE reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    type VARCHAR(50),
    generated_by INT,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data JSON,
    FOREIGN KEY (generated_by) REFERENCES users(id)
);

-- Settings table
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    key_name VARCHAR(100) NOT NULL UNIQUE,
    value TEXT,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default roles
INSERT INTO roles (name, description) VALUES
('karyawan', 'Regular employee with access to training and personal data'),
('admin', 'Administrator with access to employee management and reports'),
('super admin', 'Super administrator with full system access');

-- Insert default settings
INSERT INTO settings (key_name, value, description) VALUES
('company_name', 'PT Training Indonesia', 'Company name for the system'),
('email_notification', 'enabled', 'Enable/disable email notifications');

-- Insert sample users
INSERT INTO users (nik, fullname, email, password, department, position, role_id, status) VALUES
('EMP001', 'Budi Santoso', 'budi@example.com', '$2b$10$hashedpassword', 'Production', 'Operator', 1, 'active'),
('EMP002', 'Siti Aminah', 'siti@example.com', '$2b$10$hashedpassword', 'HRD', 'Staff HR', 1, 'active'),
('ADM001', 'Admin User', 'admin@example.com', '$2b$10$hashedpassword', 'IT', 'System Admin', 2, 'active');

-- Insert sample trainings
INSERT INTO trainings (title, description, type, category, duration, venue, start_date, end_date, created_by) VALUES
('Digital Marketing', 'Pelatihan online untuk strategi pemasaran digital dan analitik', 'online', 'Marketing', '4 Weeks', 'Online Platform', '2026-05-15', '2026-06-15', 3),
('Communication Skills', 'Pelatihan untuk komunikasi efektif dan presentasi secara online', 'online', 'Soft Skills', '3 Weeks', 'Online Platform', '2026-05-20', '2026-06-10', 3),
('Leadership Workshop', 'Workshop tatap muka untuk kepemimpinan dan kerja tim', 'offline', 'Management', '2 Days', 'Room A', '2026-05-20', '2026-05-21', 3),
('Safety & K3', 'Pelatihan offline untuk kesehatan dan keselamatan kerja', 'offline', 'Safety', '1 Day', 'Room B', '2026-05-25', '2026-05-25', 3);

-- Insert sample user trainings
INSERT INTO user_trainings (user_id, training_id, status, progress_percentage, pre_test_score, post_test_score, result_status) VALUES
(1, 1, 'in_progress', 75, 85.00, NULL, 'pending'),
(1, 4, 'enrolled', 0, NULL, NULL, 'pending'),
(1, 3, 'completed', 100, 78.00, 92.00, 'pass'),
(2, 2, 'in_progress', 60, 88.00, NULL, 'pending'),
(2, 5, 'enrolled', 0, NULL, NULL, 'pending'),
(2, 6, 'completed', 100, 82.00, 95.00, 'pass');

-- Insert sample schedules
INSERT INTO schedules (training_id, schedule_date, start_time, end_time, venue, trainer) VALUES
(3, '2026-05-20', '09:00:00', '17:00:00', 'Room A', 'Dr. Leadership Expert'),
(4, '2026-05-25', '08:00:00', '16:00:00', 'Room B', 'Safety Specialist');

-- Insert sample competencies
INSERT INTO competencies (name, description, category) VALUES
('Digital Marketing', 'Knowledge of digital marketing strategies', 'Marketing'),
('Communication', 'Effective communication skills', 'Soft Skills'),
('Leadership', 'Leadership and team management', 'Management'),
('Safety Awareness', 'Knowledge of workplace safety', 'Safety');

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_trainings_type ON trainings(type);
CREATE INDEX idx_user_trainings_status ON user_trainings(status);
CREATE INDEX idx_attendance_date ON attendance(attendance_date);
CREATE INDEX idx_evaluations_date ON evaluations(evaluation_date);