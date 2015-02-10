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
      int1 := int1 + int2;
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
      int1 := int1 + int2;
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
123456789 iterations had run time of:+000000000 00:00:07.026167000
*/

BEGIN
   simple_test (123456789);
END;
/

/* We saw:
123456789 iterations had run time of:+000000000 00:00:06.750064000
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
123456789 iterations had run time of:+000000000 00:00:01.766409000
*/

BEGIN
   simple_test (123456789);
END;
/

/* We saw:
123456789 iterations had run time of:+000000000 00:00:00.725167000
*/