BEGIN
   FOR rec
   IN (SELECT table_name, constraint_name
         FROM user_constraints
        WHERE table_name IN
                    ('EMPLOYEES'
                   , 'DEPARTMENTS'
                   , 'JOBS'
                   , 'COUNTRIES'
                   , 'REGIONS'
                   , 'LOCATIONS'
                   , 'JOB_HISTORY'))
   LOOP
      BEGIN
         DBMS_OUTPUT.put_line(   'alter table '
                              || rec.table_name
                              || ' '
                              || 'disable constraint '
                              || rec.constraint_name);

         EXECUTE IMMEDIATE   'alter table '
                          || rec.table_name
                          || ' '
                          || 'disable constraint '
                          || rec.constraint_name;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (SQLERRM);
      END;
   END LOOP;
END set_constraints;
/

DROP    TABLE job_history
/
DROP TABLE employees
/
DROP TABLE departments
/
DROP TABLE regions
/
DROP TABLE countries
/
DROP TABLE locations
/
DROP TABLE jobs
/

CREATE TABLE regions
(
   region_id     NUMBER CONSTRAINT region_id_nn NOT NULL
 , region_name   VARCHAR2 (25)
)
/

CREATE TABLE countries
(
   country_id     CHAR (2) CONSTRAINT country_id_nn NOT NULL
 , country_name   VARCHAR2 (40)
 , region_id      NUMBER
 , CONSTRAINT country_c_id_pk PRIMARY KEY (country_id)
)
/

COMMENT ON TABLE countries IS
'country table. Contains 25 rows. References with locations table.'
/

COMMENT ON COLUMN countries.country_id IS 'Primary key of countries table.'
/

COMMENT ON COLUMN countries.country_name IS 'Country name'
/

COMMENT ON COLUMN countries.region_id IS
'Region ID for the country. Foreign key to region_id column in the departments table.'
/

CREATE TABLE locations
(
   location_id      NUMBER (4)
 , street_address   VARCHAR2 (40)
 , postal_code      VARCHAR2 (12)
 , city             VARCHAR2 (30) CONSTRAINT loc_city_nn NOT NULL
 , state_province   VARCHAR2 (25)
 , country_id       CHAR (2)
)
/

COMMENT ON TABLE locations IS
'Locations table that contains specific address of a specific office,
warehouse, and/or production site of a company. Does not store addresses /
locations of customers. Contains 23 rows; references with the
departments and countries tables. '
/

COMMENT ON COLUMN locations.location_id IS 'Primary key of locations table'
/

COMMENT ON COLUMN locations.street_address IS
'Street address of an office, warehouse, or production site of a company.
Contains building number and street name'
/

COMMENT ON COLUMN locations.postal_code IS
'Postal code of the location of an office, warehouse, or production site
of a company. '
/

COMMENT ON COLUMN locations.city IS
'A not null column that shows city where an office, warehouse, or
production site of a company is located. '
/

COMMENT ON COLUMN locations.state_province IS
'State or Province where an office, warehouse, or production site of a
company is located.'
/

COMMENT ON COLUMN locations.country_id IS
'Country where an office, warehouse, or production site of a company is
located. Foreign key to country_id column of the countries table.'
/

CREATE TABLE departments
(
   department_id     NUMBER (4)
 , department_name   VARCHAR2 (30) CONSTRAINT dept_name_nn NOT NULL
 , manager_id        NUMBER (6)
 , location_id       NUMBER (4)
)
/

COMMENT ON TABLE departments IS
'Departments table that shows details of departments where employees
work. Contains 27 rows; references with locations, employees, and job_history tables.'
/

COMMENT ON COLUMN departments.department_id IS
'Primary key column of departments table.'
/

COMMENT ON COLUMN departments.department_name IS
'A not null column that shows name of a department. Administration,
Marketing, Purchasing, Human Resources, Shipping, IT, Executive, Public
Relations, Sales, Finance, and Accounting. '
/

COMMENT ON COLUMN departments.manager_id IS
'Manager_id of a department. Foreign key to employee_id column of employees table. The manager_id column of the employee table references this column.'
/

COMMENT ON COLUMN departments.location_id IS
'Location id where a department is located. Foreign key to location_id column of locations table.'
/

CREATE TABLE jobs
(
   job_id       VARCHAR2 (10)
 , job_title    VARCHAR2 (35) CONSTRAINT job_title_nn NOT NULL
 , min_salary   NUMBER (6)
 , max_salary   NUMBER (6)
)
/

COMMENT ON TABLE jobs IS
'jobs table with job titles and salary ranges. Contains 19 rows.
References with employees and job_history table.'
/

COMMENT ON COLUMN jobs.job_id IS 'Primary key of jobs table.'
/

COMMENT ON COLUMN jobs.job_title IS
'A not null column that shows job title, e.g. AD_VP, FI_ACCOUNTANT'
/

COMMENT ON COLUMN jobs.min_salary IS 'Minimum salary for a job title.'
/

COMMENT ON COLUMN jobs.max_salary IS 'Maximum salary for a job title'
/

CREATE TABLE employees
(
   employee_id      NUMBER (6)
 , first_name       VARCHAR2 (20) NOT NULL
 , last_name        VARCHAR2 (25) CONSTRAINT emp_last_name_nn NOT NULL
 , email            VARCHAR2 (25) CONSTRAINT emp_email_nn NOT NULL
 , phone_number     VARCHAR2 (20)
 , hire_date        DATE CONSTRAINT emp_hire_date_nn NOT NULL
 , job_id           VARCHAR2 (10) CONSTRAINT emp_job_nn NOT NULL
 , salary           NUMBER (8, 2)
 , commission_pct   NUMBER (2, 2)
 , manager_id       NUMBER (6)
 , department_id    NUMBER (4)
)
/

COMMENT ON TABLE employees IS
'employees table. Contains 107 rows. References with departments,
jobs, job_history tables. Contains a self reference.'
/

COMMENT ON COLUMN employees.employee_id IS 'Primary key of employees table.'
/

COMMENT ON COLUMN employees.first_name IS
'First name of the employee. A not null column.'
/

COMMENT ON COLUMN employees.last_name IS
'Last name of the employee. A not null column.'
/

COMMENT ON COLUMN employees.email IS 'Email id of the employee'
/

COMMENT ON COLUMN employees.phone_number IS
'Phone number of the employee; includes country code and area code'
/

COMMENT ON COLUMN employees.hire_date IS
'Date when the employee started on this job. A not null column.'
/

COMMENT ON COLUMN employees.job_id IS
'Current job of the employee; foreign key to job_id column of the
jobs table. A not null column.'
/

COMMENT ON COLUMN employees.salary IS
'Monthly salary of the employee. Must be greater
than zero (enforced by constraint emp_salary_min)'
/

COMMENT ON COLUMN employees.commission_pct IS
'Commission percentage of the employee; Only employees in sales
department elgible for commission percentage'
/

COMMENT ON COLUMN employees.manager_id IS
'Manager id of the employee; has same domain as manager_id in
departments table. Foreign key to employee_id column of employees table.
(useful for reflexive joins and CONNECT BY query)'
/

COMMENT ON COLUMN employees.department_id IS
'Department id where employee works; foreign key to department_id
column of the departments table'
/

CREATE TABLE job_history
(
   employee_id     NUMBER (6) CONSTRAINT jhist_employee_nn NOT NULL
 , start_date      DATE CONSTRAINT jhist_start_date_nn NOT NULL
 , end_date        DATE CONSTRAINT jhist_end_date_nn NOT NULL
 , job_id          VARCHAR2 (10) CONSTRAINT jhist_job_nn NOT NULL
 , department_id   NUMBER (4)
)
/

COMMENT ON TABLE job_history IS
'Table that stores job history of the employees. If an employee
changes departments within the job or changes jobs within the department,
new rows get inserted into this table with old job information of the
employee. Contains a complex primary key: employee_id+start_date.
Contains 25 rows. References with jobs, employees, and departments tables.'
/

COMMENT ON COLUMN job_history.employee_id IS
'A not null column in the complex primary key employee_id+start_date.
Foreign key to employee_id column of the employee table'
/

COMMENT ON COLUMN job_history.start_date IS
'A not null column in the complex primary key employee_id+start_date.
Must be less than the end_date of the job_history table. (enforced by
constraint jhist_date_interval)'
/

COMMENT ON COLUMN job_history.end_date IS
'Last day of the employee in this job role. A not null column. Must be
greater than the start_date of the job_history table.
(enforced by constraint jhist_date_interval)'
/

COMMENT ON COLUMN job_history.job_id IS
'Job role in which the employee worked in the past; foreign key to
job_id column in the jobs table. A not null column.'
/

COMMENT ON COLUMN job_history.department_id IS
'Department id in which the employee worked in the past; foreign key to deparment_id column in the departments table'
/

BEGIN
   INSERT INTO regions (region_id, region_name
                       )
       VALUES (1, 'Europe'
              );

   INSERT INTO regions (region_id, region_name
                       )
       VALUES (2, 'Americas'
              );

   INSERT INTO regions (region_id, region_name
                       )
       VALUES (3, 'Asia'
              );

   INSERT INTO regions (region_id, region_name
                       )
       VALUES (4, 'Middle East and Africa'
              );

   COMMIT;

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('AR', 'Argentina', 2
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('AU', 'Australia', 3
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('BE', 'Belgium', 1
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('BR', 'Brazil', 2
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('CA', 'Canada', 2
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('CH', 'Switzerland', 1
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('CN', 'China', 3
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('DE', 'Germany', 1
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('DK', 'Denmark', 1
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('EG', 'Egypt', 4
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('FR', 'France', 1
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('HK', 'HongKong', 3
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('IL', 'Israel', 4
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('IN', 'India', 3
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('IT', 'Italy', 1
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('JP', 'Japan', 3
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('KW', 'Kuwait', 4
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('MX', 'Mexico', 2
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('NG', 'Nigeria', 4
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('NL', 'Netherlands', 1
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('SG', 'Singapore', 3
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('UK', 'United Kingdom', 1
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('US', 'United States of America', 2
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('ZM', 'Zambia', 4
              );

   INSERT INTO countries (country_id, country_name, region_id
                         )
       VALUES ('ZW', 'Zimbabwe', 4
              );

   COMMIT;

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (1000, '1297 Via Cola di Rie', '00989', 'Roma', NULL, 'IT'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (1100, '93091 Calle della Testa', '10934', 'Venice', NULL, 'IT'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  1200
                , '2017 Shinjuku-ku'
                , '1689'
                , 'Tokyo'
                , 'Tokyo Prefecture'
                , 'JP'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (1300, '9450 Kamiya-cho', '6823', 'Hiroshima', NULL, 'JP'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (1400, '2014 Jabberwocky Rd', '26192', 'Southlake', 'Texas', 'US'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  1500
                , '2011 Interiors Blvd'
                , '99236'
                , 'South San Francisco'
                , 'California'
                , 'US'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  1600
                , '2007 Zagora St'
                , '50090'
                , 'South Brunswick'
                , 'New Jersey'
                , 'US'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (1700, '2004 Charade Rd', '98199', 'Seattle', 'Washington', 'US'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (1800, '147 Spadina Ave', 'M5V 2L7', 'Toronto', 'Ontario', 'CA'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (1900, '6092 Boxwood St', 'YSW 9T2', 'Whitehorse', 'Yukon', 'CA'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (2000, '40-5-12 Laogianggen', '190518', 'Beijing', NULL, 'CN'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  2100
                , '1298 Vileparle (E)'
                , '490231'
                , 'Bombay'
                , 'Maharashtra'
                , 'IN'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  2200
                , '12-98 Victoria Street'
                , '2901'
                , 'Sydney'
                , 'New South Wales'
                , 'AU'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (2300, '198 Clementi North', '540198', 'Singapore', NULL, 'SG'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (2400, '8204 Arthur St', NULL, 'London', NULL, 'UK'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  2500
                , 'Magdalen Centre, The Oxford Science Park'
                , 'OX9 9ZB'
                , 'Oxford'
                , 'Oxford'
                , 'UK'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  2600
                , '9702 Chester Road'
                , '09629850293'
                , 'Stretford'
                , 'Manchester'
                , 'UK'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  2700
                , 'Schwanthalerstr. 7031'
                , '80925'
                , 'Munich'
                , 'Bavaria'
                , 'DE'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  2800
                , 'Rua Frei Caneca 1360 '
                , '01307-002'
                , 'Sao Paulo'
                , 'Sao Paulo'
                , 'BR'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  2900
                , '20 Rue des Corps-Saints'
                , '1730'
                , 'Geneva'
                , 'Geneve'
                , 'CH'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (3000, 'Murtenstrasse 921', '3095', 'Bern', 'BE', 'CH'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  3100
                , 'Pieter Breughelstraat 837'
                , '3029SK'
                , 'Utrecht'
                , 'Utrecht'
                , 'NL'
              );

   INSERT INTO locations (
                             location_id
                           , street_address
                           , postal_code
                           , city
                           , state_province
                           , country_id
              )
       VALUES (
                  3200
                , 'Mariano Escobedo 9991'
                , '11932'
                , 'Mexico City'
                , 'Distrito Federal,'
                , 'MX'
              );

   COMMIT;

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('AD_PRES', 'President', 20000, 40000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('AD_VP', 'Administration Vice President', 15000, 30000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('AD_ASST', 'Administration Assistant', 3000, 6000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('FI_MGR', 'Finance Manager', 8200, 16000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('FI_ACCOUNT', 'Accountant', 4200, 9000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('AC_MGR', 'Accounting Manager', 8200, 16000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('AC_ACCOUNT', 'Public Accountant', 4200, 9000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('SA_MAN', 'Sales Manager', 10000, 20000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('SA_REP', 'Sales Representative', 6000, 12000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('PU_MAN', 'Purchasing Manager', 8000, 15000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('PU_CLERK', 'Purchasing Clerk', 2500, 5500
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('ST_MAN', 'Stock Manager', 5500, 8500
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('ST_CLERK', 'Stock Clerk', 2000, 5000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('SH_CLERK', 'Shipping Clerk', 2500, 5500
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('IT_PROG', 'Programmer', 4000, 10000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('MK_MAN', 'Marketing Manager', 9000, 15000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('MK_REP', 'Marketing Representative', 4000, 9000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('HR_REP', 'Human Resources Representative', 4000, 9000
              );

   INSERT INTO jobs (job_id, job_title, min_salary, max_salary
                    )
       VALUES ('PR_REP', 'Public Relations Representative', 4500, 10500
              );

   COMMIT;

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (10, 'Administration', 200, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (20, 'Marketing', 201, 1800
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (30, 'Purchasing', 114, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (40, 'Human Resources', 203, 2400
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (50, 'Shipping', 121, 1500
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (60, 'IT', 103, 1400
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (70, 'Public Relations', 204, 2700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (80, 'Sales', 145, 2500
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (90, 'Executive', 100, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (100, 'Finance', 108, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (110, 'Accounting', 205, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (120, 'Treasury', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (130, 'Corporate Tax', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (140, 'Control And Credit', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (150, 'Shareholder Services', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (160, 'Benefits', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (170, 'Manufacturing', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (180, 'Construction', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (190, 'Contracting', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (200, 'Operations', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (210, 'IT Support', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (220, 'NOC', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (230, 'IT Helpdesk', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (240, 'Government Sales', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (250, 'Retail Sales', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (260, 'Recruiting', NULL, 1700
              );

   INSERT INTO departments (
                               department_id
                             , department_name
                             , manager_id
                             , location_id
              )
       VALUES (270, 'Payroll', NULL, 1700
              );

   COMMIT;

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  100
                , 'Steven'
                , 'King'
                , 'SKING'
                , '515.123.4567'
                , TO_DATE ('06/17/1987 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'AD_PRES'
                , 24000
                , NULL
                , NULL
                , 90
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  101
                , 'Neena'
                , 'Kochhar'
                , 'NKOCHHAR'
                , '515.123.4568'
                , TO_DATE ('09/21/1989 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'AD_VP'
                , 17000
                , NULL
                , 100
                , 90
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  102
                , 'Lex'
                , 'De Haan'
                , 'LDEHAAN'
                , '515.123.4569'
                , TO_DATE ('01/13/1993 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'AD_VP'
                , 17000
                , NULL
                , 100
                , 90
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  103
                , 'Alexander'
                , 'Hunold'
                , 'AHUNOLD'
                , '590.423.4567'
                , TO_DATE ('01/03/1990 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'IT_PROG'
                , 9000
                , NULL
                , 102
                , 60
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  104
                , 'Bruce'
                , 'Ernst'
                , 'BERNST'
                , '590.423.4568'
                , TO_DATE ('05/21/1991 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'IT_PROG'
                , 6000
                , NULL
                , 103
                , 60
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  105
                , 'David'
                , 'Austin'
                , 'DAUSTIN'
                , '590.423.4569'
                , TO_DATE ('06/25/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'IT_PROG'
                , 4800
                , NULL
                , 103
                , 60
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  106
                , 'Valli'
                , 'Pataballa'
                , 'VPATABAL'
                , '590.423.4560'
                , TO_DATE ('02/05/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'IT_PROG'
                , 4800
                , NULL
                , 103
                , 60
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  107
                , 'Diana'
                , 'Lorentz'
                , 'DLORENTZ'
                , '590.423.5567'
                , TO_DATE ('02/07/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'IT_PROG'
                , 4200
                , NULL
                , 103
                , 60
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  108
                , 'Nancy'
                , 'Greenberg'
                , 'NGREENBE'
                , '515.124.4569'
                , TO_DATE ('08/17/1994 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'FI_MGR'
                , 12000
                , NULL
                , 101
                , 100
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  109
                , 'Daniel'
                , 'Faviet'
                , 'DFAVIET'
                , '515.124.4169'
                , TO_DATE ('08/16/1994 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'FI_ACCOUNT'
                , 9000
                , NULL
                , 108
                , 100
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  110
                , 'John'
                , 'Chen'
                , 'JCHEN'
                , '515.124.4269'
                , TO_DATE ('09/28/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'FI_ACCOUNT'
                , 8200
                , NULL
                , 108
                , 100
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  111
                , 'Ismael'
                , 'Sciarra'
                , 'ISCIARRA'
                , '515.124.4369'
                , TO_DATE ('09/30/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'FI_ACCOUNT'
                , 7700
                , NULL
                , 108
                , 100
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  112
                , 'Jose Manuel'
                , 'Urman'
                , 'JMURMAN'
                , '515.124.4469'
                , TO_DATE ('03/07/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'FI_ACCOUNT'
                , 7800
                , NULL
                , 108
                , 100
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  113
                , 'Luis'
                , 'Popp'
                , 'LPOPP'
                , '515.124.4567'
                , TO_DATE ('12/07/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'FI_ACCOUNT'
                , 6900
                , NULL
                , 108
                , 100
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  114
                , 'Den'
                , 'Raphaely'
                , 'DRAPHEAL'
                , '515.127.4561'
                , TO_DATE ('12/07/1994 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'PU_MAN'
                , 11000
                , NULL
                , 100
                , 30
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  115
                , 'Alexander'
                , 'Khoo'
                , 'AKHOO'
                , '515.127.4562'
                , TO_DATE ('05/18/1995 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'PU_CLERK'
                , 3100
                , NULL
                , 114
                , 30
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  116
                , 'Shelli'
                , 'Baida'
                , 'SBAIDA'
                , '515.127.4563'
                , TO_DATE ('12/24/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'PU_CLERK'
                , 2900
                , NULL
                , 114
                , 30
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  117
                , 'Sigal'
                , 'Tobias'
                , 'STOBIAS'
                , '515.127.4564'
                , TO_DATE ('07/24/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'PU_CLERK'
                , 2800
                , NULL
                , 114
                , 30
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  118
                , 'Guy'
                , 'Himuro'
                , 'GHIMURO'
                , '515.127.4565'
                , TO_DATE ('11/15/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'PU_CLERK'
                , 2600
                , NULL
                , 114
                , 30
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  119
                , 'Karen'
                , 'Colmenares'
                , 'KCOLMENA'
                , '515.127.4566'
                , TO_DATE ('08/10/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'PU_CLERK'
                , 2500
                , NULL
                , 114
                , 30
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  120
                , 'Matthew'
                , 'Weiss'
                , 'MWEISS'
                , '650.123.1234'
                , TO_DATE ('07/18/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_MAN'
                , 8000
                , NULL
                , 100
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  121
                , 'Adam'
                , 'Fripp'
                , 'AFRIPP'
                , '650.123.2234'
                , TO_DATE ('04/10/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_MAN'
                , 8200
                , NULL
                , 100
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  122
                , 'Payam'
                , 'Kaufling'
                , 'PKAUFLIN'
                , '650.123.3234'
                , TO_DATE ('05/01/1995 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_MAN'
                , 7900
                , NULL
                , 100
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  123
                , 'Shanta'
                , 'Vollman'
                , 'SVOLLMAN'
                , '650.123.4234'
                , TO_DATE ('10/10/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_MAN'
                , 6500
                , NULL
                , 100
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  124
                , 'Kevin'
                , 'Mourgos'
                , 'KMOURGOS'
                , '650.123.5234'
                , TO_DATE ('11/16/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_MAN'
                , 5800
                , NULL
                , 100
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  125
                , 'Julia'
                , 'Nayer'
                , 'JNAYER'
                , '650.124.1214'
                , TO_DATE ('07/16/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 3200
                , NULL
                , 120
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  126
                , 'Irene'
                , 'Mikkilineni'
                , 'IMIKKILI'
                , '650.124.1224'
                , TO_DATE ('09/28/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2700
                , NULL
                , 120
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  127
                , 'James'
                , 'Landry'
                , 'JLANDRY'
                , '650.124.1334'
                , TO_DATE ('01/14/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2400
                , NULL
                , 120
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  128
                , 'Steven'
                , 'Markle'
                , 'SMARKLE'
                , '650.124.1434'
                , TO_DATE ('03/08/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2200
                , NULL
                , 120
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  129
                , 'Laura'
                , 'Bissot'
                , 'LBISSOT'
                , '650.124.5234'
                , TO_DATE ('08/20/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 3300
                , NULL
                , 121
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  130
                , 'Mozhe'
                , 'Atkinson'
                , 'MATKINSO'
                , '650.124.6234'
                , TO_DATE ('10/30/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2800
                , NULL
                , 121
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  131
                , 'James'
                , 'Marlow'
                , 'JAMRLOW'
                , '650.124.7234'
                , TO_DATE ('02/16/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2500
                , NULL
                , 121
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  132
                , 'TJ'
                , 'Olson'
                , 'TJOLSON'
                , '650.124.8234'
                , TO_DATE ('04/10/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2100
                , NULL
                , 121
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  133
                , 'Jason'
                , 'Mallin'
                , 'JMALLIN'
                , '650.127.1934'
                , TO_DATE ('06/14/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 3300
                , NULL
                , 122
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  134
                , 'Michael'
                , 'Rogers'
                , 'MROGERS'
                , '650.127.1834'
                , TO_DATE ('08/26/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2900
                , NULL
                , 122
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  135
                , 'Ki'
                , 'Gee'
                , 'KGEE'
                , '650.127.1734'
                , TO_DATE ('12/12/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2400
                , NULL
                , 122
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  136
                , 'Hazel'
                , 'Philtanker'
                , 'HPHILTAN'
                , '650.127.1634'
                , TO_DATE ('02/06/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2200
                , NULL
                , 122
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  137
                , 'Renske'
                , 'Ladwig'
                , 'RLADWIG'
                , '650.121.1234'
                , TO_DATE ('07/14/1995 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 3600
                , NULL
                , 123
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  138
                , 'Stephen'
                , 'Stiles'
                , 'SSTILES'
                , '650.121.2034'
                , TO_DATE ('10/26/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 3200
                , NULL
                , 123
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  139
                , 'John'
                , 'Seo'
                , 'JSEO'
                , '650.121.2019'
                , TO_DATE ('02/12/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2700
                , NULL
                , 123
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  140
                , 'Joshua'
                , 'Patel'
                , 'JPATEL'
                , '650.121.1834'
                , TO_DATE ('04/06/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2500
                , NULL
                , 123
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  141
                , 'Trenna'
                , 'Rajs'
                , 'TRAJS'
                , '650.121.8009'
                , TO_DATE ('10/17/1995 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 3500
                , NULL
                , 124
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  142
                , 'Curtis'
                , 'Davies'
                , 'CDAVIES'
                , '650.121.2994'
                , TO_DATE ('01/29/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 3100
                , NULL
                , 124
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  143
                , 'Randall'
                , 'Matos'
                , 'RMATOS'
                , '650.121.2874'
                , TO_DATE ('03/15/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2600
                , NULL
                , 124
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  144
                , 'Peter'
                , 'Vargas'
                , 'PVARGAS'
                , '650.121.2004'
                , TO_DATE ('07/09/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 2500
                , NULL
                , 124
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  145
                , 'John'
                , 'Russell'
                , 'JRUSSEL'
                , '011.44.1344.429268'
                , TO_DATE ('10/01/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_MAN'
                , 14000
                , 0.4
                , 100
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  146
                , 'Karen'
                , 'Partners'
                , 'KPARTNER'
                , '011.44.1344.467268'
                , TO_DATE ('01/05/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_MAN'
                , 13500
                , 0.3
                , 100
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  147
                , 'Alberto'
                , 'Errazuriz'
                , 'AERRAZUR'
                , '011.44.1344.429278'
                , TO_DATE ('03/10/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_MAN'
                , 12000
                , 0.3
                , 100
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  148
                , 'Gerald'
                , 'Cambrault'
                , 'GCAMBRAU'
                , '011.44.1344.619268'
                , TO_DATE ('10/15/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_MAN'
                , 11000
                , 0.3
                , 100
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  149
                , 'Eleni'
                , 'Zlotkey'
                , 'EZLOTKEY'
                , '011.44.1344.429018'
                , TO_DATE ('01/29/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_MAN'
                , 10500
                , 0.2
                , 100
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  150
                , 'Peter'
                , 'Tucker'
                , 'PTUCKER'
                , '011.44.1344.129268'
                , TO_DATE ('01/30/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 10000
                , 0.3
                , 145
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  151
                , 'David'
                , 'Bernstein'
                , 'DBERNSTE'
                , '011.44.1344.345268'
                , TO_DATE ('03/24/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 9500
                , 0.25
                , 145
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  152
                , 'Peter'
                , 'Hall'
                , 'PHALL'
                , '011.44.1344.478968'
                , TO_DATE ('08/20/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 9000
                , 0.25
                , 145
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  153
                , 'Christopher'
                , 'Olsen'
                , 'COLSEN'
                , '011.44.1344.498718'
                , TO_DATE ('03/30/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 8000
                , 0.2
                , 145
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  154
                , 'Nanette'
                , 'Cambrault'
                , 'NCAMBRAU'
                , '011.44.1344.987668'
                , TO_DATE ('12/09/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 7500
                , 0.2
                , 145
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  155
                , 'Oliver'
                , 'Tuvault'
                , 'OTUVAULT'
                , '011.44.1344.486508'
                , TO_DATE ('11/23/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 7000
                , 0.15
                , 145
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  156
                , 'Janette'
                , 'King'
                , 'JKING'
                , '011.44.1345.429268'
                , TO_DATE ('01/30/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 10000
                , 0.35
                , 146
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  157
                , 'Patrick'
                , 'Sully'
                , 'PSULLY'
                , '011.44.1345.929268'
                , TO_DATE ('03/04/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 9500
                , 0.35
                , 146
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  158
                , 'Allan'
                , 'McEwen'
                , 'AMCEWEN'
                , '011.44.1345.829268'
                , TO_DATE ('08/01/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 9000
                , 0.35
                , 146
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  159
                , 'Lindsey'
                , 'Smith'
                , 'LSMITH'
                , '011.44.1345.729268'
                , TO_DATE ('03/10/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 8000
                , 0.3
                , 146
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  160
                , 'Louise'
                , 'Doran'
                , 'LDORAN'
                , '011.44.1345.629268'
                , TO_DATE ('12/15/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 7500
                , 0.3
                , 146
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  161
                , 'Sarath'
                , 'Sewall'
                , 'SSEWALL'
                , '011.44.1345.529268'
                , TO_DATE ('11/03/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 7000
                , 0.25
                , 146
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  162
                , 'Clara'
                , 'Vishney'
                , 'CVISHNEY'
                , '011.44.1346.129268'
                , TO_DATE ('11/11/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 10500
                , 0.25
                , 147
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  163
                , 'Danielle'
                , 'Greene'
                , 'DGREENE'
                , '011.44.1346.229268'
                , TO_DATE ('03/19/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 9500
                , 0.15
                , 147
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  164
                , 'Mattea'
                , 'Marvins'
                , 'MMARVINS'
                , '011.44.1346.329268'
                , TO_DATE ('01/24/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 7200
                , 0.1
                , 147
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  165
                , 'David'
                , 'Lee'
                , 'DLEE'
                , '011.44.1346.529268'
                , TO_DATE ('02/23/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 6800
                , 0.1
                , 147
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  166
                , 'Sundar'
                , 'Ande'
                , 'SANDE'
                , '011.44.1346.629268'
                , TO_DATE ('03/24/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 6400
                , 0.1
                , 147
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  167
                , 'Amit'
                , 'Banda'
                , 'ABANDA'
                , '011.44.1346.729268'
                , TO_DATE ('04/21/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 6200
                , 0.1
                , 147
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  168
                , 'Lisa'
                , 'Ozer'
                , 'LOZER'
                , '011.44.1343.929268'
                , TO_DATE ('03/11/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 11500
                , 0.25
                , 148
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  169
                , 'Harrison'
                , 'Bloom'
                , 'HBLOOM'
                , '011.44.1343.829268'
                , TO_DATE ('03/23/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 10000
                , 0.2
                , 148
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  170
                , 'Tayler'
                , 'Fox'
                , 'TFOX'
                , '011.44.1343.729268'
                , TO_DATE ('01/24/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 9600
                , 0.2
                , 148
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  171
                , 'William'
                , 'Smith'
                , 'WSMITH'
                , '011.44.1343.629268'
                , TO_DATE ('02/23/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 7400
                , 0.15
                , 148
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  172
                , 'Elizabeth'
                , 'Bates'
                , 'EBATES'
                , '011.44.1343.529268'
                , TO_DATE ('03/24/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 7300
                , 0.15
                , 148
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  173
                , 'Sundita'
                , 'Kumar'
                , 'SKUMAR'
                , '011.44.1343.329268'
                , TO_DATE ('04/21/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 6100
                , 0.1
                , 148
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  174
                , 'Ellen'
                , 'Abel'
                , 'EABEL'
                , '011.44.1644.429267'
                , TO_DATE ('05/11/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 11000
                , 0.3
                , 149
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  175
                , 'Alyssa'
                , 'Hutton'
                , 'AHUTTON'
                , '011.44.1644.429266'
                , TO_DATE ('03/19/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 8800
                , 0.25
                , 149
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  176
                , 'Jonathon'
                , 'Taylor'
                , 'JTAYLOR'
                , '011.44.1644.429265'
                , TO_DATE ('03/24/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 8600
                , 0.2
                , 149
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  177
                , 'Jack'
                , 'Livingston'
                , 'JLIVINGS'
                , '011.44.1644.429264'
                , TO_DATE ('04/23/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 8400
                , 0.2
                , 149
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  178
                , 'Kimberely'
                , 'Grant'
                , 'KGRANT'
                , '011.44.1644.429263'
                , TO_DATE ('05/24/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 7000
                , 0.15
                , 149
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  179
                , 'Charles'
                , 'Johnson'
                , 'CJOHNSON'
                , '011.44.1644.429262'
                , TO_DATE ('01/04/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 6200
                , 0.1
                , 149
                , 80
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  180
                , 'Winston'
                , 'Taylor'
                , 'WTAYLOR'
                , '650.507.9876'
                , TO_DATE ('01/24/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 3200
                , NULL
                , 120
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  181
                , 'Jean'
                , 'Fleaur'
                , 'JFLEAUR'
                , '650.507.9877'
                , TO_DATE ('02/23/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 3100
                , NULL
                , 120
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  182
                , 'Martha'
                , 'Sullivan'
                , 'MSULLIVA'
                , '650.507.9878'
                , TO_DATE ('06/21/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 2500
                , NULL
                , 120
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  183
                , 'Girard'
                , 'Geoni'
                , 'GGEONI'
                , '650.507.9879'
                , TO_DATE ('02/03/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 2800
                , NULL
                , 120
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  184
                , 'Nandita'
                , 'Sarchand'
                , 'NSARCHAN'
                , '650.509.1876'
                , TO_DATE ('01/27/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 4200
                , NULL
                , 121
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  185
                , 'Alexis'
                , 'Bull'
                , 'ABULL'
                , '650.509.2876'
                , TO_DATE ('02/20/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 4100
                , NULL
                , 121
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  186
                , 'Julia'
                , 'Dellinger'
                , 'JDELLING'
                , '650.509.3876'
                , TO_DATE ('06/24/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 3400
                , NULL
                , 121
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  187
                , 'Anthony'
                , 'Cabrio'
                , 'ACABRIO'
                , '650.509.4876'
                , TO_DATE ('02/07/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 3000
                , NULL
                , 121
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  188
                , 'Kelly'
                , 'Chung'
                , 'KCHUNG'
                , '650.505.1876'
                , TO_DATE ('06/14/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 3800
                , NULL
                , 122
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  189
                , 'Jennifer'
                , 'Dilly'
                , 'JDILLY'
                , '650.505.2876'
                , TO_DATE ('08/13/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 3600
                , NULL
                , 122
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  190
                , 'Timothy'
                , 'Gates'
                , 'TGATES'
                , '650.505.3876'
                , TO_DATE ('07/11/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 2900
                , NULL
                , 122
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  191
                , 'Randall'
                , 'Perkins'
                , 'RPERKINS'
                , '650.505.4876'
                , TO_DATE ('12/19/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 2500
                , NULL
                , 122
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  192
                , 'Sarah'
                , 'Bell'
                , 'SBELL'
                , '650.501.1876'
                , TO_DATE ('02/04/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 4000
                , NULL
                , 123
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  193
                , 'Britney'
                , 'Everett'
                , 'BEVERETT'
                , '650.501.2876'
                , TO_DATE ('03/03/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 3900
                , NULL
                , 123
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  194
                , 'Samuel'
                , 'McCain'
                , 'SMCCAIN'
                , '650.501.3876'
                , TO_DATE ('07/01/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 3200
                , NULL
                , 123
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  195
                , 'Vance'
                , 'Jones'
                , 'VJONES'
                , '650.501.4876'
                , TO_DATE ('03/17/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 2800
                , NULL
                , 123
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  196
                , 'Alana'
                , 'Walsh'
                , 'AWALSH'
                , '650.507.9811'
                , TO_DATE ('04/24/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 3100
                , NULL
                , 124
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  197
                , 'Kevin'
                , 'Feeney'
                , 'KFEENEY'
                , '650.507.9822'
                , TO_DATE ('05/23/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 3000
                , NULL
                , 124
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  198
                , 'Donald'
                , 'OConnell'
                , 'DOCONNEL'
                , '650.507.9833'
                , TO_DATE ('06/21/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 2600
                , NULL
                , 124
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  199
                , 'Douglas'
                , 'Grant'
                , 'DGRANT'
                , '650.507.9844'
                , TO_DATE ('01/13/2000 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SH_CLERK'
                , 2600
                , NULL
                , 124
                , 50
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  200
                , 'Jennifer'
                , 'Whalen'
                , 'JWHALEN'
                , '515.123.4444'
                , TO_DATE ('09/17/1987 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'AD_ASST'
                , 4400
                , NULL
                , 101
                , 10
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  201
                , 'Michael'
                , 'Hartstein'
                , 'MHARTSTE'
                , '515.123.5555'
                , TO_DATE ('02/17/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'MK_MAN'
                , 13000
                , NULL
                , 100
                , 20
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  202
                , 'Pat'
                , 'Fay'
                , 'PFAY'
                , '603.123.6666'
                , TO_DATE ('08/17/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'MK_REP'
                , 6000
                , NULL
                , 201
                , 20
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  203
                , 'Susan'
                , 'Mavris'
                , 'SMAVRIS'
                , '515.123.7777'
                , TO_DATE ('06/07/1994 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'HR_REP'
                , 6500
                , NULL
                , 101
                , 40
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  204
                , 'Hermann'
                , 'Baer'
                , 'HBAER'
                , '515.123.8888'
                , TO_DATE ('06/07/1994 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'PR_REP'
                , 10000
                , NULL
                , 101
                , 70
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  205
                , 'Shelley'
                , 'Higgins'
                , 'SHIGGINS'
                , '515.123.8080'
                , TO_DATE ('06/07/1994 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'AC_MGR'
                , 12000
                , NULL
                , 101
                , 110
              );

   INSERT INTO employees (
                             employee_id
                           , first_name
                           , last_name
                           , email
                           , phone_number
                           , hire_date
                           , job_id
                           , salary
                           , commission_pct
                           , manager_id
                           , department_id
              )
       VALUES (
                  206
                , 'William'
                , 'Gietz'
                , 'WGIETZ'
                , '515.123.8181'
                , TO_DATE ('06/07/1994 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'AC_ACCOUNT'
                , 8300
                , NULL
                , 205
                , 110
              );

   COMMIT;

   INSERT INTO job_history (
                               employee_id
                             , start_date
                             , end_date
                             , job_id
                             , department_id
              )
       VALUES (
                  102
                , TO_DATE ('01/13/1993 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , TO_DATE ('07/24/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'IT_PROG'
                , 60
              );

   INSERT INTO job_history (
                               employee_id
                             , start_date
                             , end_date
                             , job_id
                             , department_id
              )
       VALUES (
                  101
                , TO_DATE ('09/21/1989 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , TO_DATE ('10/27/1993 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'AC_ACCOUNT'
                , 110
              );

   INSERT INTO job_history (
                               employee_id
                             , start_date
                             , end_date
                             , job_id
                             , department_id
              )
       VALUES (
                  101
                , TO_DATE ('10/28/1993 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , TO_DATE ('03/15/1997 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'AC_MGR'
                , 110
              );

   INSERT INTO job_history (
                               employee_id
                             , start_date
                             , end_date
                             , job_id
                             , department_id
              )
       VALUES (
                  201
                , TO_DATE ('02/17/1996 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , TO_DATE ('12/19/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'MK_REP'
                , 20
              );

   INSERT INTO job_history (
                               employee_id
                             , start_date
                             , end_date
                             , job_id
                             , department_id
              )
       VALUES (
                  114
                , TO_DATE ('03/24/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , TO_DATE ('12/31/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 50
              );

   INSERT INTO job_history (
                               employee_id
                             , start_date
                             , end_date
                             , job_id
                             , department_id
              )
       VALUES (
                  122
                , TO_DATE ('01/01/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , TO_DATE ('12/31/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'ST_CLERK'
                , 50
              );

   INSERT INTO job_history (
                               employee_id
                             , start_date
                             , end_date
                             , job_id
                             , department_id
              )
       VALUES (
                  200
                , TO_DATE ('09/17/1987 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , TO_DATE ('06/17/1993 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'AD_ASST'
                , 90
              );

   INSERT INTO job_history (
                               employee_id
                             , start_date
                             , end_date
                             , job_id
                             , department_id
              )
       VALUES (
                  176
                , TO_DATE ('03/24/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , TO_DATE ('12/31/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_REP'
                , 80
              );

   INSERT INTO job_history (
                               employee_id
                             , start_date
                             , end_date
                             , job_id
                             , department_id
              )
       VALUES (
                  176
                , TO_DATE ('01/01/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , TO_DATE ('12/31/1999 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'SA_MAN'
                , 80
              );

   INSERT INTO job_history (
                               employee_id
                             , start_date
                             , end_date
                             , job_id
                             , department_id
              )
       VALUES (
                  200
                , TO_DATE ('07/01/1994 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , TO_DATE ('12/31/1998 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM')
                , 'AC_ACCOUNT'
                , 90
              );

   COMMIT;
END;
/

CREATE UNIQUE INDEX dept_id_pk
   ON departments (department_id)
/

CREATE INDEX dept_location_ix
   ON departments (location_id)
/

CREATE UNIQUE INDEX emp_email_uk
   ON employees (email)
/

CREATE UNIQUE INDEX emp_emp_id_pk
   ON employees (employee_id)
/

CREATE INDEX emp_department_ix
   ON employees (department_id)
/

CREATE INDEX emp_job_ix
   ON employees (job_id)
/

CREATE INDEX emp_manager_ix
   ON employees (manager_id)
/

CREATE INDEX emp_name_ix
   ON employees (last_name, first_name)
/

CREATE UNIQUE INDEX job_id_pk
   ON jobs (job_id)
/

CREATE UNIQUE INDEX jhist_emp_id_st_date_pk
   ON job_history (employee_id, start_date)
/

CREATE INDEX jhist_job_ix
   ON job_history (job_id)
/

CREATE INDEX jhist_employee_ix
   ON job_history (employee_id)
/

CREATE INDEX jhist_department_ix
   ON job_history (department_id)
/

CREATE UNIQUE INDEX loc_id_pk
   ON locations (location_id)
/

CREATE INDEX loc_city_ix
   ON locations (city)
/

CREATE INDEX loc_state_province_ix
   ON locations (state_province)
/

CREATE INDEX loc_country_ix
   ON locations (country_id)
/

CREATE UNIQUE INDEX reg_id_pk
   ON regions (region_id)
/

ALTER TABLE regions ADD (
  CONSTRAINT reg_id_pk
 PRIMARY KEY
 (region_id))
/
ALTER TABLE locations ADD (
  CONSTRAINT loc_id_pk
 PRIMARY KEY
 (location_id))
/
ALTER TABLE departments ADD (
  CONSTRAINT dept_id_pk
 PRIMARY KEY
 (department_id))
/
ALTER TABLE jobs ADD (
  CONSTRAINT job_id_pk
 PRIMARY KEY
 (job_id))
/
ALTER TABLE employees ADD (
  CONSTRAINT emp_salary_min
 CHECK (salary > 0))
/
ALTER TABLE employees ADD (
  CONSTRAINT emp_emp_id_pk
 PRIMARY KEY
 (employee_id))
/
ALTER TABLE employees ADD (
  CONSTRAINT emp_email_uk
 UNIQUE (email))
/
ALTER TABLE job_history ADD (
  CONSTRAINT jhist_date_interval
 CHECK (end_date > start_date))
/
ALTER TABLE job_history ADD (
  CONSTRAINT jhist_emp_id_st_date_pk
 PRIMARY KEY
 (employee_id, start_date))
/
ALTER TABLE countries ADD (
  CONSTRAINT countr_reg_fk
 FOREIGN KEY (region_id)
 REFERENCES regions (region_id) ON DELETE CASCADE)
/
ALTER TABLE locations ADD (
  CONSTRAINT loc_c_id_fk
 FOREIGN KEY (country_id)
 REFERENCES countries (country_id) ON DELETE CASCADE)
/
ALTER TABLE departments ADD (
  CONSTRAINT dept_mgr_fk
 FOREIGN KEY (manager_id)
 REFERENCES employees (employee_id) ON DELETE CASCADE)
/
ALTER TABLE departments ADD (
  CONSTRAINT dept_loc_fk
 FOREIGN KEY (location_id)
 REFERENCES locations (location_id) ON DELETE CASCADE)
/
ALTER TABLE employees ADD (
  CONSTRAINT emp_manager_fk
 FOREIGN KEY (manager_id)
 REFERENCES employees (employee_id) ON DELETE CASCADE)
/
ALTER TABLE employees ADD (
  CONSTRAINT emp_job_fk
 FOREIGN KEY (job_id)
 REFERENCES jobs (job_id) ON DELETE CASCADE)
/
ALTER TABLE employees ADD (
  CONSTRAINT emp_dept_fk
 FOREIGN KEY (department_id)
 REFERENCES departments (department_id) ON DELETE CASCADE)
/
ALTER TABLE job_history ADD (
  CONSTRAINT jhist_dept_fk
 FOREIGN KEY (department_id)
 REFERENCES departments (department_id) ON DELETE CASCADE)
/
ALTER TABLE job_history ADD (
  CONSTRAINT jhist_emp_fk
 FOREIGN KEY (employee_id)
 REFERENCES employees (employee_id) ON DELETE CASCADE)
/
ALTER TABLE job_history ADD (
  CONSTRAINT jhist_job_fk
 FOREIGN KEY (job_id)
 REFERENCES jobs (job_id) ON DELETE CASCADE)
/

CREATE OR REPLACE TYPE employee_ids_ntt IS TABLE OF INTEGER;
/

/* Assume max of 1000 employees per department. Just to use a varray! */

CREATE OR REPLACE TYPE uc_employee_names_vat
IS
   VARRAY (1000) OF VARCHAR2 (4000);
/

CREATE TABLE department_denorms
(
   department_id    NUMBER (6)
 , max_salary       NUMBER
 , employee_names   uc_employee_names_vat
 , employee_ids     employee_ids_ntt
)
NESTED TABLE employee_ids
   STORE AS nested_id_table
/

--
ALTER TABLE department_denorms ADD (
  CONSTRAINT department_denorms_fk
 FOREIGN KEY (department_id)
 REFERENCES departments (department_id) ON DELETE CASCADE)
/

/* Initial population of the denormalized table */
TRUNCATE TABLE department_denorms
/

DECLARE
   TYPE employees_aat
   IS
      TABLE OF employees%ROWTYPE
         INDEX BY PLS_INTEGER;

   l_employees          employees_aat;

   TYPE denorms_aat
   IS
      TABLE OF department_denorms%ROWTYPE
         INDEX BY PLS_INTEGER;

   l_sorted_dept_info   denorms_aat;
BEGIN
   SELECT *
     BULK COLLECT
     INTO l_employees
     FROM employees;

   FOR indx IN 1 .. l_employees.COUNT
   LOOP
      -- Initialize the row if necessary.
      -- Set max salary.
      IF NOT l_sorted_dept_info.EXISTS (l_employees (indx).department_id)
      THEN
         l_sorted_dept_info (l_employees (indx).department_id).department_id :=
            l_employees (indx).department_id;
         l_sorted_dept_info (l_employees (indx).department_id).max_salary := 0;
         l_sorted_dept_info (l_employees (indx).department_id).employee_ids :=
            employee_ids_ntt ();
         l_sorted_dept_info (l_employees (indx).department_id).employee_names :=
            uc_employee_names_vat ();
      END IF;

      -- Set the maximum salary.
      l_sorted_dept_info (l_employees (indx).department_id).max_salary :=
         GREATEST (
            l_sorted_dept_info (l_employees (indx).department_id).max_salary
          , l_employees (indx).salary
         );
      -- Add the upper cased name.
      l_sorted_dept_info (l_employees (indx).department_id
                         ).employee_names.EXTEND;
      l_sorted_dept_info(l_employees (indx).department_id).employee_names(l_sorted_dept_info(l_employees(indx).department_id).employee_names.COUNT) :=
         UPPER(   l_employees (indx).first_name
               || ' '
               || l_employees (indx).last_name);
      -- Add the employee id.
      l_sorted_dept_info (l_employees (indx).department_id).employee_ids.EXTEND;
      l_sorted_dept_info(l_employees (indx).department_id).employee_ids(l_sorted_dept_info(l_employees(indx).department_id).employee_ids.COUNT) :=
         l_employees (indx).employee_id;
   END LOOP;

   -- Push the data into the denorm table.
   FORALL indx IN INDICES OF l_sorted_dept_info
      INSERT INTO department_denorms
          VALUES l_sorted_dept_info (indx);

   COMMIT;
END;
/

CREATE OR REPLACE PACKAGE denorm_demo_pkg
IS
   PROCEDURE show_ids (
      department_id_in IN department_denorms.department_id%TYPE
   );

   PROCEDURE show_names (
      department_id_in IN department_denorms.department_id%TYPE
   );

   PROCEDURE add_id (department_id_in IN department_denorms.department_id%TYPE
                   , employee_id_in IN employees.employee_id%TYPE
                    );

   PROCEDURE add_name (
      department_id_in IN department_denorms.department_id%TYPE
    , NAME_IN IN VARCHAR2
   );

   PROCEDURE add_name (
      department_id_in IN department_denorms.department_id%TYPE
    , employee_id_in IN employees.employee_id%TYPE
   );

   PROCEDURE show_all;
END denorm_demo_pkg;
/

CREATE OR REPLACE PACKAGE BODY denorm_demo_pkg
IS
   PROCEDURE show_ids (
      department_id_in IN department_denorms.department_id%TYPE
   )
   IS
      l_ids   employee_ids_ntt;
   BEGIN
      DBMS_OUTPUT.put_line ('Employee IDs for department ' || department_id_in);

      SELECT employee_ids
        INTO l_ids
        FROM department_denorms
       WHERE department_id = department_id_in;

      FOR indx IN 1 .. l_ids.COUNT
      LOOP
         DBMS_OUTPUT.put_line ('   ' || l_ids (indx));
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         DBMS_OUTPUT.put_line (
            '*** No employee IDs found for department ' || department_id_in
         );
   END show_ids;

   PROCEDURE show_names (
      department_id_in IN department_denorms.department_id%TYPE
   )
   IS
      l_names   uc_employee_names_vat;
   BEGIN
      DBMS_OUTPUT.put_line (
         'Employee names for department ' || department_id_in
      );

      SELECT employee_names
        INTO l_names
        FROM department_denorms
       WHERE department_id = department_id_in;

      FOR indx IN 1 .. l_names.COUNT
      LOOP
         DBMS_OUTPUT.put_line ('   ' || l_names (indx));
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         DBMS_OUTPUT.put_line (
            '***No employee names found for department ' || department_id_in
         );
   END show_names;

   PROCEDURE add_id (department_id_in IN department_denorms.department_id%TYPE
                   , employee_id_in IN employees.employee_id%TYPE
                    )
   IS
   BEGIN
      --   update department_denorms
      NULL;
   END add_id;

   PROCEDURE add_name (
      department_id_in IN department_denorms.department_id%TYPE
    , NAME_IN IN VARCHAR2
   )
   IS
   BEGIN
      --   update department_denorms
      NULL;
   END add_name;

   PROCEDURE add_name (
      department_id_in IN department_denorms.department_id%TYPE
    , employee_id_in IN employees.employee_id%TYPE
   )
   IS
   BEGIN
      --   update department_denorms
      NULL;
   END add_name;

   PROCEDURE show_all
   IS
      TYPE departments_aat
      IS
         TABLE OF departments%ROWTYPE
            INDEX BY PLS_INTEGER;

      l_departments   departments_aat;
   BEGIN
      SELECT *
        BULK COLLECT
        INTO l_departments
        FROM departments;

      FOR indx IN 1 .. l_departments.COUNT
      LOOP
         show_ids (l_departments (indx).department_id);
         show_names (l_departments (indx).department_id);
      END LOOP;
   END;
END denorm_demo_pkg;
/

CREATE OR REPLACE VIEW hr_just_names
AS
   SELECT d.department_name, e.last_name, e.first_name
     FROM employees e, departments d
    WHERE d.department_id = e.department_id
/

/* UNFINISHED!
   Now create a trigger to manage the denorm table.
CREATE OR REPLACE TRIGGER populate_denorms_tr
   AFTER INSERT OR UPDATE
   ON employees
   FOR EACH ROW
DECLARE
BEGIN
   SELECT *
     INTO l_denorm
     FROM department_denorms
    WHERE department_id = :NEW.department_id;
END type_table_bir;
*/