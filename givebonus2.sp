CREATE OR REPLACE PROCEDURE give_bonus (
   dept_in    IN   employees_tp.department_id_t
 , bonus_in   IN   employees_tp.bonus_t
)
IS
   l_department     departments_tp.department_rt;
   l_employees      employees_tp.employee_tc;
   l_rows_updated   PLS_INTEGER;
BEGIN
   l_department := departments_tp.onerow (dept_in);
   l_employees := employees_qp.ar_fk_emp_department (dept_in);
   
   FOR l_index IN 1 .. l_employees.COUNT
   LOOP
      IF employees_rp.eligible_for_bonus (rec)
      THEN
         employees_cp.upd_onecol_pky
            (colname_in          => 'salary'
           , new_value_in        =>   l_employees (l_index).salary
                                    + bonus_in
           , employee_id_in      => l_employees (l_index).employee_id
           , rows_out            => l_rows_updated
            );
      END IF;
   END LOOP;
   
   -- ... more processing with name and other elements
END;
/