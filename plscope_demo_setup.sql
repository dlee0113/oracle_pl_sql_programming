ALTER SESSION SET plscope_settings='identifiers:all'
/

CREATE OR REPLACE PACKAGE plscope_demo
IS
   g_global   NUMBER;

   PROCEDURE my_procedure (
      param1_in   IN INTEGER,
      param2      IN employees.last_name%TYPE);

   --PROCEDURE my_procedure (param1_in IN INTEGER);
END plscope_demo;
/

CREATE OR REPLACE PACKAGE BODY plscope_demo
IS
   g_private_global   NUMBER;

   PROCEDURE my_procedure (
      param1_in   IN INTEGER,
      param2      IN employees.last_name%TYPE)
   IS
      c_no_such       CONSTANT NUMBER := 100;
      l_local_variable         NUMBER;
      another_local_variable   DATE;
   BEGIN
      IF param1_in > l_local_variable
      THEN
         DBMS_OUTPUT.put_line (param2);
      ELSE
         DBMS_OUTPUT.put_line (c_no_such);
      END IF;
   END my_procedure;

--   PROCEDURE my_procedure (param1_in IN INTEGER)
--   IS
--   BEGIN
--      NULL;
--   END;

   FUNCTION my_priv_function
      RETURN NUMBER
   IS
   BEGIN
      RETURN 0;
   END;

   PROCEDURE plscope_demo_proc
   IS
      e_bad_data    EXCEPTION;
      PRAGMA EXCEPTION_INIT (e_bad_data, -20900);
      e_bad_data2   EXCEPTION;
   BEGIN
      RAISE e_bad_data2;
   EXCEPTION
      WHEN e_bad_data2
      THEN
         NULL;                                    --log_error ();
   END plscope_demo_proc;
END plscope_demo;
/

CREATE OR REPLACE PACKAGE plscope_demo2
IS
   some_public_global_variable   NUMBER (10);
   g_and_another_one             BOOLEAN;

   PROCEDURE wonderful_program (input_param1   IN     NUMBER,
                                p_param2       IN OUT DATE);
END plscope_demo2;
/

CREATE OR REPLACE PACKAGE BODY plscope_demo2
IS
   TYPE emprec IS RECORD
   (
      l_name   VARCHAR2 (20),
      job      VARCHAR2 (20)
   );

   g_emp      emprec;
   global_1   POSITIVE;

   PROCEDURE wonderful_program (input_param1   IN     NUMBER,
                                p_param2       IN OUT DATE)
   IS
      name       VARCHAR2 (100) := 'LUCAS';
      v_salary   NUMBER (10, 2);
      b_job      VARCHAR2 (20);
      hiredate   DATE;
   BEGIN
      v_salary := 5432.12;
      DBMS_OUTPUT.put_line ('My Name is ' || name);
      DBMS_OUTPUT.put_line ('My Job is ' || b_job);
      hiredate := SYSDATE - 1;
      DBMS_OUTPUT.put_line (
         'I started this job on ' || hiredate);
      plscope_demo.my_procedure (1, 'Smith');
   END wonderful_program;
END plscope_demo2;
/