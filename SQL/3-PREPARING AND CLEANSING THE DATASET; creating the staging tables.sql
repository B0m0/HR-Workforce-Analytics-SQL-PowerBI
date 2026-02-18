                                
								-- PREPARING AND CLEANSING THE DATASET:
                                
                                
                                -- Creating the staging_tables:
-- 1️ Staging table: departments
CREATE TABLE IF NOT EXISTS staging_departments AS
SELECT * FROM departments;

-- 2️ Staging table: employee
CREATE TABLE IF NOT EXISTS staging_employee AS
SELECT * FROM employee;

-- 3️ Staging table: location
CREATE TABLE IF NOT EXISTS staging_location AS
SELECT * FROM location;

-- 4️ Staging table: org_edges
CREATE TABLE IF NOT EXISTS staging_org_edges AS
SELECT * FROM org_edges;

-- 5️ Staging table: promotions
CREATE TABLE IF NOT EXISTS staging_promotions AS
SELECT * FROM promotions;

-- 6️ Staging table: salaries_annual
CREATE TABLE IF NOT EXISTS staging_salaries_annual AS
SELECT * FROM salaries_annual;


-- Check row counts for each staging table
SELECT 'departments', COUNT(*) FROM staging_departments;
SELECT 'employee', COUNT(*) FROM staging_employee;
SELECT 'location', COUNT(*) FROM staging_location;
SELECT 'org_edges', COUNT(*) FROM staging_org_edges;
SELECT 'promotions', COUNT(*) FROM staging_promotions;
SELECT 'salaries_annual', COUNT(*) FROM staging_salaries_annual;



