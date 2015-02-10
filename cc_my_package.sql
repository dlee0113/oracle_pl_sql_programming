CREATE OR REPLACE PROCEDURE apply_bonus (
   id_in IN employee.employee_id%TYPE
  ,bonus_in IN employee.bonus%TYPE)
IS
BEGIN
   UPDATE employee
      SET bonus =
       $IF employee_rp.apply_sarbanes_oxley
       $THEN
          LEAST (bonus_in, 10000)
       $ELSE
          bonus_in		  
       $END
     WHERE employee_id = id_in;          
   NULL;
END apply_bonus;
/

