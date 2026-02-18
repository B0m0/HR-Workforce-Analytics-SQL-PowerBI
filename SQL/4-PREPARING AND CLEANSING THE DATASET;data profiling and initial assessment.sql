                          
                          -- PREPARING AND CLEANSING THE DATASET:
                          
						
                          -- DATA PROFILING / INITIAL ASSESSMENT
DESCRIBE staging_departments;
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT department_id) AS unique_department_ids
FROM staging_departments;

DESCRIBE staging_employee;
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT employee_id) AS unique_employee_ids
FROM staging_employee;

-- Gender Distribution
SELECT 
    gender, COUNT(*) AS count_employees
FROM
    staging_employee
GROUP BY gender; 

-- Seniority Distribution

SELECT
    seniority,
    COUNT(*) AS count_employees
FROM staging_employee
GROUP BY seniority;
-- Age Distribution
SELECT
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    AVG(age) AS avg_age
FROM staging_employee;

-- Performance Score Distribution
SELECT
    MIN(performance_score) AS min_score,
    MAX(performance_score) AS max_score,
    AVG(performance_score) AS avg_score
FROM staging_employee; 

-- Satisfaction score distribution
SELECT
    MIN(satisfaction_score) AS min_score,
    MAX(satisfaction_score) AS max_score,
    AVG(satisfaction_score) AS avg_score
FROM staging_employee;

-- Salary Distribution

SELECT
    MIN(initial_salary_usd) AS min_salary,
    MAX(initial_salary_usd) AS max_salary,
    AVG(initial_salary_usd) AS avg_salary
FROM staging_employee;

-- RELATIONSHIP CHECKS 

-- EMPLOYEE ↔ DEPARTMENTS 

SELECT
    e.employee_id,
    e.department_id
FROM staging_employee e
LEFT JOIN staging_departments d
    ON e.department_id = d.department_id
WHERE e.department_id IS NOT NULL
  AND d.department_id IS NULL;
SELECT
    d.department_id,
    d.department
FROM staging_departments d
LEFT JOIN staging_employee e
    ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- EMPLOYEE ↔ LOCATION 
SELECT
    e.employee_id,
    e.location_id
FROM staging_employee e
LEFT JOIN staging_location l
    ON e.location_id = l.location_id
WHERE e.location_id IS NOT NULL
  AND l.location_id IS NULL;
SELECT
    l.country,
    l.city,
    COUNT(e.employee_id) AS employee_count
FROM staging_location l
LEFT JOIN staging_employee e
    ON l.location_id = e.location_id
GROUP BY l.country, l.city;

-- EMPLOYEE ↔ MANAGER
SELECT
    e.employee_id,
    e.manager_id
FROM staging_employee e
LEFT JOIN staging_employee m
    ON e.manager_id = m.employee_id
WHERE e.manager_id IS NOT NULL
  AND m.employee_id IS NULL;
SELECT
    employee_id,
    manager_id
FROM staging_employee
WHERE employee_id = manager_id;

-- ORG_EDGES ↔ EMPLOYEE
SELECT
    oe.target_employee_id
FROM staging_org_edges oe
LEFT JOIN staging_employee e
    ON oe.target_employee_id = e.employee_id
WHERE e.employee_id IS NULL;
SELECT
    oe.source_manager_id
FROM staging_org_edges oe
LEFT JOIN staging_employee m
    ON oe.source_manager_id = m.employee_id
WHERE m.employee_id IS NULL;
SELECT
    source_manager_id,
    target_employee_id,
    COUNT(*) AS edge_count
FROM staging_org_edges
GROUP BY source_manager_id, target_employee_id
HAVING COUNT(*) > 1;

-- PROMOTIONS ↔ EMPLOYEE
SELECT
    p.employee_id
FROM staging_promotions p
LEFT JOIN staging_employee e
    ON p.employee_id = e.employee_id
WHERE e.employee_id IS NULL;

SELECT *
FROM staging_promotions
WHERE from_level = to_level;

SELECT
    employee_id,
    promotion_date,
    from_level,
    to_level
FROM staging_promotions
ORDER BY employee_id, promotion_date;

-- SALARIES ↔ EMPLOYEE
SELECT
    s.employee_id
FROM staging_salaries_annual s
LEFT JOIN staging_employee e
    ON s.employee_id = e.employee_id
WHERE e.employee_id IS NULL;

SELECT
    employee_id,
    year,
    COUNT(*) AS records_per_year
FROM staging_salaries_annual
GROUP BY employee_id, year
HAVING COUNT(*) > 1;

-- CROSS-TABLE LOGICAL CONSISTENCY
SELECT
    s.employee_id,
    s.year,
    s.seniority_level,
    p.to_level
FROM staging_salaries_annual s
LEFT JOIN staging_promotions p
    ON s.employee_id = p.employee_id
   AND YEAR(p.promotion_date) = s.year
WHERE p.to_level IS NOT NULL
  AND s.seniority_level <> p.to_level;
















  








