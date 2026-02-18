                           -- Create database and tables:

Create database HR_Firm;
Use HR_Firm;
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE location (
    location_id INT PRIMARY KEY,
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    cost_index DECIMAL(4,2) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gender ENUM('Male', 'Female', 'Non-binary') NOT NULL,
    age INT CHECK (age >= 18),
    department_id INT,
    location_id INT,
    seniority VARCHAR(50),
    education VARCHAR(50),
    hire_date DATE,
    work_mode ENUM('On-site', 'Hybrid', 'Remote'),
    performance_score DECIMAL(3,2),
    satisfaction_score DECIMAL(3,2),
    initial_salary_usd DECIMAL(12,2),
    manager_id INT,
    
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id),
        
    CONSTRAINT fk_employee_location
        FOREIGN KEY (location_id) REFERENCES location(location_id)
) ENGINE=InnoDB;
CREATE TABLE org_edges (
    source_manager_id INT,
    target_employee_id INT,
    
    PRIMARY KEY (source_manager_id, target_employee_id),
    
    CONSTRAINT fk_org_employee
        FOREIGN KEY (target_employee_id) REFERENCES employee(employee_id)
) ENGINE=InnoDB;
CREATE TABLE promotions (
    employee_id INT,
    promotion_date DATE,
    from_level VARCHAR(50),
    to_level VARCHAR(50),
    
    PRIMARY KEY (employee_id, promotion_date),
    
    CONSTRAINT fk_promotion_employee
        FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=InnoDB;
CREATE TABLE salaries_annual (
    employee_id INT,
    year YEAR,
    seniority_level VARCHAR(50),
    salary_usd DECIMAL(12,2),
    
    PRIMARY KEY (employee_id, year),
    
    CONSTRAINT fk_salary_employee
        FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=InnoDB;

              -- Loading dataset using Python; 
CREATE USER 'yono'@'localhost' IDENTIFIED BY 'Bomo1234';
GRANT ALL PRIVILEGES ON Hr_firm.* TO 'yono'@'localhost';
FLUSH PRIVILEGES;  






