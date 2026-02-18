                                  -- PREPARING AND CLEANSING THE DATASET:
                                  
                                  
                                  -- DATA STANDARDIZATION :
                                  
-- Create INITCAP function (for multi-word capitalization): 
DELIMITER $$

CREATE FUNCTION initcap(str VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE c INT DEFAULT 1;
    DECLARE len INT;
    DECLARE ret VARCHAR(255) DEFAULT '';
    DECLARE ch CHAR(1);
    
    SET len = CHAR_LENGTH(str);
    
    WHILE c <= len DO
        SET ch = SUBSTRING(str,c,1);
        IF c = 1 OR SUBSTRING(str,c-1,1) = ' ' THEN
            SET ret = CONCAT(ret,UCASE(ch));
        ELSE
            SET ret = CONCAT(ret,LCASE(ch));
        END IF;
        SET c = c + 1;
    END WHILE;
    
    RETURN ret;
END$$

DELIMITER ;

-- staging_departments:

-- Trim spaces and capitalize properly
UPDATE staging_departments
SET 
    department = initcap(TRIM(department)),
    category = initcap(TRIM(category));

-- Check for missing values
SELECT * 
FROM staging_departments
WHERE department_id IS NULL OR department IS NULL OR category IS NULL;

-- Cross-table check: make sure department_id exists in employee
SELECT DISTINCT e.department_id
FROM staging_employee e
LEFT JOIN staging_departments d
ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- staging_employee: 

-- Standardize text columns
UPDATE staging_employee
SET
    name = TRIM(name),
    gender = initcap(TRIM(gender)),
    seniority = initcap(TRIM(seniority)),
    education = initcap(TRIM(education)),
    work_mode = initcap(TRIM(work_mode));

-- Ensure numeric types
ALTER TABLE staging_employee 
MODIFY age INT,
MODIFY performance_score DECIMAL(3,2),
MODIFY satisfaction_score DECIMAL(3,2),
MODIFY initial_salary_usd DECIMAL(12,2),
MODIFY manager_id INT;

-- Ensure hire_date is DATE
ALTER TABLE staging_employee MODIFY hire_date DATE;

-- Cross-table consistency checks
-- Department exists
SELECT e.employee_id
FROM staging_employee e
LEFT JOIN staging_departments d
ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- Location exists
SELECT e.employee_id
FROM staging_employee e
LEFT JOIN staging_location l
ON e.location_id = l.location_id
WHERE l.location_id IS NULL;

-- Manager exists (or -1)
SELECT e.employee_id
FROM staging_employee e
LEFT JOIN staging_employee m
ON e.manager_id = m.employee_id OR e.manager_id = -1
WHERE e.manager_id IS NOT NULL AND m.employee_id IS NULL;

-- staging_location: 

-- Standardize text
UPDATE staging_location
SET
    country = initcap(TRIM(country)),
    city = initcap(TRIM(city));

-- Ensure numeric type
ALTER TABLE staging_location MODIFY cost_index DECIMAL(4,2);

-- Cross-table consistency: location exists in employee
SELECT l.location_id
FROM staging_location l
LEFT JOIN staging_employee e
ON l.location_id = e.location_id
WHERE e.location_id IS NULL;

-- staging_org_edges:

-- Ensure INT types
ALTER TABLE staging_org_edges
MODIFY source_manager_id INT,
MODIFY target_employee_id INT;

-- Cross-table consistency: both manager and employee exist
SELECT *
FROM staging_org_edges e
LEFT JOIN staging_employee m
ON e.source_manager_id = m.employee_id OR e.source_manager_id = -1
LEFT JOIN staging_employee t
ON e.target_employee_id = t.employee_id
WHERE m.employee_id IS NULL OR t.employee_id IS NULL;

-- staging_promotions:

-- Standardize text
UPDATE staging_promotions
SET
    from_level = initcap(TRIM(from_level)),
    to_level = initcap(TRIM(to_level));

-- Ensure date type
ALTER TABLE staging_promotions MODIFY promotion_date DATE;

-- Cross-table consistency: employee exists
SELECT p.employee_id
FROM staging_promotions p
LEFT JOIN staging_employee e
ON p.employee_id = e.employee_id
WHERE e.employee_id IS NULL;

-- staging_salaries_annual: 

-- Standardize text
UPDATE staging_salaries_annual
SET seniority_level = initcap(TRIM(seniority_level));

-- Ensure numeric type
ALTER TABLE staging_salaries_annual MODIFY salary_usd DECIMAL(12,2);

-- Cross-table consistency: employee exists
SELECT s.employee_id
FROM staging_salaries_annual s
LEFT JOIN staging_employee e
ON s.employee_id = e.employee_id
WHERE e.employee_id IS NULL;











							

