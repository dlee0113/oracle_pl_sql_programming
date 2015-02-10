/*
Demonstration of "automatic upgrading" to use of result cache 
when upgrading to Oracle11g using Conditional Compilation....
*/
CREATE OR REPLACE PACKAGE emplu11g
IS
   FUNCTION onerow (employee_id_in IN employees.employee_id%TYPE)
      RETURN employees%ROWTYPE
   $IF dbms_db_version.version >= 11
   $THEN
      result_cache
   $END
   ;
END;
/

CREATE OR REPLACE PACKAGE BODY emplu11g
IS
   FUNCTION onerow (employee_id_in IN employees.employee_id%TYPE)
      RETURN employees%ROWTYPE
   $IF dbms_db_version.version >= 11
   $THEN
      result_cache relies_on (employees)
   $END
   IS
      onerow_rec   employees%ROWTYPE;
   BEGIN
   $IF dbms_db_version.version >= 11
   $THEN
      $ERROR 'Review this use of RESULT_CACHE! Ask Steven for more info.'   
   $END   
      SELECT *
        INTO onerow_rec
        FROM employees
       WHERE employee_id = employee_id_in;
      RETURN onerow_rec;
   END;
END;
/
