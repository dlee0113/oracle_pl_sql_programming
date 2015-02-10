CREATE OR REPLACE PACKAGE BODY fullname_pkg
AS
   FUNCTION fullname (
      l employee.last_name%TYPE
    , f employee.first_name%TYPE
    , use_f_l_in IN BOOLEAN := FALSE
   )
      RETURN fullname_t
   IS
   BEGIN
      IF use_f_l_in
      THEN
         RETURN f || ' ' || l;
      ELSE
         RETURN l || ',' || f;
      END IF;
   END;

   FUNCTION fullname (
      l employee.last_name%TYPE
    , f employee.first_name%TYPE
    , use_f_l_in IN PLS_INTEGER := 0
   )
      RETURN fullname_t
   IS
   BEGIN
      /* One return! Utrecht 11/2003
      IF use_f_l_in = 1
      THEN
         RETURN fullname (l, f, TRUE);
      ELSE
         RETURN fullname (l, f, FALSE);
      END IF;
	  */
	  RETURN fullname (l, f, use_f_l_in = 1);
   END;

   FUNCTION fullname (
      employee_id_in IN employee.employee_id%TYPE
    , use_f_l_in IN BOOLEAN := FALSE          -- London 2/20/2002
   )
      RETURN fullname_t
   IS
      retval fullname_t;
      v_tf PLS_INTEGER;
   BEGIN
      IF use_f_l_in
      THEN
         v_tf := 1;
      ELSE
         v_tf := 0;
      END IF;

      SELECT fullname (last_name, first_name, v_tf)
        INTO retval
        FROM employee
       WHERE employee_id = employee_id_in;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
             /*
            -- London 9/2001
               RETURN excpkg.no_row_found_indicator ('employee');


       name := emppkg.empname(15);
       IF excpkg.row_not_found ('employee', name)
       then
          -- Row not found...
      */
      WHEN TOO_MANY_ROWS
      THEN
         RAISE;
   END;

   FUNCTION fullname_explicit (
      employee_id_in IN employee.employee_id%TYPE
    , use_f_l_in IN BOOLEAN := FALSE          -- London 2/20/2002
   )
      RETURN fullname_t
   IS
      retval fullname_t;
      v_tf PLS_INTEGER;

      CURSOR fullname_cur
      IS
         SELECT fullname (last_name, first_name, v_tf)
           FROM employee
          WHERE employee_id = employee_id_in;
   BEGIN
      IF use_f_l_in
      THEN
         v_tf := 1;
      ELSE
         v_tf := 0;
      END IF;

      OPEN fullname_cur;

      FETCH fullname_cur
       INTO retval;

      CLOSE fullname_cur;

      RETURN retval;
   END;

   FUNCTION fullname_twosteps (
      employee_id_in IN employee.employee_id%TYPE
    , use_f_l_in IN BOOLEAN := FALSE          -- London 2/20/2002
   )
      RETURN fullname_t
   IS
      l_last_name employee.last_name%TYPE;
      l_first_name employee.first_name%TYPE;
   BEGIN
      SELECT last_name, first_name
        INTO l_last_name, l_first_name
        FROM employee
       WHERE employee_id = employee_id_in;

      RETURN fullname (l_last_name, l_first_name, use_f_l_in);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN TOO_MANY_ROWS
      THEN
         RAISE;
   END;
END;
/
