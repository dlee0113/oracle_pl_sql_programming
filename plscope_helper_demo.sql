ALTER SESSION SET plscope_settings='identifiers:all'
/

CREATE OR REPLACE PACKAGE great_package
IS
   some_public_global_variable   NUMBER (10);
   g_and_another_one             BOOLEAN;

   PROCEDURE wonderful_program (
      input_param1_in   IN     NUMBER
    ,  p_param2          IN OUT DATE);
END great_package;
/

CREATE OR REPLACE PACKAGE BODY great_package
IS
   TYPE emprec IS RECORD
   (
      l_name   VARCHAR2 (20)
    ,  job      VARCHAR2 (20)
   );

   g_emp      emprec;
   global_1   POSITIVE;

   PROCEDURE wonderful_program (
      input_param1_in   IN     NUMBER
    ,  p_param2          IN OUT DATE)
   IS
      name       VARCHAR2 (100) := 'LUCAS';
      v_salary   NUMBER (10, 2);
      b_job      VARCHAR2 (20);
      hiredate   DATE;
   BEGIN
      /* PLScope does NOT do CRUD analysis. Sigh.... */

      UPDATE employees
         SET salary = salary;

      GOTO all_done;

      v_salary := 5432.12;
      DBMS_OUTPUT.put_line ('My Name is ' || name);
      DBMS_OUTPUT.put_line ('My Job is ' || b_job);
      v_salary := v_salary * 2;
      hiredate := SYSDATE - 1;

     <<all_done>>
      DBMS_OUTPUT.put_line (
         'I started this job on ' || hiredate);
   END wonderful_program;
END great_package;
/

CREATE OR REPLACE PROCEDURE test_plscope (n IN NUMBER)
IS
BEGIN
   NULL;
END;
/

BEGIN
   DBMS_OUTPUT.enable (1000000);
   plscope_helper.show_identifiers_in (USER
                                     ,  'GREAT_PACKAGE');
   plscope_helper.all_changes_to (USER
                                ,  'GREAT_PACKAGE'
                                ,  'V_SALARY');
   plscope_helper.should_start_with (
      USER
    ,  'GREAT_PACKAGE'
    ,  q'['FORMAL IN', 'FORMAL IN OUT', 'FORMAL OUT']'
    ,  'p_');
   plscope_helper.should_end_with (USER
                                 ,  'GREAT_PACKAGE'
                                 ,  q'['FORMAL IN OUT']'
                                 ,  '_io');
   plscope_helper.exposed_package_data_in (
      USER
    ,  'GREAT_PACKAGE');
END;
/