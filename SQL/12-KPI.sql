                                     -- KEY PERFORMANCE INDICATOR:

                                     -- Headcount Analysis: 


-- Headcount by Department:
SELECT d.department, COUNT(e.employee_id) AS headcount
FROM dim_employee e
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department
ORDER BY headcount DESC;
-- Headcount by Location
SELECT l.city, COUNT(e.employee_id) AS headcount
FROM dim_employee e
JOIN dim_location l ON e.location_id = l.location_id
GROUP BY l.city
ORDER BY headcount DESC;
-- Insight: Quickly identify large departments or locations, spot imbalances, and support workforce planning.

                                   -- Average Salary & Compensation Metrics:

-- Average Salary by Department:
SELECT d.department, AVG(f.salary_usd) AS avg_salary
FROM fact_salary f
JOIN dim_employee e ON f.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department
ORDER BY avg_salary DESC;
-- Salary Growth over Time
SELECT f.year, AVG(f.salary_usd) AS avg_salary
FROM fact_salary f
GROUP BY f.year
ORDER BY f.year;
-- Salary by Seniority Level
SELECT f.seniority_level, AVG(f.salary_usd) AS avg_salary
FROM fact_salary f
GROUP BY f.seniority_level
ORDER BY FIELD(f.seniority_level, 'Intern','Junior','Mid','Senior','Lead','Manager','Director','VP','C-level');
-- Insight: Detect compensation gaps, monitor growth trends, identify departments or levels needing attention.

                                           -- Promotions & Career Progression:
-- Promotions per Department:
SELECT d.department, COUNT(p.employee_id) AS promotions_count
FROM fact_promotion p
JOIN dim_employee e ON p.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department
ORDER BY promotions_count DESC;
-- Promotion Rate by Seniority
SELECT 
    COALESCE(fp.to_level, 'Unknown') AS current_level, 
    COUNT(fp.employee_id) AS promotion_count
FROM fact_promotion fp
LEFT JOIN (
    SELECT employee_id, MAX(promotion_date) AS last_promo_date
    FROM fact_promotion
    GROUP BY employee_id
) lp ON fp.employee_id = lp.employee_id AND fp.promotion_date = lp.last_promo_date
GROUP BY current_level
ORDER BY promotion_count DESC;
-- Average Time Between Promotions
SELECT e.employee_id, e.name,
       MIN(p.promotion_date) AS first_promo,
       MAX(p.promotion_date) AS last_promo,
       DATEDIFF(MAX(p.promotion_date), MIN(p.promotion_date)) / NULLIF(COUNT(p.promotion_date)-1,0) AS avg_days_between_promotions
FROM fact_promotion p
JOIN dim_employee e ON p.employee_id = e.employee_id
GROUP BY e.employee_id, e.name;
-- Insight: Identify top-performing departments, assess career progression speed, highlight employees with rapid growth.

                                -- Employee Satisfaction & Performance:

-- Average Performance by Department
SELECT d.department, AVG(f.performance_score) AS avg_performance
FROM fact_performance f
JOIN dim_employee e ON f.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department
ORDER BY avg_performance DESC;
-- Average Satisfaction by Location
SELECT l.city, AVG(f.satisfaction_score) AS avg_satisfaction
FROM fact_performance f
JOIN dim_employee e ON f.employee_id = e.employee_id
JOIN dim_location l ON e.location_id = l.location_id
GROUP BY l.city
ORDER BY avg_satisfaction DESC;
-- Performance vs Satisfaction Correlation
SELECT f.performance_score, f.satisfaction_score, COUNT(*) AS employee_count
FROM fact_performance f
GROUP BY f.performance_score, f.satisfaction_score
ORDER BY employee_count DESC;
-- Detect high performers with low satisfaction → risk of attrition.Detect low performers with high satisfaction → coaching opportunity.


                                -- Organizational Hierarchy KPIs:
 
 -- Direct Reports per Manager
SELECT m.name AS manager_name, COUNT(e.employee_id) AS direct_reports
FROM dim_employee e
JOIN dim_employee m ON e.manager_id = m.employee_id
GROUP BY m.employee_id, m.name
ORDER BY direct_reports DESC;
-- Department Manager Load
SELECT d.department, m.name AS manager_name, COUNT(e.employee_id) AS reports_count
FROM dim_employee e
JOIN dim_employee m ON e.manager_id = m.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department, m.employee_id, m.name
ORDER BY d.department, reports_count DESC;



                               -- validate accuracy & business sense:
-- Headcount Analysis:
-- Headcount by Department
SELECT d.department, COUNT(e.employee_id) AS headcount
FROM dim_employee e
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department
ORDER BY headcount DESC;
SELECT COUNT(*) AS total_employees FROM dim_employee;
-- Headcount by Location
SELECT l.city, COUNT(e.employee_id) AS headcount
FROM dim_employee e
JOIN dim_location l ON e.location_id = l.location_id
GROUP BY l.city
ORDER BY headcount DESC;
-- Average Salary & Compensation Metrics: 
-- Average Salary by Department
SELECT d.department, AVG(f.salary_usd) AS avg_salary
FROM fact_salary f
JOIN dim_employee e ON f.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department
ORDER BY avg_salary DESC;
SELECT d.department, MIN(f.salary_usd), MAX(f.salary_usd) FROM fact_salary f
JOIN dim_employee e ON f.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department;
-- Salary Growth Over Time
SELECT f.year, AVG(f.salary_usd) AS avg_salary
FROM fact_salary f
-- Salary by Seniority Level
SELECT f.seniority_level, AVG(f.salary_usd) AS avg_salary
FROM fact_salary f
GROUP BY f.seniority_level
ORDER BY FIELD(f.seniority_level, 'Intern','Junior','Mid','Senior','Lead','Manager','Director','VP','C-level');
-- Promotions & Career Progression:
-- Promotions per Department
SELECT d.department, COUNT(p.employee_id) AS promotions_count
FROM fact_promotion p
JOIN dim_employee e ON p.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department
ORDER BY promotions_count DESC;
-- Promotion Rate by Seniority
SELECT COALESCE(fp.to_level, 'Unknown') AS current_level, COUNT(fp.employee_id) AS promotion_count
FROM fact_promotion fp
LEFT JOIN (
    SELECT employee_id, MAX(promotion_date) AS last_promo_date
    FROM fact_promotion
    GROUP BY employee_id
) lp ON fp.employee_id = lp.employee_id AND fp.promotion_date = lp.last_promo_date
GROUP BY current_level
ORDER BY promotion_count DESC;
-- Average Time Between Promotions
SELECT e.employee_id, e.name,
       MIN(p.promotion_date) AS first_promo,
       MAX(p.promotion_date) AS last_promo,
       DATEDIFF(MAX(p.promotion_date), MIN(p.promotion_date)) / NULLIF(COUNT(p.promotion_date)-1,0) AS avg_days_between_promotions
FROM fact_promotion p
JOIN dim_employee e ON p.employee_id = e.employee_id
GROUP BY e.employee_id, e.name;
-- Employee Satisfaction & Performance:
-- Average Performance by Department
SELECT d.department, AVG(f.performance_score) AS avg_performance
FROM fact_performance f
JOIN dim_employee e ON f.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department
ORDER BY avg_performance DESC;
-- Average Satisfaction by Location
SELECT l.city, AVG(f.satisfaction_score) AS avg_satisfaction
FROM fact_performance f
JOIN dim_employee e ON f.employee_id = e.employee_id
JOIN dim_location l ON e.location_id = l.location_id
GROUP BY l.city
ORDER BY avg_satisfaction DESC;
-- Performance vs Satisfaction Correlation
SELECT f.performance_score, f.satisfaction_score, COUNT(*) AS employee_count
FROM fact_performance f
GROUP BY f.performance_score, f.satisfaction_score
ORDER BY employee_count DESC;
-- Organizational Hierarchy KPIs:
-- Direct Reports per Manager
SELECT m.name AS manager_name, COUNT(e.employee_id) AS direct_reports
FROM dim_employee e
JOIN dim_employee m ON e.manager_id = m.employee_id
GROUP BY m.employee_id, m.name
ORDER BY direct_reports DESC;
-- Department Manager Load
SELECT d.department, m.name AS manager_name, COUNT(e.employee_id) AS reports_count
FROM dim_employee e
JOIN dim_employee m ON e.manager_id = m.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department, m.employee_id, m.name
ORDER BY d.department, reports_count DESC;


































