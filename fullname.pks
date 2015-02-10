CREATE OR REPLACE PACKAGE fullname_pkg
AS
   SUBTYPE fullname_t IS VARCHAR2 (1000);

   FUNCTION fullname (
      l employee.last_name%TYPE
    , f employee.first_name%TYPE
    , use_f_l_in IN BOOLEAN := FALSE         -- London 2/20/2002
   )
      RETURN fullname_t;

   FUNCTION fullname (
      l employee.last_name%TYPE
    , f employee.first_name%TYPE
    , use_f_l_in IN PLS_INTEGER := 0
   )
      RETURN fullname_t;

   FUNCTION fullname (
      employee_id_in IN employee.employee_id%TYPE
    , use_f_l_in IN BOOLEAN := FALSE         
   )
      RETURN fullname_t;

   FUNCTION fullname_explicit (
      employee_id_in IN employee.employee_id%TYPE
    , use_f_l_in IN BOOLEAN := FALSE
   )
      RETURN fullname_t;

   FUNCTION fullname_twosteps (
      employee_id_in IN employee.employee_id%TYPE
    , use_f_l_in IN BOOLEAN := FALSE
   )
      RETURN fullname_t;
END;
/
