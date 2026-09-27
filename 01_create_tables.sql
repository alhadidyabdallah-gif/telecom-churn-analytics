-- Telecom Churn Analytics - Database Schema
-- Author: Abdullah Alahidy
-- Date: 2026

USE telecom_db;

-- 1. جدول العملاء
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    city VARCHAR(50),
    signup_date DATE,
    plan_id INT,
    status VARCHAR(20),
    churn_date DATE NULL
) ENGINE=InnoDB;

-- 2. جدول الباقات
CREATE TABLE plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(50),
    plan_type VARCHAR(20),
    monthly_fee DECIMAL(10,2),
    data_limit_gb INT,
    call_minutes INT
) ENGINE=InnoDB;

-- 3. جدول الاستخدام الشهري
CREATE TABLE usage_data (
    usage_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    month_date DATE,
    data_used_gb DECIMAL(10,2),
    call_minutes_used INT,
    sms_count INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

-- 4. جدول الفواتير
CREATE TABLE bills (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    bill_date DATE,
    amount DECIMAL(10,2),
    paid VARCHAR(5),
    late_payment VARCHAR(5),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

-- 5. جدول الشكاوى
CREATE TABLE complaints (
    complaint_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    complaint_date DATE,
    complaint_type VARCHAR(50),
    resolved VARCHAR(5),
    resolution_days INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;
