/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 18

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

CREATE OR REPLACE PROCEDURE process_employee (
   employee_id_in IN employees.employee_id%TYPE
)
IS
   l_fullname   VARCHAR2 (100);
BEGIN
   SELECT last_name || ',' || first_name
     INTO l_fullname
     FROM employees
    WHERE employee_id = employee_id_in;
END;
/

@fullname.pkg

DECLARE
   l_name           employee_pkg.fullname_t;
   employee_id_in   employees.employee_id%TYPE := 1;
BEGIN
   l_name := employee_pkg.fullname (employee_id_in);
END;
/

DROP TABLE pet
/

CREATE TABLE pet (id NUMBER (38) CONSTRAINT pk_pet PRIMARY KEY NOT NULL)
/

CREATE OR REPLACE PACKAGE pets_inc
IS
   max_pets_in_facility   CONSTANT INTEGER := 120;
   pet_is_sick exception;

   CURSOR pet_cur (pet_id_in IN pet.id%TYPE)
      RETURN pet%ROWTYPE;

   FUNCTION next_pet_shots (pet_id_in IN pet.id%TYPE)
      RETURN DATE;

   PROCEDURE set_schedule (pet_id_in IN pet.id%TYPE);
END pets_inc;
/

DECLARE
   -- Base this constant on the id column of the pet table.
   c_pet                CONSTANT pet.id%TYPE := 1099;
   v_next_appointment   DATE;
BEGIN
   IF pets_inc.max_pets_in_facility > 100
   THEN
      OPEN pets_inc.pet_cur (c_pet);
   ELSE
      v_next_appointment := pets_inc.next_pet_shots (c_pet);
   END IF;
EXCEPTION
   WHEN pets_inc.pet_is_sick
   THEN
      pets_inc.set_schedule (c_pet);
END;
/

/* Run pkgcur.sql before this. */

DECLARE
   onebook   book_info.bytitle_cur%ROWTYPE;
BEGIN
   OPEN book_info.bytitle_cur ('%PL/SQL%');

   LOOP
      EXIT WHEN book_info.bytitle_cur%NOTFOUND;

      FETCH book_info.bytitle_cur
      INTO onebook;

      book_info.display (onebook);
   END LOOP;

   CLOSE book_info.bytitle_cur;
END;
/

/* Run openclose.sql first */

DECLARE
   one_emp   personnel.emps_for_dept%ROWTYPE;
BEGIN
   personnel.open_emps_for_dept (1055);

   LOOP
      EXIT WHEN personnel.emps_for_dept%NOTFOUND;

      FETCH personnel.emps_for_dept
      INTO one_emp;
   END LOOP;

   personnel.close_emps_for_dept;
END;
/

CREATE OR REPLACE PACKAGE config_pkg
IS
   closed_status     CONSTANT VARCHAR2 (1) := 'C';
   open_status       CONSTANT VARCHAR2 (1) := 'O';
   active_status     CONSTANT VARCHAR2 (1) := 'A';
   inactive_status   CONSTANT VARCHAR2 (1) := 'I';

   min_difference    CONSTANT PLS_INTEGER := 1;
   max_difference    CONSTANT PLS_INTEGER := 100;

   earliest_date     CONSTANT DATE := SYSDATE;
   latest_date       CONSTANT DATE := ADD_MONTHS (SYSDATE, 120);
END config_pkg;
/

DECLARE
   footing_difference   PLS_INTEGER;
   cust_status          VARCHAR2 (1);

   PROCEDURE adjust_line_item
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE reopen_customer
   IS
   BEGIN
      NULL;
   END;
BEGIN
   IF footing_difference BETWEEN config_pkg.min_difference
                             AND  config_pkg.max_difference
   THEN
      adjust_line_item;
   END IF;

   IF cust_status = config_pkg.closed_status
   THEN
      reopen_customer;
   END IF;
END;
/