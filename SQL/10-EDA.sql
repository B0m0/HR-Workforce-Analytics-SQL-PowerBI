                                       -- EXPLORATORY DATA ANALYSIS:
                                       
                                       
                                       -- EDA Staging_department.

-- Column & Type Validation;Ensure all columns have appropriate types and data consistency.

 DESCRIBE staging_departments;

-- Check department_id uniqueness and data type sanity
SELECT MIN(department_id) AS min_id, MAX(department_id) AS max_id
FROM staging_departments;
-- missing values 
SELECT 
    COUNT(*) AS total_rows,
    SUM(department_id IS NULL) AS missing_id,
    SUM(department IS NULL) AS missing_department,
    SUM(category IS NULL) AS missing_category
FROM staging_departments;
-- Grain Validation;Each department_id should be unique.
SELECT department_id, COUNT(*) AS cnt
FROM staging_departments
GROUP BY department_id
HAVING cnt > 1;
-- Distribution Analysis;All departments should fall into expected categories.
SELECT category, COUNT(*) AS cnt
FROM staging_departments
GROUP BY category;

-- The step of the logical Outliers; Not much applies here as departments are categorical, just check for duplicates or misclassifications.

-- Referential Consistency
SELECT DISTINCT department_id
FROM staging_employee
WHERE department_id NOT IN (SELECT department_id FROM staging_departments);

-- Patterns & Behavior;Count of employees per department (early insight).
SELECT e.department_id, d.department, COUNT(*) AS num_employees
FROM staging_employee e
JOIN staging_departments d ON e.department_id = d.department_id
GROUP BY e.department_id, d.department;

-- Validate Business Assumptions;Example: All department IDs used by employees must exist in staging_departments. Already checked in step 6.

                               
                               -- EDA STAGING_EMPLOYEE:

-- Column & Type Validation:
DESCRIBE staging_employee;

-- Check ranges for numeric fields
SELECT 
    MIN(age) AS min_age, MAX(age) AS max_age,
    MIN(performance_score) AS min_perf, MAX(performance_score) AS max_perf,
    MIN(satisfaction_score) AS min_sat, MAX(satisfaction_score) AS max_sat,
    MIN(initial_salary_usd) AS min_salary, MAX(initial_salary_usd) AS max_salary
FROM staging_employee;
-- Missing Values
SELECT 
    COUNT(*) AS total_rows,
    SUM(department_id IS NULL) AS missing_dept,
    SUM(location_id IS NULL) AS missing_location,
    SUM(manager_id IS NULL) AS missing_manager,
    SUM(performance_score IS NULL) AS missing_perf,
    SUM(satisfaction_score IS NULL) AS missing_sat,
    SUM(initial_salary_usd IS NULL) AS missing_salary
FROM staging_employee;

-- Grain Validation;Employee_id must be unique.
SELECT employee_id, COUNT(*) AS cnt
FROM staging_employee
GROUP BY employee_id
HAVING cnt > 1;

-- Distribution Analysis
SELECT gender, COUNT(*) AS cnt FROM staging_employee GROUP BY gender;
SELECT seniority, COUNT(*) AS cnt FROM staging_employee GROUP BY seniority;
SELECT work_mode, COUNT(*) AS cnt FROM staging_employee GROUP BY work_mode;

-- Salary bins
SELECT 
    CASE 
        WHEN initial_salary_usd < 50000 THEN '<50k'
        WHEN initial_salary_usd < 100000 THEN '50k-100k'
        WHEN initial_salary_usd < 150000 THEN '100k-150k'
        ELSE '150k+' 
    END AS salary_range,
    COUNT(*) AS cnt
FROM staging_employee
GROUP BY salary_range;

-- Logical Outliers
-- Interns with very high salary
SELECT * FROM staging_employee WHERE seniority='Intern' AND initial_salary_usd > 50000;

-- Performance vs satisfaction anomalies
SELECT * FROM staging_employee WHERE performance_score > 4.5 AND satisfaction_score < 5;

-- Referential Consistency

-- Department
SELECT e.* 
FROM staging_employee e
LEFT JOIN staging_departments d ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- Location
SELECT e.* 
FROM staging_employee e
LEFT JOIN staging_location l ON e.location_id = l.location_id
WHERE l.location_id IS NULL;

-- Manager exists
SELECT e.* 
FROM staging_employee e
LEFT JOIN staging_employee m ON e.manager_id = m.employee_id
WHERE e.manager_id IS NOT NULL AND m.employee_id IS NULL;

-- Patterns & Behavior
-- Average performance by department
SELECT e.department_id, AVG(performance_score) AS avg_perf, AVG(satisfaction_score) AS avg_sat
FROM staging_employee e
GROUP BY e.department_id;
-- Validate Business Assumptions
-- Senior employees have higher salaries
SELECT seniority, AVG(initial_salary_usd) AS avg_salary
FROM staging_employee
GROUP BY seniority
ORDER BY FIELD(seniority,'Intern','Junior','Mid','Senior','Lead','Manager','Director','VP');

                               -- EDA  STAGING_LOCATION :
-- Column & Type Validation
DESCRIBE staging_location;
SELECT MIN(cost_index) AS min_ci, MAX(cost_index) AS max_ci FROM staging_location;
-- Missing Values
SELECT COUNT(*) AS total_rows,
       SUM(country IS NULL) AS missing_country,
       SUM(city IS NULL) AS missing_city,
       SUM(cost_index IS NULL) AS missing_ci
FROM staging_location;
-- Grain Validation
SELECT location_id, COUNT(*) AS cnt
FROM staging_location
GROUP BY location_id
HAVING cnt > 1;
-- Distribution Analysis
SELECT country, COUNT(*) AS cnt FROM staging_location GROUP BY country;
-- Logical Outliers;cost_index < 0 or > 3 (likely impossible).

-- Referential Consistency.
SELECT e.*
FROM staging_employee e
LEFT JOIN staging_location l ON e.location_id = l.location_id
WHERE l.location_id IS NULL;
-- Patterns & Behavior
SELECT l.city, COUNT(e.employee_id) AS num_employees
FROM staging_location l
LEFT JOIN staging_employee e ON l.location_id = e.location_id
GROUP BY l.city;
                        
                        
                          -- EDA STAGING_ORG_EDGES:
-- Column & Type Validation
DESCRIBE staging_org_edges;
-- Missing Values
SELECT COUNT(*) AS total_rows,
       SUM(source_manager_id IS NULL) AS missing_manager,
       SUM(target_employee_id IS NULL) AS missing_employee
FROM staging_org_edges;

-- Grain Validation
SELECT source_manager_id, target_employee_id, COUNT(*) AS cnt
FROM staging_org_edges
GROUP BY source_manager_id, target_employee_id
HAVING cnt > 1;
-- Distribution Analysis;Count reports per manager.
SELECT source_manager_id, COUNT(target_employee_id) AS report_count
FROM staging_org_edges
GROUP BY source_manager_id;

-- Logical Outliers;Self-reporting: manager_id = target_employee_id.
SELECT * FROM staging_org_edges WHERE source_manager_id = target_employee_id;
-- Referential Consistency
SELECT o.*
FROM staging_org_edges o
LEFT JOIN staging_employee m ON o.source_manager_id = m.employee_id
LEFT JOIN staging_employee e ON o.target_employee_id = e.employee_id
WHERE m.employee_id IS NULL OR e.employee_id IS NULL;
-- Patterns & Behavior;Number of direct reports distribution.
SELECT COUNT(*) AS num_managers, COUNT(target_employee_id) AS total_reports
FROM staging_org_edges
GROUP BY source_manager_id;

                              -- EDA STAGING_PROMOTIONS:
-- Column & Type Validation
DESCRIBE staging_promotions;
-- Missing Values
SELECT COUNT(*) AS total_rows,
       SUM(employee_id IS NULL) AS missing_employee,
       SUM(promotion_date IS NULL) AS missing_date
FROM staging_promotions;
-- Grain Validation
SELECT employee_id, promotion_date, COUNT(*) AS cnt
FROM staging_promotions
GROUP BY employee_id, promotion_date
HAVING cnt > 1;
-- Distribution Analysis
SELECT from_level, COUNT(*) AS cnt FROM staging_promotions GROUP BY from_level;
SELECT to_level, COUNT(*) AS cnt FROM staging_promotions GROUP BY to_level;
-- Logical Outliers;Promotion date before hire.
SELECT p.*
FROM staging_promotions p
JOIN staging_employee e ON p.employee_id = e.employee_id
WHERE p.promotion_date < e.hire_date;
-- Referential Consistency
SELECT p.*
FROM staging_promotions p
LEFT JOIN staging_employee e ON p.employee_id = e.employee_id
WHERE e.employee_id IS NULL;
-- Patterns & Behavior;Promotions per employee.
SELECT employee_id, COUNT(*) AS promotions_count
FROM staging_promotions
GROUP BY employee_id;
-- Validate Business Assumptions;Promotions usually increase seniority.
SELECT p.employee_id, p.from_level, p.to_level
FROM staging_promotions p;
                            
                               -- EDA STAGING_SALARIES_ANNUAL: 
-- Column & Type Validation
DESCRIBE staging_salaries_annual;
-- Missing Values
SELECT COUNT(*) AS total_rows,
       SUM(employee_id IS NULL) AS missing_employee,
       SUM(year IS NULL) AS missing_year,
       SUM(salary_usd IS NULL) AS missing_salary
FROM staging_salaries_annual;
-- Grain Validation
SELECT employee_id, year, COUNT(*) AS cnt
FROM staging_salaries_annual
GROUP BY employee_id, year
HAVING cnt > 1;
-- Distribution Analysis
SELECT year, AVG(salary_usd) AS avg_salary
FROM staging_salaries_annual
GROUP BY year;
-- Logical Outliers;Negative salary or huge jumps year-over-year.
SELECT * FROM staging_salaries_annual WHERE salary_usd < 0;
-- Referential Consistency
SELECT s.*
FROM staging_salaries_annual s
LEFT JOIN staging_employee e ON s.employee_id = e.employee_id
WHERE e.employee_id IS NULL;
-- Patterns & Behavior;Salary growth per employee.
SELECT employee_id, year, salary_usd
FROM staging_salaries_annual
ORDER BY employee_id, year;
-- Validate Business Assumptions;Seniority should generally increase with salary.
SELECT s.employee_id, s.seniority_level, s.salary_usd
FROM staging_salaries_annual s
JOIN staging_employee e ON s.employee_id = e.employee_id
ORDER BY s.employee_id, s.year;









                            
					 































							







