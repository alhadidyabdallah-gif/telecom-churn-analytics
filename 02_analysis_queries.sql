-- Telecom Churn Analytics - Analytical Queries
-- Author: Abdullah Alahidy

USE telecom_db;

-- 1. Overall Churn Rate
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active_customers,
    ROUND(SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    ROUND(SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS retention_rate_pct
FROM customers;

-- 2. Churn Rate by Plan Type
SELECT 
    p.plan_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN c.status = 'Churned' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN c.status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers c
JOIN plans p ON c.plan_id = p.plan_id
GROUP BY p.plan_type
ORDER BY churn_rate_pct DESC;

-- 3. Churn Rate by City
SELECT 
    city,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY city
ORDER BY churn_rate_pct DESC;

-- 4. ARPU (Average Revenue Per User)
SELECT 
    p.plan_type,
    COUNT(DISTINCT b.customer_id) AS num_customers,
    ROUND(SUM(b.amount), 2) AS total_revenue,
    ROUND(SUM(b.amount) / COUNT(DISTINCT b.customer_id), 2) AS arpu
FROM bills b
JOIN customers c ON b.customer_id = c.customer_id
JOIN plans p ON c.plan_id = p.plan_id
GROUP BY p.plan_type
ORDER BY arpu DESC;

-- 5. Cohort Analysis (Retention by Signup Month)
SELECT 
    DATE_FORMAT(signup_date, '%Y-%m') AS cohort_month,
    COUNT(*) AS total_signups,
    SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS still_active,
    SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS retention_pct
FROM customers
GROUP BY DATE_FORMAT(signup_date, '%Y-%m')
ORDER BY cohort_month;

-- 6. Monthly Revenue Trend
SELECT 
    DATE_FORMAT(bill_date, '%Y-%m') AS month,
    COUNT(*) AS num_bills,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(AVG(amount), 2) AS avg_bill,
    SUM(CASE WHEN late_payment = 'Yes' THEN 1 ELSE 0 END) AS late_payments
FROM bills
GROUP BY DATE_FORMAT(bill_date, '%Y-%m')
ORDER BY month;

-- 7. Top 10 Customers by Revenue
SELECT 
    c.customer_name, c.city, p.plan_name,
    COUNT(b.bill_id) AS num_bills,
    ROUND(SUM(b.amount), 2) AS total_revenue
FROM bills b
JOIN customers c ON b.customer_id = c.customer_id
JOIN plans p ON c.plan_id = p.plan_id
GROUP BY c.customer_id, c.customer_name, c.city, p.plan_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 8. At-Risk Customers (Late Payments + Complaints)
SELECT 
    c.customer_id, c.customer_name, c.city, p.plan_name,
    COUNT(DISTINCT b.bill_id) AS total_bills,
    SUM(CASE WHEN b.late_payment = 'Yes' THEN 1 ELSE 0 END) AS late_payments,
    COUNT(DISTINCT cp.complaint_id) AS complaints,
    ROUND(SUM(b.amount), 2) AS total_revenue
FROM customers c
JOIN plans p ON c.plan_id = p.plan_id
LEFT JOIN bills b ON c.customer_id = b.customer_id
LEFT JOIN complaints cp ON c.customer_id = cp.customer_id
WHERE c.status = 'Active'
GROUP BY c.customer_id, c.customer_name, c.city, p.plan_name
HAVING late_payments > 2 OR complaints > 2
ORDER BY late_payments DESC, complaints DESC
LIMIT 30;
