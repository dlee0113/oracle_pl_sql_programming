ALTER SESSION SET plscope_settings='identifiers:all'
/

CREATE OR REPLACE PACKAGE great_package
IS
   some_public_global_variable   NUMBER (10);
   g_and_another_one             BOOLEAN;

   PROCEDURE wonderful_program (input_param1 IN NUMBER, p_param2 IN OUT DATE);
END great_package;
/

CREATE OR REPLACE PACKAGE BODY great_package
IS
   TYPE emprec IS RECORD
   (
      l_name   VARCHAR2 (20)
    , job      VARCHAR2 (20)
   );

   g_emp      emprec;
   global_1   POSITIVE;

   PROCEDURE wonderful_program (input_param1 IN NUMBER, p_param2 IN OUT DATE)
   IS
      name       VARCHAR2 (100) := 'LUCAS';
      v_salary   NUMBER (10, 2);
      b_job      VARCHAR2 (20);
      hiredate   DATE;
   BEGIN
      v_salary := 5432.12;
      DBMS_OUTPUT.put_line ('My Name is ' || name);
      DBMS_OUTPUT.put_line ('My Job is ' || b_job);
      v_salary := v_salary * 2;
      hiredate := SYSDATE - 1;
      DBMS_OUTPUT.put_line ('I started this job on ' || hiredate);
   END wonderful_program;
END great_package;
/

CREATE OR REPLACE PROCEDURE test_plscope (n IN NUMBER)
IS
BEGIN
   NULL;
END;
/

CREATE OR REPLACE PROCEDURE plscope_demo_proc
IS
   e_bad_data    EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_bad_data, -20900);
   e_bad_data2   EXCEPTION;
BEGIN
   RAISE e_bad_data2;
END plscope_demo_proc;
/

BEGIN
   plscope_helper.show_identifiers_in (USER, 'GREAT_PACKAGE');
   plscope_helper.all_changes_to (USER, 'GREAT_PACKAGE', 'V_SALARY');
   plscope_helper.
    should_start_with (USER
                     , '%'
                     , q'['FORMAL IN', 'FORMAL IN OUT', 'FORMAL OUT']'
                     , 'p_'
                      );
   plscope_helper.
    should_start_with (USER
                     , '%'
                     , q'['FORMAL IN', 'FORMAL IN OUT', 'FORMAL OUT']'
                     , '_p'
                      );
   plscope_helper.exposed_package_data_in (USER, 'GREAT_PACKAGE');

   plscope_helper.unused_exceptions_in (USER);
END;
/