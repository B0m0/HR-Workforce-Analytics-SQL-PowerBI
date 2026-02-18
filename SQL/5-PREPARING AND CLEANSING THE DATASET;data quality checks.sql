                                         -- PREPARING AND CLEANSING THE DATASET:
                                         
                                         -- DATA QUALITY CHECKS:
-- MISSING VALUES CHECKS: 


SELECT
    SUM(employee_id IS NULL)        AS employee_id_missing,
    SUM(name IS NULL)               AS name_missing,
    SUM(gender IS NULL)             AS gender_missing,
    SUM(age IS NULL)                AS age_missing,
    SUM(department_id IS NULL)      AS department_missing,
    SUM(location_id IS NULL)        AS location_missing,
    SUM(seniority IS NULL)          AS seniority_missing,
    SUM(education IS NULL)          AS education_missing,
    SUM(hire_date IS NULL)          AS hire_date_missing,
    SUM(work_mode IS NULL)          AS work_mode_missing,
    SUM(performance_score IS NULL)  AS performance_missing,
    SUM(satisfaction_score IS NULL) AS satisfaction_missing,
    SUM(initial_salary_usd IS NULL) AS salary_missing,
    SUM(manager_id IS NULL)         AS manager_missing
FROM staging_employee;

SELECT
    SUM(department_id IS NULL) AS dept_id_missing,
    SUM(department IS NULL)    AS department_name_missing,
    SUM(category IS NULL)      AS category_missing
FROM staging_departments;

SELECT
    SUM(location_id IS NULL) AS location_id_missing,
    SUM(country IS NULL)     AS country_missing,
    SUM(city IS NULL)        AS city_missing,
    SUM(cost_index IS NULL)  AS cost_index_missing
FROM staging_location;

SELECT
    SUM(employee_id IS NULL)    AS employee_missing,
    SUM(promotion_date IS NULL) AS promotion_date_missing,
    SUM(from_level IS NULL)     AS from_level_missing,
    SUM(to_level IS NULL)       AS to_level_missing
FROM staging_promotions;

SELECT
    SUM(employee_id IS NULL) AS employee_missing,
    SUM(year IS NULL)        AS year_missing,
    SUM(seniority_level IS NULL) AS seniority_missing,
    SUM(salary_usd IS NULL)  AS salary_missing
FROM staging_salaries_annual;

SELECT
    SUM(source_manager_id IS NULL)   AS source_manager_missing,
    SUM(target_employee_id IS NULL)  AS target_employee_missing
FROM staging_org_edges; 

-- DUPLICATE CHECKS:



SELECT
    employee_id,
    COUNT(*) AS duplicate_count
FROM staging_employee
GROUP BY employee_id
HAVING COUNT(*) > 1;

SELECT
    department_id,
    COUNT(*)
FROM staging_departments
GROUP BY department_id
HAVING COUNT(*) > 1;

SELECT
    location_id,
    COUNT(*)
FROM staging_location
GROUP BY location_id
HAVING COUNT(*) > 1;

SELECT
    employee_id,
    promotion_date,
    from_level,
    to_level,
    COUNT(*) AS duplicate_count
FROM staging_promotions
GROUP BY employee_id, promotion_date, from_level, to_level
HAVING COUNT(*) > 1;

SELECT
    employee_id,
    year,
    COUNT(*) AS records_per_year
FROM staging_salaries_annual
GROUP BY employee_id, year
HAVING COUNT(*) > 1;

SELECT
    source_manager_id,
    target_employee_id,
    COUNT(*) AS duplicate_count
FROM staging_org_edges
GROUP BY source_manager_id, target_employee_id
HAVING COUNT(*) > 1;
SELECT
    target_employee_id,
    COUNT(DISTINCT source_manager_id) AS manager_count
FROM staging_org_edges
GROUP BY target_employee_id
HAVING COUNT(DISTINCT source_manager_id) > 1;

-- DATA TYPE AND CONSISTENCY:



-- staging_employee
-- 1-Gender Domain Check
SELECT DISTINCT gender
FROM staging_employee;
-- 2-Work Mode Domain Check
SELECT DISTINCT work_mode
FROM staging_employee;
-- 3-Seniority Domain Exploration
SELECT DISTINCT seniority
FROM staging_employee;
-- 4-Education Domain Exploration
SELECT DISTINCT education
FROM staging_employee;
-- 5-Age Logical Validation
SELECT *
FROM staging_employee
WHERE age < 16
   OR age > 70;
-- 6-Performance Score Bounds
SELECT *
FROM staging_employee
WHERE performance_score < 0
   OR performance_score > 5;
-- 7-Satisfaction Score Bounds
SELECT *
FROM staging_employee
WHERE satisfaction_score < 0
   OR satisfaction_score > 10;
-- 8-Salary Logical Validation
SELECT *
FROM staging_employee
WHERE initial_salary_usd <= 0;
-- 9-Hire Date Temporal Validity
SELECT *
FROM staging_employee
WHERE hire_date > CURRENT_DATE;
-- staging_departments
-- 1 Category Domain Check
SELECT DISTINCT category
FROM staging_departments;
-- 2 Department domain check 
SELECT DISTINCT department
FROM staging_departments;
-- staging_location
-- 1 Country / City Completeness
SELECT *
FROM staging_location
WHERE country = ''
   OR city = '';
-- 2 Cost Index Logical Range
SELECT *
FROM staging_location
WHERE cost_index <= 0
   OR cost_index > 3;
   
-- staging_org_edges
-- 1 Self-Referencing Edges
SELECT *
FROM staging_org_edges
WHERE source_manager_id = target_employee_id;
-- 2 Circular Management (Direct)
SELECT
    e1.source_manager_id,
    e1.target_employee_id
FROM staging_org_edges e1
JOIN staging_org_edges e2
  ON e1.source_manager_id = e2.target_employee_id
 AND e1.target_employee_id = e2.source_manager_id;
-- staging_promotions 
-- 1 Promotion Level Validity 
SELECT DISTINCT from_level, to_level
FROM staging_promotions;
-- 2 Promotion Date Validity
SELECT *
FROM staging_promotions
WHERE promotion_date > CURRENT_DATE;
-- 3 Illogical Promotion Events
SELECT *
FROM staging_promotions
WHERE from_level = to_level;
-- staging_salaries_annual 
-- .1 Year Validity
SELECT *
FROM staging_salaries_annual
WHERE year < 2000
   OR year > YEAR(CURRENT_DATE);
-- 2 Salary Logical Bounds
SELECT *
FROM staging_salaries_annual
WHERE salary_usd <= 0;
-- 3 Seniority Domain Check 
SELECT DISTINCT seniority_level
FROM staging_salaries_annual;


-- OUTLIERS AND ANOMALIES:


-- staging_employee 
-- 1 Age Outliers
SELECT *
FROM staging_employee
WHERE age < 18
   OR age > 65;
-- 2 Performance vs Satisfaction Mismatch
SELECT
    employee_id,
    performance_score,
    satisfaction_score
FROM staging_employee
WHERE performance_score >= 4.5
  AND satisfaction_score <= 3;
-- 3 Salary vs Seniority Anomalies
SELECT
    employee_id,
    seniority,
    initial_salary_usd
FROM staging_employee
WHERE seniority = 'Intern'
  AND initial_salary_usd > 80000;
-- 4 Salary vs Location Cost Index to Detect compensation imbalance
SELECT
    e.employee_id,
    e.initial_salary_usd,
    l.cost_index
FROM staging_employee e
JOIN staging_location l
    ON e.location_id = l.location_id
WHERE e.initial_salary_usd / l.cost_index > 200000;

-- staging_departments
-- 1 Departments with No Employees
SELECT
    d.department_id,
    d.department
FROM staging_departments d
LEFT JOIN staging_employee e
    ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;
-- staging_location 
-- 1 Extreme Cost Index Values 
SELECT *
FROM staging_location
WHERE cost_index < 0.5
   OR cost_index > 2.0;
-- 2 Locations with Very Few Employees
SELECT
    l.country,
    l.city,
    COUNT(e.employee_id) AS employee_count
FROM staging_location l
LEFT JOIN staging_employee e
    ON l.location_id = e.location_id
GROUP BY l.country, l.city
HAVING COUNT(e.employee_id) <= 1;
-- staging_org_edges 
-- 1 Managers with Excessive Direct Reports.this mean Possible data duplication Or org design risk.
SELECT
    source_manager_id,
    COUNT(target_employee_id) AS direct_reports
FROM staging_org_edges
GROUP BY source_manager_id
HAVING COUNT(target_employee_id) > 15;
-- 2 Employees with No Manager 
SELECT
    e.employee_id
FROM staging_employee e
LEFT JOIN staging_org_edges oe
    ON e.employee_id = oe.target_employee_id
WHERE oe.target_employee_id IS NULL
  AND e.manager_id IS NOT NULL;
  
-- staging_promotions
-- 1 Rapid Promotion Patterns
SELECT
    employee_id,
    COUNT(*) AS promotion_count
FROM staging_promotions
GROUP BY employee_id
HAVING COUNT(*) >= 3;
-- 2 Promotion Without Salary Growth.Promotion should usually align with compensation change.
SELECT
    p.employee_id,
    p.promotion_date,
    s.salary_usd
FROM staging_promotions p
LEFT JOIN staging_salaries_annual s
    ON p.employee_id = s.employee_id
   AND YEAR(p.promotion_date) = s.year;

-- staging_salaries_annual
-- 1 Salary Decrease Year-over-Year
WITH SalaryChanges AS (
    SELECT
        employee_id,
        year,
        salary_usd,
        LAG(salary_usd) OVER (
            PARTITION BY employee_id
            ORDER BY year 
        ) AS previous_salary
    FROM staging_salaries_annual
)
SELECT 
    employee_id,
    year,
    salary_usd,
    previous_salary
FROM SalaryChanges
WHERE salary_usd < previous_salary
ORDER BY year DESC; 

-- 2 Extreme Salary Growth 
WITH SalaryData AS (
    -- Step 1: Fetch the previous year's salary
    SELECT
        employee_id,
        year,
        salary_usd,
        LAG(salary_usd) OVER (
            PARTITION BY employee_id
            ORDER BY year
        ) AS previous_salary
    FROM staging_salaries_annual
),
GrowthCalculations AS (
    -- Step 2: Calculate the raw growth rate
    SELECT 
        employee_id,
        year,
        salary_usd,
        previous_salary,
        -- Calculate the decimal growth (e.g., 0.52 for 52%)
        (salary_usd - previous_salary) / NULLIF(previous_salary, 0) AS growth_rate
    FROM SalaryData
    WHERE previous_salary IS NOT NULL
)
-- Step 3: Filter for the "Exceptional Event" (> 50%)
SELECT 
    employee_id,
    year AS event_year,
    previous_salary AS old_salary,
    salary_usd AS new_salary,
    -- Format as a readable percentage
    CONCAT(ROUND(growth_rate * 100, 2), '%') AS yoy_growth_pct
FROM GrowthCalculations
WHERE growth_rate > 0.5
ORDER BY year DESC, growth_rate DESC;








 



















































								