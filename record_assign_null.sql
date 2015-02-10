CREATE OR REPLACE FUNCTION dept_for_name (
   department_name_in IN departments.department_name%TYPE
)
   RETURN departments%ROWTYPE
IS
   l_return   departments%ROWTYPE;

   FUNCTION is_secret_department (
      department_name_in IN departments.department_name%TYPE
   )
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN CASE department_name_in
                WHEN 'VICE PRESIDENT' THEN TRUE
                ELSE FALSE
             END;
   END is_secret_department;
BEGIN
   SELECT *
     INTO l_return
     FROM departments
    WHERE department_name = department_name_in;

   IF is_secret_department (department_name_in)
   THEN
      l_return := NULL;
   END IF;

   RETURN l_return;
END dept_for_name;
/