SET SERVEROUTPUT ON FORMAT WRAPPED

DROP TABLE my_emps
/

CREATE TABLE my_emps (employee_id NUMBER, last_name VARCHAR2 (100))
/

BEGIN
   INSERT INTO my_emps
       VALUES (138, 'Feuerstein'
              );

   INSERT INTO my_emps
       VALUES (139, 'Ellison'
              );

   COMMIT;
END;
/

CREATE OR REPLACE PACKAGE emplu11g
IS
   FUNCTION last_name (employee_id_in IN my_emps.employee_id%TYPE)
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE;

    FUNCTION last_name_no_relies_on (employee_id_in IN my_emps.employee_id%TYPE, prefix_in IN VARCHAR2 DEFAULT '(NO RELIES ON)')
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE;

    FUNCTION last_name_wrong_relies_on (employee_id_in IN my_emps.employee_id%TYPE)
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE;
      FUNCTION last_name_indirect_relies_on (
      employee_id_in IN my_emps.employee_id%TYPE
   )  RETURN my_emps.last_name%TYPE
      RESULT_CACHE;
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

      RETURN onerow_rec.last_name;
   END;

   FUNCTION last_name_no_relies_on (
      employee_id_in IN my_emps.employee_id%TYPE
      , prefix_in IN VARCHAR2 DEFAULT '(NO RELIES ON)'
   )
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE
   IS
      onerow_rec my_emps%ROWTYPE;
   BEGIN
      DBMS_OUTPUT.put_line ( prefix_in || ' Get name for ' || employee_id_in);

      SELECT *
        INTO onerow_rec
        FROM my_emps
       WHERE employee_id = employee_id_in;

      RETURN onerow_rec.last_name;
   END;

   FUNCTION last_name_wrong_relies_on (
      employee_id_in IN my_emps.employee_id%TYPE
   )
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE RELIES_ON ( departments )
   IS
      onerow_rec   my_emps%ROWTYPE;
   BEGIN
      DBMS_OUTPUT.put_line (
         '(WRONG RELIES ON) Get name for ' || employee_id_in
      );

      SELECT *
        INTO onerow_rec
        FROM my_emps
       WHERE employee_id = employee_id_in;

      RETURN onerow_rec.last_name;
   END;

    FUNCTION last_name_indirect_relies_on (
      employee_id_in IN my_emps.employee_id%TYPE
   )
      RETURN my_emps.last_name%TYPE
      RESULT_CACHE
   IS
      onerow_rec   my_emps%ROWTYPE;
   BEGIN

      RETURN last_name_no_relies_on (employee_id_in, prefix_in => '(INDIRECT RELIES ON)');
   END;
END;
/

BEGIN
   FOR indx IN 1 .. 2
   LOOP
      UPDATE my_emps
         SET last_name = 'JOE';

      COMMIT;
      DBMS_OUTPUT.put_line (
         'Explicit RELIES_ON = ' || emplu11g.last_name (138)
      );
      DBMS_OUTPUT.put_line (
         'No RELIES_ON = ' || emplu11g.last_name_no_relies_on (138)
      );
      DBMS_OUTPUT.put_line (
         'Wrong RELIES_ON = ' || emplu11g.last_name_wrong_relies_on (138)
      );
      DBMS_OUTPUT.put_line('Indirect RELIES_ON = '
                           || emplu11g.last_name_indirect_relies_on (138));
   END LOOP;
END;
/