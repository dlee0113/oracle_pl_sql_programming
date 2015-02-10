/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 6

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

CREATE OR REPLACE PROCEDURE log_error
IS
BEGIN
   NULL;
END;
/

DROP TABLE company
/

CREATE TABLE company (company_id INTEGER)
/

CREATE OR REPLACE PROCEDURE calc_annual_sales (
   company_id_in IN company.company_id%TYPE
)
IS
   invalid_company_id exception;
   negative_balance exception;

   duplicate_company   BOOLEAN;
BEGIN
   NULL;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      log_error ();
   WHEN invalid_company_id
   THEN
      log_error ();
   WHEN negative_balance
   THEN
      log_error ();
END;
/

CREATE OR REPLACE PROCEDURE delete_company (company_id_in IN NUMBER)
IS
   /* Declare the exception. */
   still_have_employees exception;

   /* Associate the exception name with an error number. */
   PRAGMA EXCEPTION_INIT (still_have_employees, -2292);
BEGIN
   /* Try to delete the company. */
   DELETE FROM company
         WHERE company_id = company_id_in;
EXCEPTION
   /* If child records were found, this exception is raised! */
   WHEN still_have_employees
   THEN
      DBMS_OUTPUT.put_line ('Please delete employees for company first.');
END;
/

CREATE OR REPLACE PACKAGE errnums
IS
   en_too_young     CONSTANT NUMBER := -20001;
   exc_too_young exception;
   PRAGMA EXCEPTION_INIT (exc_too_young, -20001);

   en_sal_too_low   CONSTANT NUMBER := -20002;
   exc_sal_too_low exception;
   PRAGMA EXCEPTION_INIT (exc_sal_too_low, -20002);
END errnums;
/

CREATE OR REPLACE PROCEDURE validate_emp (birthdate_in IN DATE)
IS
   min_years   CONSTANT PLS_INTEGER := 18;
BEGIN
   IF ADD_MONTHS (SYSDATE, min_years * 12 * -1) < birthdate_in
   THEN
      raise_application_error (
         errnums.en_too_young
       , 'Employee must be at least ' || min_years || ' old.'
      );
   END IF;
END;
/

CREATE OR REPLACE PROCEDURE check_account (company_id_in IN NUMBER)
IS
   overdue_balance exception;
BEGIN
   LOOP
      IF TRUE
      THEN
         RAISE overdue_balance;
      END IF;
   END LOOP;
EXCEPTION
   WHEN overdue_balance
   THEN
      DBMS_OUTPUT.put_line ('Overdue!');
END;
/

DECLARE
   invalid_id exception;
   id_value   VARCHAR2 (30);

   FUNCTION id_for (NAME_IN IN VARCHAR2)
      RETURN INTEGER
   IS
   BEGIN
      RETURN 1;
   END;
BEGIN
   id_value := id_for ('SMITH');

   IF SUBSTR (id_value, 1, 1) != 'X'
   THEN
      RAISE invalid_id;
   END IF;
END;
/

CREATE OR REPLACE FUNCTION sales_percentage_calculation (mine_in  IN NUMBER
                                                       , total_in IN NUMBER
                                                        )
   RETURN NUMBER
IS
BEGIN
   RETURN NULL;
END;

CREATE OR REPLACE FUNCTION return_stuff
   RETURN NUMBER
IS
   total_sales   NUMBER;
BEGIN
   IF total_sales = 0
   THEN
      RAISE ZERO_DIVIDE;
   ELSE
      RETURN (sales_percentage_calculation (my_sales, total_sales));
   END IF;
END;
/

BEGIN
   DBMS_OUTPUT.put_line (SQLERRM (-1403));
END;
/

CREATE OR REPLACE PROCEDURE proc1
IS
BEGIN
   DBMS_OUTPUT.put_line ('running proc1');
   RAISE NO_DATA_FOUND;
END;
/

CREATE OR REPLACE PROCEDURE proc2
IS
   l_str   VARCHAR2 (30) := 'calling proc1';
BEGIN
   DBMS_OUTPUT.put_line (l_str);
   proc1;
END;
/

CREATE OR REPLACE PROCEDURE proc3
IS
BEGIN
   DBMS_OUTPUT.put_line ('calling proc2');
   proc2;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error stack at top level:');
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_backtrace);
END;
/

BEGIN
   DBMS_OUTPUT.put_line ('Proc3 -> Proc2 -> Proc1 backtrace');
   proc3;
END;
/

DROP TABLE company
/

CREATE TABLE company (id NUMBER, name VARCHAR2 (200), type_id NUMBER)
/

CREATE TABLE company_history (id NUMBER)
/


CREATE OR REPLACE PROCEDURE change_data
IS
BEGIN
   BEGIN
      DELETE FROM employees
            WHERE employee_id = 198;
   EXCEPTION
      WHEN OTHERS
      THEN
         log_error;
   END;

   BEGIN
      UPDATE company
         SET id = 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         log_error;
   END;

   BEGIN
      INSERT INTO company_history
         SELECT *
           FROM company
          WHERE id = 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         log_error;
   END;
END;
/

CREATE OR REPLACE PROCEDURE add_company (id_in      IN company.id%TYPE
                                       , NAME_IN    IN company.name%TYPE
                                       , type_id_in IN company.type_id%TYPE
                                        )
IS
BEGIN
   INSERT INTO company (id, name, type_id
                       )
       VALUES (id_in, NAME_IN, type_id_in
              );
EXCEPTION
   WHEN OTHERS
   THEN
      /*
      || Anonymous block inside the exception handler lets me declare
      || local variables to hold the error code information.
      */
      DECLARE
         l_errcode   PLS_INTEGER := SQLCODE;
      BEGIN
         CASE l_errcode
            WHEN -1
            THEN
               -- Duplicate value for unique index. Either a repeat of the
               -- primary key or name. Display problem and re-raise.
               DBMS_OUTPUT.put_line('Company ID or name already in use. ID = '
                                    || TO_CHAR (id_in)
                                    || ' name = '
                                    || NAME_IN);
               RAISE;
            WHEN -2291
            THEN
               -- Parent key not found for type. Display problem and re-raise.
               DBMS_OUTPUT.put_line (
                  'Invalid company type ID: ' || TO_CHAR (type_id_in)
               );
               RAISE;
            ELSE
               RAISE;
         END CASE;
      END;
END add_company;
/

CREATE OR REPLACE PROCEDURE read_file_and_do_stuff (dir_in  IN VARCHAR2
                                                  , file_in IN VARCHAR2
                                                   )
IS
   l_file   UTL_FILE.file_type;
   l_line   VARCHAR2 (32767);
BEGIN
   l_file := UTL_FILE.fopen (dir_in, file_in, 'R', max_linesize => 32767);

   LOOP
      UTL_FILE.get_line (l_file, l_line);
   -- do_stuff;
   END LOOP;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      UTL_FILE.fclose (l_file);
-- more_stuff_here;
END;
/

CREATE OR REPLACE FUNCTION fullname (
   employee_id_in IN employees.employee_id%TYPE
)
   RETURN VARCHAR2
IS
   retval   VARCHAR2 (32767);
BEGIN
   SELECT last_name || ',' || first_name
     INTO retval
     FROM employees
    WHERE employee_id = employee_id_in;

   RETURN retval;
END fullname;
/

BEGIN
   NULL;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX
   THEN
      q$error_manager.register_error (error_name_in => 'DUPLICATE-VALUE'
                                    , err_instance_id_out => l_err_instance_id
                                     );
      q$error_manager.add_context (err_instance_id_in => l_err_instance_id
                                 , NAME_IN => 'TABLE_NAME'
                                 , value_in => 'EMPLOYEES'
                                  );
      q$error_manager.add_context (err_instance_id_in => l_err_instance_id
                                 , NAME_IN => 'KEY_VALUE'
                                 , value_in => l_employee_id
                                  );
      q$error_manager.raise_error_instance (
         err_instance_id_in => l_err_instance_id
      );
END;
/

CREATE OR REPLACE PROCEDURE read_file_and_do_stuff (dir      IN VARCHAR2
                                                  , filename IN VARCHAR2
                                                   )
ISBEGIN
   UTL_FILE.fremove (dir, filename);
EXCEPTION
   WHEN UTL_FILE.delete_failed
   THEN
      DBMS_OUTPUT.put_line (
         'Error attempting to remove: ' || filename || ' from ' || dir
      );
      -- Then take appropriate action....

   WHEN UTL_FILE.invalid_operation
   THEN
      DBMS_OUTPUT.put_line (
         'Unable to find and remove: ' || filename || ' from ' || dir
      );
      -- Then take appropriate action....
END;
/