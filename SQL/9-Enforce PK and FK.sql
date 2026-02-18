                                  -- PREPARING AND CLEANSING THE DATASET:
                                  
                                  
                                  
                                  -- ENFORCE PK and FK:
                                  
                                  
-- DATA INTEGRITY PRE-CHECKS
SELECT DISTINCT e.department_id
FROM staging_employee e
LEFT JOIN staging_departments d
  ON e.department_id = d.department_id
WHERE d.department_id IS NULL;
SELECT DISTINCT e.location_id
FROM staging_employee e
LEFT JOIN staging_location l
  ON e.location_id = l.location_id
WHERE l.location_id IS NULL;
SELECT DISTINCT oe.target_employee_id
FROM staging_org_edges oe
LEFT JOIN staging_employee e
  ON oe.target_employee_id = e.employee_id
WHERE e.employee_id IS NULL;
SELECT DISTINCT oe.source_manager_id
FROM staging_org_edges oe
LEFT JOIN staging_employee e
  ON oe.source_manager_id = e.employee_id
WHERE e.employee_id IS NULL;
SELECT DISTINCT p.employee_id
FROM staging_promotions p
LEFT JOIN staging_employee e
  ON p.employee_id = e.employee_id
WHERE e.employee_id IS NULL;
SELECT DISTINCT s.employee_id
FROM staging_salaries_annual s
LEFT JOIN staging_employee e
  ON s.employee_id = e.employee_id
WHERE e.employee_id IS NULL;

-- IDENTIFY WHERE PKs

SELECT table_name, constraint_name
FROM information_schema.table_constraints
WHERE constraint_schema = DATABASE()
  AND constraint_type = 'PRIMARY KEY'
  AND table_name IN (
    'staging_departments',
    'staging_employee',
    'staging_location',
    'staging_org_edges',
    'staging_promotions',
    'staging_salaries_annual'
  );
ALTER TABLE staging_departments DROP PRIMARY KEY;
ALTER TABLE staging_location DROP PRIMARY KEY;
ALTER TABLE staging_employee DROP PRIMARY KEY;
ALTER TABLE staging_promotions DROP PRIMARY KEY;
ALTER TABLE staging_org_edges DROP PRIMARY KEY;
ALTER TABLE staging_salaries_annual DROP PRIMARY KEY;

-- DATA VALIDATION;Check duplicates that would break PKs
SELECT department_id, COUNT(*)
FROM staging_departments
GROUP BY department_id
HAVING COUNT(*) > 1;
SELECT location_id, COUNT(*)
FROM staging_location
GROUP BY location_id
HAVING COUNT(*) > 1;
SELECT employee_id, COUNT(*)
FROM staging_employee
GROUP BY employee_id
HAVING COUNT(*) > 1;
SELECT source_manager_id, target_employee_id, COUNT(*)
FROM staging_org_edges
GROUP BY source_manager_id, target_employee_id
HAVING COUNT(*) > 1;
SELECT employee_id, promotion_date, COUNT(*)
FROM staging_promotions
GROUP BY employee_id, promotion_date
HAVING COUNT(*) > 1;
SELECT employee_id, year, COUNT(*)
FROM staging_salaries_annual
GROUP BY employee_id, year
HAVING COUNT(*) > 1;

-- FK COMPATIBILITY CHECK :
-- Employee → Departments
SELECT DISTINCT e.department_id
FROM staging_employee e
LEFT JOIN staging_departments d
  ON e.department_id = d.department_id
WHERE d.department_id IS NULL;
-- Employee → Location
SELECT DISTINCT e.location_id
FROM staging_employee e
LEFT JOIN staging_location l
  ON e.location_id = l.location_id
WHERE l.location_id IS NULL;
-- Manager (self-reference)
SELECT DISTINCT manager_id
FROM staging_employee
WHERE manager_id IS NOT NULL
  AND manager_id NOT IN (SELECT employee_id FROM staging_employee);
-- Promotions → Employee
SELECT DISTINCT p.employee_id
FROM staging_promotions p
LEFT JOIN staging_employee e
  ON p.employee_id = e.employee_id
WHERE e.employee_id IS NULL;
-- Salaries → Employee
SELECT DISTINCT s.employee_id
FROM staging_salaries_annual s
LEFT JOIN staging_employee e
  ON s.employee_id = e.employee_id
WHERE e.employee_id IS NULL;
-- Org edges → Employee
SELECT DISTINCT source_manager_id
FROM staging_org_edges
WHERE source_manager_id NOT IN (SELECT employee_id FROM staging_employee);

SELECT DISTINCT target_employee_id
FROM staging_org_edges
WHERE target_employee_id NOT IN (SELECT employee_id FROM staging_employee);

-- ENFORCE PRIMARY KEYS

ALTER TABLE staging_departments
ADD CONSTRAINT pk_staging_departments
PRIMARY KEY (department_id);

ALTER TABLE staging_location
ADD CONSTRAINT pk_staging_location
PRIMARY KEY (location_id);

ALTER TABLE staging_employee
ADD CONSTRAINT pk_staging_employee
PRIMARY KEY (employee_id);

ALTER TABLE staging_org_edges
ADD CONSTRAINT pk_staging_org_edges
PRIMARY KEY (source_manager_id, target_employee_id);

ALTER TABLE staging_promotions
ADD CONSTRAINT pk_staging_promotions
PRIMARY KEY (employee_id, promotion_date);

ALTER TABLE staging_salaries_annual
ADD CONSTRAINT pk_staging_salaries_annual
PRIMARY KEY (employee_id, year);

-- CREATE REQUIRED INDEXES:

CREATE INDEX idx_employee_department
ON staging_employee (department_id);

CREATE INDEX idx_employee_location
ON staging_employee (location_id);

CREATE INDEX idx_employee_manager
ON staging_employee (manager_id);

CREATE INDEX idx_org_edges_source
ON staging_org_edges (source_manager_id);

CREATE INDEX idx_org_edges_target
ON staging_org_edges (target_employee_id);

CREATE INDEX idx_promotions_employee
ON staging_promotions (employee_id);

CREATE INDEX idx_salaries_employee
ON staging_salaries_annual (employee_id);

-- ENFORCE FOREIGN KEYS:

-- Employee → Departments
ALTER TABLE staging_employee
ADD CONSTRAINT fk_employee_department
FOREIGN KEY (department_id)
REFERENCES staging_departments (department_id);
-- Employee → Location
ALTER TABLE staging_employee
ADD CONSTRAINT fk_employee_location
FOREIGN KEY (location_id)
REFERENCES staging_location (location_id);
-- Employee → Manager (self-FK)
ALTER TABLE staging_employee
ADD CONSTRAINT fk_employee_manager
FOREIGN KEY (manager_id)
REFERENCES staging_employee (employee_id);
-- Org edges → Employee
ALTER TABLE staging_org_edges
ADD CONSTRAINT fk_org_edges_manager
FOREIGN KEY (source_manager_id)
REFERENCES staging_employee (employee_id);

ALTER TABLE staging_org_edges
ADD CONSTRAINT fk_org_edges_employee
FOREIGN KEY (target_employee_id)
REFERENCES staging_employee (employee_id);
-- Promotions → Employee
ALTER TABLE staging_promotions
ADD CONSTRAINT fk_promotions_employee
FOREIGN KEY (employee_id)
REFERENCES staging_employee (employee_id);
-- Salaries → Employee
ALTER TABLE staging_salaries_annual
ADD CONSTRAINT fk_salaries_employee
FOREIGN KEY (employee_id)
REFERENCES staging_employee (employee_id);

























  













