/* Formatted on 3/8/2009 12:49:07 PM (QP5 v5.114.809.3010) */
SET SERVEROUTPUT ON FORMAT WRAPPED

DROP TABLE my_emps
/

CREATE TABLE my_emps (employee_id NUMBER, last_name  VARCHAR2 (100))
/

BEGIN
   INSERT INTO my_emps
     VALUES   (138, 'Feuerstein');

   INSERT INTO my_emps
     VALUES   (139, 'Ellison');

   COMMIT;
END;
/

CREATE OR REPLACE PACKAGE emplu11g
IS
   FUNCTION last_name (employee_id_in IN my_emps.employee_id%TYPE)
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE
;
    FUNCTION last_name_no_relies_on (employee_id_in IN my_emps.employee_id%TYPE)
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE
;
END;
/

CREATE OR REPLACE PACKAGE BODY emplu11g
IS
   FUNCTION last_name (employee_id_in IN my_emps.employee_id%TYPE)
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE RELIES_ON ( my_emps )
   IS
      onerow_rec   my_emps%ROWTYPE;
   BEGIN
      DBMS_OUTPUT.put_line ('(RELIES ON) Get name for ' || employee_id_in);

      SELECT *
        INTO onerow_rec
        FROM my_emps
       WHERE employee_id = employee_id_in;

      RETURN onerow_rec.last_name || ' (WITH RELIES ON)';
   END;

   FUNCTION last_name_no_relies_on (
      employee_id_in IN my_emps.employee_id%TYPE
   )
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE
   IS
      onerow_rec my_emps%ROWTYPE;
   BEGIN
      DBMS_OUTPUT.put_line ('(NO RELIES ON) Get name for ' || employee_id_in);

      SELECT *
        INTO onerow_rec
        FROM my_emps
       WHERE employee_id = employee_id_in;

      RETURN onerow_rec.last_name || ' (WITHOUT RELIES ON)';
   END;
END;
/

CREATE OR REPLACE PROCEDURE frc_no_relies_on (t varchar2)
IS
BEGIN
   DBMS_OUTPUT.put_line(   t
                        || ' with '
                        || DBMS_DB_VERSION.version
                        || '.'
                        || DBMS_DB_VERSION.release);
   DBMS_OUTPUT.put_line ('Same Emp ID - 2 times');

   FOR indx IN 1 .. 2
   LOOP
      DBMS_OUTPUT.put_line ('NAME = ' || emplu11g.last_name (138));
      DBMS_OUTPUT.put_line (
         'NAME = ' || emplu11g.last_name_no_relies_on (138)
      );
   END LOOP;

   DBMS_OUTPUT.put_line ('Same Emp ID - 2 times - update between each one');

   FOR indx IN 1 .. 2
   LOOP
      UPDATE   my_emps
         SET   last_name = 'JOE';

      COMMIT;
      DBMS_OUTPUT.put_line ('NAME = ' || emplu11g.last_name (138));
      DBMS_OUTPUT.put_line (
         'NAME = ' || emplu11g.last_name_no_relies_on (138)
      );
   END LOOP;
END frc_no_relies_on;
/

BEGIN
   frc_no_relies_on ('Static Queries');
END;
/

/*
11.1
Same Emp ID - 2 times
(RELIES ON) Get name for 138
NAME = Feuerstein (WITH RELIES ON)
(NO RELIES ON) Get name for 138
NAME = Feuerstein (WITHOUT RELIES ON)
NAME = Feuerstein (WITH RELIES ON)
NAME = Feuerstein (WITHOUT RELIES ON)
Same Emp ID - 2 times - update between each one
(RELIES ON) Get name for 138
NAME = JOE (WITH RELIES ON)
NAME = Feuerstein (WITHOUT RELIES ON)
(RELIES ON) Get name for 138
NAME = JOE (WITH RELIES ON)
NAME = Feuerstein (WITHOUT RELIES ON)
*/

/*
11.2
Same Emp ID - 2 times
(RELIES ON) Get name for 138
NAME = Feuerstein (WITH RELIES ON)
(NO RELIES ON) Get name for 138
NAME = Feuerstein (WITHOUT RELIES ON)
NAME = Feuerstein (WITH RELIES ON)
NAME = Feuerstein (WITHOUT RELIES ON)
Same Emp ID - 2 times - update between each one
(RELIES ON) Get name for 138
NAME = JOE (WITH RELIES ON)
(NO RELIES ON) Get name for 138
NAME = JOE (WITHOUT RELIES ON)
(RELIES ON) Get name for 138
NAME = JOE (WITH RELIES ON)
(NO RELIES ON) Get name for 138
NAME = JOE (WITHOUT RELIES ON)
*/

CREATE OR REPLACE PACKAGE BODY emplu11g
IS
   FUNCTION last_name (employee_id_in IN my_emps.employee_id%TYPE)
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE RELIES_ON ( my_emps )
   IS
      onerow_rec   my_emps%ROWTYPE;
   BEGIN
      DBMS_OUTPUT.put_line ('(RELIES ON) Dynamic get name for ' ||
      employee_id_in);

      EXECUTE IMMEDIATE
      'SELECT last_name
        FROM my_emps
       WHERE employee_id = :employee_id_in'
       INTO onerow_rec.last_name USING
      employee_id_in;

      RETURN onerow_rec.last_name || ' (WITH RELIES ON)';
   END;

   FUNCTION last_name_no_relies_on (
      employee_id_in IN my_emps.employee_id%TYPE
   )
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE
   IS
      onerow_rec my_emps%ROWTYPE;
   BEGIN
      DBMS_OUTPUT.put_line ('(NO RELIES ON) Dynamic get name for ' ||
      employee_id_in);

      EXECUTE IMMEDIATE
      'SELECT last_name
        FROM my_emps
       WHERE employee_id = :employee_id_in'
       INTO onerow_rec.last_name USING
      employee_id_in;

      RETURN onerow_rec.last_name || ' (WITHOUT RELIES ON)';
   END;
END;
/

BEGIN
   frc_no_relies_on ('Dynamic Queries');
END;
/