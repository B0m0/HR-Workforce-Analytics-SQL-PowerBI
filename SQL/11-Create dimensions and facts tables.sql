                              -- CREATE DIMENSIONS AND FACTS TABLES:
                              
CREATE TABLE dim_department (
    department_id INT PRIMARY KEY,
    department VARCHAR(100),
    category VARCHAR(50)
);

INSERT INTO dim_department (department_id, department, category)
SELECT department_id, department, category
FROM staging_departments;
CREATE TABLE dim_location (
    location_id INT PRIMARY KEY,
    country VARCHAR(100),
    city VARCHAR(100),
    cost_index DECIMAL(4,2)
);

INSERT INTO dim_location (location_id, country, city, cost_index)
SELECT location_id, country, city, cost_index
FROM staging_location;

CREATE TABLE dim_employee (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender ENUM('Male','Female','Non-binary'),
    age INT,
    department_id INT,
    location_id INT,
    education VARCHAR(50),
    hire_date DATE,
    work_mode ENUM('On-site','Hybrid','Remote'),
    manager_id INT,
    FOREIGN KEY(department_id) REFERENCES dim_department(department_id),
    FOREIGN KEY(location_id) REFERENCES dim_location(location_id)
    -- manager_id FK will be added later
);
INSERT INTO dim_employee (employee_id, name, gender, age, department_id, location_id, education, hire_date, work_mode)
SELECT employee_id, name, gender, age, department_id, location_id, education, hire_date, work_mode
FROM staging_employee;
SELECT DISTINCT manager_id
FROM staging_employee
WHERE manager_id IS NOT NULL
  AND manager_id NOT IN (SELECT employee_id FROM staging_employee);
UPDATE dim_employee e
JOIN staging_employee s ON e.employee_id = s.employee_id
SET e.manager_id = CASE
    WHEN s.manager_id IN (SELECT employee_id FROM staging_employee) THEN s.manager_id
    ELSE NULL
END;
ALTER TABLE dim_employee
ADD CONSTRAINT fk_manager
FOREIGN KEY(manager_id) REFERENCES dim_employee(employee_id);

-- Verify all employees
SELECT * FROM dim_employee;

-- Verify managers
SELECT e.employee_id, e.manager_id, m.name AS manager_name
FROM dim_employee e
LEFT JOIN dim_employee m ON e.manager_id = m.employee_id;

CREATE TABLE fact_salary (
    employee_id INT,
    year YEAR,
    seniority_level VARCHAR(50),
    salary_usd DECIMAL(12,2),
    PRIMARY KEY(employee_id, year),
    FOREIGN KEY(employee_id) REFERENCES dim_employee(employee_id)
);

INSERT INTO fact_salary (employee_id, year, seniority_level, salary_usd)
SELECT employee_id, year, seniority_level, salary_usd
FROM staging_salaries_annual;
CREATE TABLE fact_promotion (
    employee_id INT,
    promotion_date DATE,
    from_level VARCHAR(50),
    to_level VARCHAR(50),
    PRIMARY KEY(employee_id, promotion_date),
    FOREIGN KEY(employee_id) REFERENCES dim_employee(employee_id)
);

INSERT INTO fact_promotion (employee_id, promotion_date, from_level, to_level)
SELECT employee_id, promotion_date, from_level, to_level
FROM staging_promotions;
CREATE TABLE fact_org_edges (
    source_manager_id INT,
    target_employee_id INT,
    PRIMARY KEY(source_manager_id, target_employee_id),
    FOREIGN KEY(source_manager_id) REFERENCES dim_employee(employee_id),
    FOREIGN KEY(target_employee_id) REFERENCES dim_employee(employee_id)
);

-- Step 1: Set missing managers/employees to NULL or remove invalid rows
INSERT INTO fact_org_edges (source_manager_id, target_employee_id)
SELECT source_manager_id, target_employee_id
FROM staging_org_edges s
WHERE source_manager_id IN (SELECT employee_id FROM dim_employee)
  AND target_employee_id IN (SELECT employee_id FROM dim_employee);
  CREATE TABLE fact_performance (
    employee_id INT,
    evaluation_date DATE,
    performance_score DECIMAL(3,2),
    satisfaction_score DECIMAL(3,2),
    PRIMARY KEY(employee_id, evaluation_date),
    FOREIGN KEY(employee_id) REFERENCES dim_employee(employee_id)
);
INSERT INTO fact_performance (employee_id, evaluation_date, performance_score, satisfaction_score)
SELECT employee_id, CURDATE(), performance_score, satisfaction_score
FROM staging_employee;




























