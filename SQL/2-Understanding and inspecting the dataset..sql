                               -- Understanding and inspecting the dataset:
-- Departments:
SELECT * FROM departments;
-- 1. Show first 10 rows
SELECT * FROM departments LIMIT 10;

-- 2. Check number of departments
SELECT COUNT(*) AS num_departments FROM departments;

-- 3. Check unique categories
SELECT category, COUNT(*) AS num_departments
FROM departments
GROUP BY category;
-- Employee 
SELECT * FROM employee;
-- 1. Show first 10 rows

SELECT * FROM employee LIMIT 10;

-- 2. Summary: total employees
SELECT COUNT(*) AS total_employees FROM employee;

-- 3. Employees per department
SELECT d.department, COUNT(*) AS num_employees
FROM employee e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department;

-- 4. Employees per location
SELECT l.city, l.country, COUNT(*) AS num_employees
FROM employee e
JOIN location l ON e.location_id = l.location_id
GROUP BY l.city, l.country;

-- 5. Average age and salary
SELECT AVG(age) AS avg_age, AVG(initial_salary_usd) AS avg_initial_salary
FROM employee;

-- 6. Count by seniority level
SELECT seniority, COUNT(*) AS num_employees
FROM employee
GROUP BY seniority;

-- 7. Count by work_mode
SELECT work_mode, COUNT(*) AS num_employees
FROM employee
GROUP BY work_mode;

-- Location:
SELECT * FROM location;
-- 1. Show first 10 rows
SELECT * FROM location LIMIT 10;

-- 2. Count of locations
SELECT COUNT(*) AS num_locations FROM location;

-- Org_edges:
SELECT * FROM org_edges;
-- 1. Show first 10 rows
SELECT * FROM org_edges LIMIT 10;

-- 2. Count of reporting lines
SELECT COUNT(*) AS total_edges FROM org_edges;

-- 3. Employees with multiple managers
SELECT target_employee_id, COUNT(*) AS num_managers
FROM org_edges
GROUP BY target_employee_id
HAVING num_managers > 1;

-- Promotions:
SELECT * FROM promotions;
-- 1. Show first 10 rows
SELECT * FROM promotions LIMIT 10;

-- 2. Count of promotions
SELECT COUNT(*) AS total_promotions FROM promotions;

-- 3. Promotions per employee
SELECT employee_id, COUNT(*) AS num_promotions
FROM promotions
GROUP BY employee_id
ORDER BY num_promotions DESC;

-- 4. Promotion speed per employee
SELECT employee_id, MIN(promotion_date) AS first_promotion, MAX(promotion_date) AS last_promotion
FROM promotions
GROUP BY employee_id;

-- Salaries_annual:
SELECT * FROM salaries_annual;
-- 1. Show first 10 rows
SELECT * FROM salaries_annual LIMIT 10;

-- 2. Count of salary records
SELECT COUNT(*) AS total_salary_records FROM salaries_annual;

-- 3. Average salary by seniority level
SELECT seniority_level, AVG(salary_usd) AS avg_salary
FROM salaries_annual
GROUP BY seniority_level;

-- 4. Year-over-year salary growth
SELECT year, AVG(salary_usd) AS avg_salary
FROM salaries_annual
GROUP BY year
ORDER BY year;

-- 1️ Average salary by department (highest salary first)
SELECT d.department, AVG(s.salary_usd) AS avg_salary
FROM salaries_annual s
JOIN employee e ON s.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department
ORDER BY avg_salary DESC;

-- 2️ Average satisfaction by location (highest satisfaction first)
SELECT l.city, AVG(e.satisfaction_score) AS avg_satisfaction
FROM employee e
JOIN location l ON e.location_id = l.location_id
GROUP BY l.city
ORDER BY avg_satisfaction DESC;

-- 3.Employees per manager sorted by average performance (highest first)
SELECT m.source_manager_id, COUNT(e.employee_id) AS num_reports, AVG(e.performance_score) AS avg_perf
FROM org_edges m
JOIN employee e ON m.target_employee_id = e.employee_id
GROUP BY m.source_manager_id
ORDER BY avg_perf DESC;













