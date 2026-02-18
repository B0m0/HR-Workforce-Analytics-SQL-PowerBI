                                   -- PREPARING AND CLEANSING THE DATASET:
                                   
                                   
                                   -- CHECKING AND HANDLING MISSING VALUES: 

-- staging_departments:
-- 1 Check for missing values: 
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN department_id IS NULL THEN 1 ELSE 0 END) AS missing_department_id,
    SUM(CASE WHEN department IS NULL THEN 1 ELSE 0 END) AS missing_department,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS missing_category
FROM staging_departments;
-- staging_employee:
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN employee_id IS NULL THEN 1 ELSE 0 END) AS missing_employee_id,
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS missing_name,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN department_id IS NULL THEN 1 ELSE 0 END) AS missing_department_id,
    SUM(CASE WHEN location_id IS NULL THEN 1 ELSE 0 END) AS missing_location_id,
    SUM(CASE WHEN seniority IS NULL THEN 1 ELSE 0 END) AS missing_seniority,
    SUM(CASE WHEN education IS NULL THEN 1 ELSE 0 END) AS missing_education,
    SUM(CASE WHEN hire_date IS NULL THEN 1 ELSE 0 END) AS missing_hire_date,
    SUM(CASE WHEN work_mode IS NULL THEN 1 ELSE 0 END) AS missing_work_mode,
    SUM(CASE WHEN performance_score IS NULL THEN 1 ELSE 0 END) AS missing_performance_score,
    SUM(CASE WHEN satisfaction_score IS NULL THEN 1 ELSE 0 END) AS missing_satisfaction_score,
    SUM(CASE WHEN initial_salary_usd IS NULL THEN 1 ELSE 0 END) AS missing_initial_salary_usd,
    SUM(CASE WHEN manager_id IS NULL THEN 1 ELSE 0 END) AS missing_manager_id
FROM staging_employee;

-- staging_location: 
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN location_id IS NULL THEN 1 ELSE 0 END) AS missing_location_id,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN cost_index IS NULL THEN 1 ELSE 0 END) AS missing_cost_index
FROM staging_location;
-- staging_org_edges:
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN source_manager_id IS NULL THEN 1 ELSE 0 END) AS missing_manager_id,
    SUM(CASE WHEN target_employee_id IS NULL THEN 1 ELSE 0 END) AS missing_employee_id
FROM staging_org_edges;

-- staging_promotions:
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN employee_id IS NULL THEN 1 ELSE 0 END) AS missing_employee_id,
    SUM(CASE WHEN promotion_date IS NULL THEN 1 ELSE 0 END) AS missing_promotion_date,
    SUM(CASE WHEN from_level IS NULL THEN 1 ELSE 0 END) AS missing_from_level,
    SUM(CASE WHEN to_level IS NULL THEN 1 ELSE 0 END) AS missing_to_level
FROM staging_promotions;

-- staging_salaries_annual: 
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN employee_id IS NULL THEN 1 ELSE 0 END) AS missing_employee_id,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS missing_year,
    SUM(CASE WHEN seniority_level IS NULL THEN 1 ELSE 0 END) AS missing_seniority_level,
    SUM(CASE WHEN salary_usd IS NULL THEN 1 ELSE 0 END) AS missing_salary_usd
FROM staging_salaries_annual;

-- 2 Handle missing values :
-- Log employees with missing manager_id
CREATE TABLE IF NOT EXISTS employee_missing_manager_log AS
SELECT *
FROM staging_employee
WHERE manager_id IS NULL;
-- Impute missing manager_id with -1 (Top-level manager)
UPDATE staging_employee
SET manager_id = -1
WHERE manager_id IS NULL;
-- Check that no more missing values exist
SELECT COUNT(*) AS missing_manager_id
FROM staging_employee
WHERE manager_id IS NULL;

                                      -- CHECKING AND HANDLING HANDLING DUPLICATES: 
-- staging_departments:

-- Check duplicate department_id
SELECT department_id, COUNT(*) AS cnt
FROM staging_departments
GROUP BY department_id
HAVING cnt > 1;

-- Check duplicate department names
SELECT department, COUNT(*) AS cnt
FROM staging_departments
GROUP BY department
HAVING cnt > 1;
-- Log duplicates
CREATE TABLE IF NOT EXISTS departments_duplicates_log AS
SELECT *
FROM staging_departments
WHERE department_id IN (
    SELECT department_id
    FROM staging_departments
    GROUP BY department_id
    HAVING COUNT(*) > 1
);

-- Remove duplicates (keep first occurrence)
DELETE t1
FROM staging_departments t1
INNER JOIN (
    SELECT MIN(department_id) AS keep_id, department_id
    FROM staging_departments
    GROUP BY department_id
    HAVING COUNT(*) > 1
) t2 ON t1.department_id = t2.department_id
WHERE t1.department_id <> t2.keep_id;

-- staging_employee: 

-- Check duplicate employee_id
SELECT employee_id, COUNT(*) AS cnt
FROM staging_employee
GROUP BY employee_id
HAVING cnt > 1;

-- Optional: check potential soft duplicates (same name, same department)
SELECT name, department_id, COUNT(*) AS cnt
FROM staging_employee
GROUP BY name, department_id
HAVING cnt > 1;

-- Log PK duplicates
CREATE TABLE IF NOT EXISTS employee_duplicates_log AS
SELECT *
FROM staging_employee
WHERE employee_id IN (
    SELECT employee_id
    FROM staging_employee
    GROUP BY employee_id
    HAVING COUNT(*) > 1
);

-- Remove PK duplicates (keep first)
DELETE t1
FROM staging_employee t1
INNER JOIN (
    SELECT MIN(employee_id) AS keep_id, employee_id
    FROM staging_employee
    GROUP BY employee_id
    HAVING COUNT(*) > 1
) t2 ON t1.employee_id = t2.employee_id
WHERE t1.employee_id <> t2.keep_id;

-- staging_location:

-- Duplicate location_id
SELECT location_id, COUNT(*) AS cnt
FROM staging_location
GROUP BY location_id
HAVING cnt > 1;

-- Duplicate city-country combination
SELECT country, city, COUNT(*) AS cnt
FROM staging_location
GROUP BY country, city
HAVING cnt > 1;
-- Log duplicates
CREATE TABLE IF NOT EXISTS location_duplicates_log AS
SELECT *
FROM staging_location
WHERE location_id IN (
    SELECT location_id
    FROM staging_location
    GROUP BY location_id
    HAVING COUNT(*) > 1
);

-- Remove PK duplicates (keep first)
DELETE t1
FROM staging_location t1
INNER JOIN (
    SELECT MIN(location_id) AS keep_id, location_id
    FROM staging_location
    GROUP BY location_id
    HAVING COUNT(*) > 1
) t2 ON t1.location_id = t2.location_id
WHERE t1.location_id <> t2.keep_id;

-- staging_org_edges:
SELECT source_manager_id, target_employee_id, COUNT(*) AS cnt
FROM staging_org_edges
GROUP BY source_manager_id, target_employee_id
HAVING cnt > 1;

-- Log duplicates
CREATE TABLE IF NOT EXISTS org_edges_duplicates_log AS
SELECT *
FROM staging_org_edges
WHERE (source_manager_id, target_employee_id) IN (
    SELECT source_manager_id, target_employee_id
    FROM staging_org_edges
    GROUP BY source_manager_id, target_employee_id
    HAVING COUNT(*) > 1
);

-- Remove duplicates (keep first)
DELETE t1
FROM staging_org_edges t1
INNER JOIN (
    SELECT MIN(source_manager_id) AS keep_source, MIN(target_employee_id) AS keep_target
    FROM staging_org_edges
    GROUP BY source_manager_id, target_employee_id
    HAVING COUNT(*) > 1
) t2 ON t1.source_manager_id = t2.keep_source AND t1.target_employee_id = t2.keep_target
WHERE t1.source_manager_id <> t2.keep_source OR t1.target_employee_id <> t2.keep_target;

-- staging_promotions: 

SELECT employee_id, promotion_date, COUNT(*) AS cnt
FROM staging_promotions
GROUP BY employee_id, promotion_date
HAVING cnt > 1;

-- Log duplicates
CREATE TABLE IF NOT EXISTS promotions_duplicates_log AS
SELECT *
FROM staging_promotions
WHERE (employee_id, promotion_date) IN (
    SELECT employee_id, promotion_date
    FROM staging_promotions
    GROUP BY employee_id, promotion_date
    HAVING COUNT(*) > 1
);

-- Remove duplicates (keep first)
DELETE t1
FROM staging_promotions t1
INNER JOIN (
    SELECT employee_id, MIN(promotion_date) AS keep_date
    FROM staging_promotions
    GROUP BY employee_id, promotion_date
    HAVING COUNT(*) > 1
) t2 ON t1.employee_id = t2.employee_id AND t1.promotion_date = t2.keep_date
WHERE t1.promotion_date <> t2.keep_date;

-- staging_salaries_annual 
SELECT employee_id, year, COUNT(*) AS cnt
FROM staging_salaries_annual
GROUP BY employee_id, year
HAVING cnt > 1;

-- Log duplicates
CREATE TABLE IF NOT EXISTS salaries_duplicates_log AS
SELECT *
FROM staging_salaries_annual
WHERE (employee_id, year) IN (
    SELECT employee_id, year
    FROM staging_salaries_annual
    GROUP BY employee_id, year
    HAVING COUNT(*) > 1
);

-- Remove duplicates (keep first)
DELETE t1
FROM staging_salaries_annual t1
INNER JOIN (
    SELECT employee_id, MIN(year) AS keep_year
    FROM staging_salaries_annual
    GROUP BY employee_id, year
    HAVING COUNT(*) > 1
) t2 ON t1.employee_id = t2.employee_id AND t1.year = t2.keep_year
WHERE t1.year <> t2.keep_year;






















								