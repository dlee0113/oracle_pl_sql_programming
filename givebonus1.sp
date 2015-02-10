CREATE OR REPLACE PROCEDURE give_bonus (
   dept_in IN employees.department_id%TYPE,
   bonus_in IN NUMBER)
/*
|| Give the same bonus to each employee in the
|| specified department, but only if they have
|| been with the company for at least 6 months.
*/
IS
   l_name VARCHAR2(50);

   CURSOR by_dept_cur 
   IS
      SELECT *
        FROM employees
       WHERE department_id = dept_in;

   fdbk INTEGER;
BEGIN
   /* Retrieve all information for the specified department. */
   SELECT department_name
     INTO l_name
     FROM departments
    WHERE department_id = dept_in;

   /* Make sure the department ID was valid. */
   IF l_name IS NULL
   THEN
      DBMS_OUTPUT.PUT_LINE (
         'Invalid department ID specified: ' || dept_in);   
   ELSE
      /* Display the header. */
      DBMS_OUTPUT.PUT_LINE (
         'Applying Bonuses of ' || bonus_in || 
         ' to the ' || l_name || ' Department');
   END IF;

   /* For each employee in the specified department... */
   FOR rec IN by_dept_cur
   LOOP
      -- Function in rules package (rp) determines if
	  -- employee should get a bonus. 
	  -- Note: this program is NOT IMPLEMENTED! 
      IF employee_rp.eligible_for_bonus (rec)  
      THEN
         /* Update this column. */

         UPDATE employees
            SET salary = rec.salary + bonus_in
          WHERE employee_id = rec.employee_id;

         /* Make sure the update was successful. */
         IF SQL%ROWCOUNT = 1
         THEN
            DBMS_OUTPUT.PUT_LINE (
               '* Bonus applied to ' ||
               rec.last_name); 
         ELSE
            DBMS_OUTPUT.PUT_LINE (
               '* Unable to apply bonus to ' ||
               rec.last_name); 
         END IF;
      END IF;
   END LOOP;
END;
/
