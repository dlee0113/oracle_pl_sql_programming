/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 4

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

/* IF statement fragments */

CREATE TABLE employee_bonus (eb_employee_id INTEGER, eb_bonus_amt NUMBER)
/

CREATE TABLE emp_employee (emp_employee_id INTEGER, emp_bonus_given NUMBER)
/

CREATE OR REPLACE PROCEDURE give_bonus (id_in IN INTEGER, bonus_in IN NUMBER)
IS
BEGIN
   NULL;
END;
/

CREATE OR REPLACE FUNCTION award_bonus (employee_id_in IN INTEGER)
   RETURN BOOLEAN
IS
BEGIN
   RETURN TRUE;
END;
/

CREATE OR REPLACE FUNCTION print_check (employee_id_in IN INTEGER)
   RETURN BOOLEAN
IS
BEGIN
   RETURN TRUE;
END;
/

DECLARE
   max_allowable_order     CONSTANT NUMBER := 10000;
   salary                  NUMBER;
   employee_id             INTEGER := 198;

   TYPE customer_rt IS RECORD (order_total NUMBER);

   customer                customer_rt;
   order_exceeds_balance   BOOLEAN;
BEGIN
   IF salary > 40000
   THEN
      give_bonus (employee_id, 500);
   END IF;

   IF salary > 40000 OR salary IS NULL
   THEN
      give_bonus (employee_id, 500);
   END IF;

   IF salary > 40000
   THEN
      INSERT INTO employee_bonus (eb_employee_id, eb_bonus_amt
                                 )
          VALUES (employee_id, 500
                 );

      UPDATE emp_employee
         SET emp_bonus_given = 1
       WHERE emp_employee_id = employee_id;
   END IF;

   IF salary <= 40000
   THEN
      give_bonus (employee_id, 0);
   ELSE
      give_bonus (employee_id, 500);
   END IF;

   IF NVL (salary, 0) <= 40000
   THEN
      give_bonus (employee_id, 0);
   ELSE
      give_bonus (employee_id, 500);
   END IF;

   IF customer.order_total > max_allowable_order
   THEN
      order_exceeds_balance := TRUE;
   ELSE
      order_exceeds_balance := FALSE;
   END IF;

   IF salary BETWEEN 10000 AND 20000
   THEN
      give_bonus (employee_id, 1500);
   ELSIF salary BETWEEN 20000 AND 40000
   THEN
      give_bonus (employee_id, 1000);
   ELSIF salary > 40000
   THEN
      give_bonus (employee_id, 500);
   ELSE
      give_bonus (employee_id, 0);
   END IF;

   IF salary >= 10000 AND salary <= 20000
   THEN
      give_bonus (employee_id, 1500);
   ELSIF salary > 20000 AND salary <= 40000
   THEN
      give_bonus (employee_id, 1000);
   ELSIF salary > 40000
   THEN
      give_bonus (employee_id, 400);
   END IF;

   IF award_bonus (employee_id)
   THEN
      IF print_check (employee_id)
      THEN
         DBMS_OUTPUT.put_line ('Check issued for ' || employee_id);
      END IF;
   END IF;
END;
/

/* CASE fragments */

DECLARE
   employee_type   CHAR (1);
   employee_id     NUMBER;
   salary          NUMBER;

   invalid_employee_type exception;

   PROCEDURE award_salary_bonus (id_in IN INTEGER)
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE award_hourly_bonus (id_in IN INTEGER)
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE award_commissioned_bonus (id_in IN INTEGER)
   IS
   BEGIN
      NULL;
   END;
BEGIN
   CASE employee_type
      WHEN 'S'
      THEN
         award_salary_bonus (employee_id);
      WHEN 'H'
      THEN
         award_hourly_bonus (employee_id);
      WHEN 'C'
      THEN
         award_commissioned_bonus (employee_id);
      ELSE
         RAISE invalid_employee_type;
   END CASE;

   CASE TRUE
      WHEN salary >= 10000 AND salary <= 20000
      THEN
         give_bonus (employee_id, 1500);
      WHEN salary > 20000 AND salary <= 40000
      THEN
         give_bonus (employee_id, 1000);
      WHEN salary > 40000
      THEN
         give_bonus (employee_id, 500);
      ELSE
         give_bonus (employee_id, 0);
   END CASE;

   CASE
      WHEN salary > 40000
      THEN
         give_bonus (employee_id, 500);
      WHEN salary > 20000
      THEN
         give_bonus (employee_id, 1000);
      WHEN salary >= 10000
      THEN
         give_bonus (employee_id, 1500);
      ELSE
         give_bonus (employee_id, 0);
   END CASE;

   CASE
      WHEN salary >= 10000
      THEN
         CASE
            WHEN salary <= 20000
            THEN
               give_bonus (employee_id, 1500);
            WHEN salary > 40000
            THEN
               give_bonus (employee_id, 500);
            WHEN salary > 20000
            THEN
               give_bonus (employee_id, 1000);
         END CASE;
      WHEN salary < 10000
      THEN
         give_bonus (employee_id, 0);
   END CASE;
END;
/

DECLARE
   boolean_true    BOOLEAN := TRUE;
   boolean_false   BOOLEAN := FALSE;
   boolean_null    BOOLEAN;

   FUNCTION boolean_to_varchar2 (flag IN BOOLEAN)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN CASE flag
                WHEN TRUE THEN 'True'
                WHEN FALSE THEN 'False'
                ELSE 'NULL'
             END;
   END;
BEGIN
   DBMS_OUTPUT.put_line (boolean_to_varchar2 (boolean_true));
   DBMS_OUTPUT.put_line (boolean_to_varchar2 (boolean_false));
   DBMS_OUTPUT.put_line (boolean_to_varchar2 (boolean_null));
END;
/

DECLARE
   salary        NUMBER := 20000;
   employee_id   NUMBER := 36325;

   PROCEDURE give_bonus (emp_id IN NUMBER, bonus_amt IN NUMBER)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (emp_id);
      DBMS_OUTPUT.put_line (bonus_amt);
   END;
BEGIN
   give_bonus (employee_id
             , CASE
                  WHEN salary >= 10000 AND salary <= 20000 THEN 1500
                  WHEN salary > 20000 AND salary <= 40000 THEN 1000
                  WHEN salary > 40000 THEN 500
                  ELSE 0
               END
              );
END;
/

DECLARE
   salary         NUMBER := 20000;
   employee_id    NUMBER := 36325;
   bonus_amount   NUMBER;
BEGIN
   bonus_amount :=
      CASE
         WHEN salary >= 10000 AND salary <= 20000 THEN 1500
         WHEN salary > 20000 AND salary <= 40000 THEN 1000
         WHEN salary > 40000 THEN 500
         ELSE 0
      END
      * 10;

   DBMS_OUTPUT.put_line (bonus_amount);
END;
/

SELECT CASE WHEN dummy = 'X' THEN 'Dual is OK' ELSE 'Dual is messed up' END
  FROM DUAL
/

DECLARE
   dual_message   VARCHAR2 (20);
BEGIN
   SELECT CASE
             WHEN dummy = 'X' THEN 'Dual is OK'
             ELSE 'Dual is messed up'
          END
     INTO dual_message
     FROM DUAL;

   DBMS_OUTPUT.put_line (dual_message);
END;
/

BEGIN
   GOTO second_output;

   DBMS_OUTPUT.put_line ('This line will never execute.');

  <<second_output>>
   DBMS_OUTPUT.put_line ('We are here!');
END;
/

DROP TABLE orders 
/

CREATE TABLE orders (ship_date DATE, order_date DATE)
/

CREATE OR REPLACE FUNCTION validate_shipdate (date_in IN DATE)
   RETURN INTEGER
IS
BEGIN
   RETURN 1;
END;
/

CREATE OR REPLACE FUNCTION validate_orderdate (date_in IN DATE)
   RETURN INTEGER
IS
BEGIN
   RETURN 1;
END;
/

CREATE OR REPLACE PROCEDURE process_data (data_in     IN orders%ROWTYPE
                                        , data_action IN VARCHAR2
                                         )
IS
   status   INTEGER;
BEGIN
   -- First in series of validations.
   IF data_in.ship_date IS NOT NULL
   THEN
      status := validate_shipdate (data_in.ship_date);

      IF status != 0
      THEN
         GOTO end_of_procedure;
      END IF;
   END IF;

   -- Second in series of validations.
   IF data_in.order_date IS NOT NULL
   THEN
      status := validate_orderdate (data_in.order_date);

      IF status != 0
      THEN
         GOTO end_of_procedure;
      END IF;
   END IF;

  -- ... more validations ...

  <<end_of_procedure>>
   NULL;
END;
/