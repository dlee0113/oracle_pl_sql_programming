
exec UTL_FILE.FREMOVE('DIR','employees.dat');
DROP TABLE employees;
DROP TABLE employees_staging;
DROP PACKAGE employee_pkg;
DROP TYPE employee_ntt;
DROP TYPE employee_ot;
DROP DIRECTORY dir;

