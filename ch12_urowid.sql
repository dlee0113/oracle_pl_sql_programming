CREATE TABLE employee (
   emp_id NUMBER,
   last_name VARCHAR2(30),
   first_name VARCHAR2(30),
   salary NUMBER,
   CONSTRAINT emp_pk
      PRIMARY KEY (emp_id)
);

INSERT INTO employee (emp_id, last_name, first_name, salary)
   VALUES (1, 'Grubbs', 'John', 100000);

INSERT INTO employee (emp_id, last_name, first_name, salary)
   VALUES (2, 'Grubbs', 'Heather', 100000);

DECLARE
   employee_rowid UROWID;
   employee_salary NUMBER;
BEGIN
   --Retrieve employee information that we might want to modify
   SELECT rowid, salary INTO employee_rowid, employee_salary
   FROM employee
   WHERE last_name='Grubbs' AND first_name='John';

   /* Do a bunch of processing to compute a new salary */

   UPDATE employee
      SET salary = employee_salary
    WHERE last_name='Grubbs' AND first_name='John';
END;
/

DECLARE
   employee_rowid UROWID;
   employee_salary NUMBER;
BEGIN
   --Retrieve employee information that we might want to modify
   SELECT rowid, salary INTO employee_rowid, employee_salary
   FROM employee
   WHERE last_name='Grubbs' AND first_name='John';

   /* Do a bunch of processing to compute a new salary */

   UPDATE employee
      SET salary = employee_salary
    WHERE rowid = employee_rowid;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
