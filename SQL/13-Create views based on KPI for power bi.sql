                                   -- CREATE VIEWS BASED ON KPI FOR POWER BI :
                                   
                                        -- Headcount Views:
                                        
                                        
CREATE OR REPLACE VIEW vw_headcount_department AS
SELECT d.department, COUNT(e.employee_id) AS headcount
FROM dim_employee e
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department;

-- View: Headcount by Location
CREATE OR REPLACE VIEW vw_headcount_location AS
SELECT l.city, COUNT(e.employee_id) AS headcount
FROM dim_employee e
JOIN dim_location l ON e.location_id = l.location_id
GROUP BY l.city;

                                         -- Salary & Compensation Views:
-- View: Average Salary by Department
CREATE OR REPLACE VIEW vw_avg_salary_department AS
SELECT d.department,
       AVG(f.salary_usd) AS avg_salary,
       MIN(f.salary_usd) AS min_salary,
       MAX(f.salary_usd) AS max_salary
FROM fact_salary f
JOIN dim_employee e ON f.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department;

-- View: Salary Growth Over Time
CREATE OR REPLACE VIEW vw_salary_growth AS
SELECT f.year, AVG(f.salary_usd) AS avg_salary
FROM fact_salary f
GROUP BY f.year
ORDER BY f.year;

-- View: Salary by Seniority Level
CREATE OR REPLACE VIEW vw_salary_seniority AS
SELECT f.seniority_level, AVG(f.salary_usd) AS avg_salary
FROM fact_salary f
GROUP BY f.seniority_level
ORDER BY FIELD(f.seniority_level, 'Intern','Junior','Mid','Senior','Lead','Manager','Director','VP','C-level');

                                           -- Promotions & Career Progression Views:

-- View: Promotions per Department
CREATE OR REPLACE VIEW vw_promotions_department AS
SELECT d.department, COUNT(p.employee_id) AS promotions_count
FROM fact_promotion p
JOIN dim_employee e ON p.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department;

-- View: Latest Promotion by Level
CREATE OR REPLACE VIEW vw_promotion_rate_level AS
SELECT COALESCE(fp.to_level, 'Unknown') AS current_level, COUNT(fp.employee_id) AS promotion_count
FROM fact_promotion fp
LEFT JOIN (
    SELECT employee_id, MAX(promotion_date) AS last_promo_date
    FROM fact_promotion
    GROUP BY employee_id
) lp ON fp.employee_id = lp.employee_id AND fp.promotion_date = lp.last_promo_date
GROUP BY current_level;

-- View: Avg Days Between Promotions per Employee
CREATE OR REPLACE VIEW vw_avg_days_between_promotions AS
SELECT e.employee_id, e.name,
       MIN(p.promotion_date) AS first_promo,
       MAX(p.promotion_date) AS last_promo,
       DATEDIFF(MAX(p.promotion_date), MIN(p.promotion_date)) / NULLIF(COUNT(p.promotion_date)-1,0) AS avg_days_between_promotions
FROM fact_promotion p
JOIN dim_employee e ON p.employee_id = e.employee_id
GROUP BY e.employee_id, e.name;
                                       -- Performance & Satisfaction Views:

-- View: Avg Performance by Department
CREATE OR REPLACE VIEW vw_avg_performance_department AS
SELECT d.department, AVG(f.performance_score) AS avg_performance
FROM fact_performance f
JOIN dim_employee e ON f.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department;

-- View: Avg Satisfaction by Location
CREATE OR REPLACE VIEW vw_avg_satisfaction_location AS
SELECT l.city, AVG(f.satisfaction_score) AS avg_satisfaction
FROM fact_performance f
JOIN dim_employee e ON f.employee_id = e.employee_id
JOIN dim_location l ON e.location_id = l.location_id
GROUP BY l.city;

-- View: Performance vs Satisfaction Correlation
CREATE OR REPLACE VIEW vw_performance_satisfaction AS
SELECT f.performance_score, f.satisfaction_score, COUNT(*) AS employee_count
FROM fact_performance f
GROUP BY f.performance_score, f.satisfaction_score;

                                    -- Organizational Hierarchy Views: 
-- View: Direct Reports per Manager
CREATE OR REPLACE VIEW vw_direct_reports AS
SELECT m.name AS manager_name, COUNT(e.employee_id) AS direct_reports
FROM dim_employee e
JOIN dim_employee m ON e.manager_id = m.employee_id
GROUP BY m.employee_id, m.name;

-- View: Department Manager Load
CREATE OR REPLACE VIEW vw_department_manager_load AS
SELECT d.department, m.name AS manager_name, COUNT(e.employee_id) AS reports_count
FROM dim_employee e
JOIN dim_employee m ON e.manager_id = m.employee_id
JOIN dim_department d ON e.department_id = d.department_id
GROUP BY d.department, m.employee_id, m.name;

                                        -- Turnover Risk and Promotion Velocity: 

-- View: Turnover Risk (High Performers, Low Satisfaction)
CREATE OR REPLACE VIEW vw_turnover_risk AS
SELECT e.employee_id, e.name, f.performance_score, f.satisfaction_score
FROM fact_performance f
JOIN dim_employee e ON f.employee_id = e.employee_id
WHERE f.satisfaction_score < 5 AND f.performance_score > 4;

-- View: Promotion Velocity by Employee
CREATE OR REPLACE VIEW vw_promotion_velocity AS
SELECT e.employee_id, e.name, COUNT(p.employee_id) AS promotion_count,
       DATEDIFF(MAX(p.promotion_date), MIN(p.promotion_date)) AS total_days,
       ROUND(DATEDIFF(MAX(p.promotion_date), MIN(p.promotion_date))/NULLIF(COUNT(p.employee_id)-1,0),2) AS avg_days_between_promotions
FROM fact_promotion p
JOIN dim_employee e ON p.employee_id = e.employee_id
GROUP BY e.employee_id, e.name;





