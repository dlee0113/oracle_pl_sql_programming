/*
First create a compute intensive procedure using PLS_INTEGER.
*/

CREATE OR REPLACE PROCEDURE pls_test (iterations IN PLS_INTEGER)
AS
   int1      PLS_INTEGER := 1;
   int2      PLS_INTEGER := 2;
   begints   timestamp;
   endts     timestamp;
BEGIN
   begints := SYSTIMESTAMP;

   FOR cnt IN 1 .. iterations
   LOOP
      int1 := int1 + int2 * cnt;
   END LOOP;

   endts := SYSTIMESTAMP;
   DBMS_OUTPUT.put_line(   iterations
                        || ' iterations had run time of:'
                        || TO_CHAR (endts - begints));
END;
/

/*
Next create the same procedure using SIMPLE_INTEGER.
*/

CREATE OR REPLACE PROCEDURE simple_test (iterations IN SIMPLE_INTEGER)
AS
   int1      SIMPLE_INTEGER := 1;
   int2      SIMPLE_INTEGER := 2;
   begints   timestamp;
   endts     timestamp;
BEGIN
   begints := SYSTIMESTAMP;

   FOR cnt IN 1 .. iterations
   LOOP
      int1 := int1 + int2 * cnt;
   END LOOP;

   endts := SYSTIMESTAMP;
   DBMS_OUTPUT.put_line(   iterations
                        || ' iterations had run time of:'
                        || TO_CHAR (endts - begints));
END;
/

/* Recompile the procedures to as interpreted. */
ALTER PROCEDURE pls_test COMPILE plsql_code_type=interpreted
/
ALTER PROCEDURE simple_test COMPILE plsql_code_type=interpreted
/

/*
Compare the run times.
*/

BEGIN
   pls_test (123456789);
END;
/

/* We saw:
123456789 iterations had run time of:+000000000 00:00:06.375000000
*/

BEGIN
   simple_test (123456789);
END;
/

/* We saw:
123456789 iterations had run time of:+000000000 00:00:06.000000000
*/

/* Recompile with to native code. */

ALTER PROCEDURE pls_test COMPILE plsql_code_type=native
/
ALTER PROCEDURE simple_test COMPILE plsql_code_type= native
/

/*
Compare the run times.
*/

BEGIN
   pls_test (123456789);
END;
/

/* We saw:
123456789 iterations had run time of:+000000000 00:00:03.703000000
*/

BEGIN
   simple_test (123456789);
END;
/

/* We saw:
123456789 iterations had run time of:+000000000 00:00:01.203000000
*/




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
