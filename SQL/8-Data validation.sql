                                    -- PREPARING AND CLEANSING THE DATASET:
                                    
								
							
								    -- DATA VALIDATION:
                                  
-- Departments Table: 
-- Check duplicates in department_id
SELECT department_id, COUNT(*) AS cnt
FROM staging_departments
GROUP BY department_id
HAVING cnt > 1;

-- Check missing PKs
SELECT *
FROM staging_departments
WHERE department_id IS NULL;

-- Employee Table:

-- Check duplicate employee_id
SELECT employee_id, COUNT(*) AS cnt
FROM staging_employee
GROUP BY employee_id
HAVING cnt > 1;

-- Check missing PK
SELECT *
FROM staging_employee
WHERE employee_id IS NULL;

-- Check invalid department_id FK
SELECT e.employee_id
FROM staging_employee e
LEFT JOIN staging_departments d
ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- Check invalid location_id FK
SELECT e.employee_id
FROM staging_employee e
LEFT JOIN staging_location l
ON e.location_id = l.location_id
WHERE l.location_id IS NULL;

-- Check invalid manager_id FK (allow -1 if used for missing managers)
SELECT e.employee_id
FROM staging_employee e
LEFT JOIN staging_employee m
ON e.manager_id = m.employee_id OR e.manager_id = -1
WHERE e.manager_id IS NOT NULL AND m.employee_id IS NULL;

-- Location Table: 

-- Check duplicate location_id
SELECT location_id, COUNT(*) AS cnt
FROM staging_location
GROUP BY location_id
HAVING cnt > 1;

-- Check missing PK
SELECT *
FROM staging_location
WHERE location_id IS NULL;

-- Optional: Check if location is referenced by employees
SELECT l.location_id
FROM staging_location l
LEFT JOIN staging_employee e
ON l.location_id = e.location_id
WHERE e.location_id IS NULL;

-- Org_edges Table:

-- Check duplicate edges
SELECT source_manager_id, target_employee_id, COUNT(*) AS cnt
FROM staging_org_edges
GROUP BY source_manager_id, target_employee_id
HAVING cnt > 1;

-- Check FK consistency: managers and employees exist
SELECT e.*
FROM staging_org_edges e
LEFT JOIN staging_employee m
ON e.source_manager_id = m.employee_id OR e.source_manager_id = -1
LEFT JOIN staging_employee t
ON e.target_employee_id = t.employee_id
WHERE m.employee_id IS NULL OR t.employee_id IS NULL;

-- Promotions Table:

-- Check duplicate promotions (same employee_id & promotion_date)
SELECT employee_id, promotion_date, COUNT(*) AS cnt
FROM staging_promotions
GROUP BY employee_id, promotion_date
HAVING cnt > 1;

-- Check employee_id FK
SELECT p.employee_id
FROM staging_promotions p
LEFT JOIN staging_employee e
ON p.employee_id = e.employee_id
WHERE e.employee_id IS NULL;

-- Salaries_annual Table: 

-- Check duplicate salary records
SELECT employee_id, year, COUNT(*) AS cnt
FROM staging_salaries_annual
GROUP BY employee_id, year
HAVING cnt > 1;

-- Check employee_id FK
SELECT s.employee_id
FROM staging_salaries_annual s
LEFT JOIN staging_employee e
ON s.employee_id = e.employee_id
WHERE e.employee_id IS NULL;






