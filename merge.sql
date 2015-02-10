DROP TABLE bonuses;

CREATE TABLE bonuses (employee_id NUMBER, bonus NUMBER DEFAULT 100);

REM Initial bonuses of 20%, incremental bonuses 10%

INSERT INTO bonuses
            (employee_id, bonus)
   (SELECT e.employee_id, salary * 0.2
      FROM employees e
     WHERE department_id != 80);

SELECT   b.employee_id, e.department_id, bonus
    FROM bonuses b, employees e
   WHERE b.employee_id = e.employee_id
ORDER BY e.department_id;

CREATE OR REPLACE PROCEDURE time_use_merge (
   dept_in   IN   employees.department_id%TYPE
)
IS
BEGIN
   MERGE INTO bonuses d
      USING (SELECT employee_id, salary, department_id
               FROM employees
              WHERE department_id = dept_in) s
      ON (d.employee_id = s.employee_id)
      WHEN MATCHED THEN
         UPDATE
            SET d.bonus = d.bonus + s.salary * .01
      WHEN NOT MATCHED THEN
         INSERT (d.employee_id, d.bonus)
         VALUES (s.employee_id, s.salary * 0.2);
END;
/

SELECT   b.employee_id, e.department_id, bonus
    FROM bonuses b, employees e
   WHERE b.employee_id = e.employee_id
ORDER BY e.department_id;

-- Traditional PL/SQL implementation

CREATE OR REPLACE PROCEDURE time_no_merge1 (
   dept_in   IN   employees.department_id%TYPE
)
IS
   FUNCTION bonus_exists (id_in IN employees.employee_id%TYPE)
      RETURN BOOLEAN
   IS
      onechar   CHAR (1);
   BEGIN
      SELECT 'x'
        INTO onechar
        FROM bonuses
       WHERE employee_id = id_in;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;
BEGIN
   FOR rec IN (SELECT employee_id, salary, department_id
                 FROM employees
                WHERE department_id = dept_in)
   LOOP
      IF bonus_exists (rec.employee_id)
      THEN
         UPDATE bonuses
            SET bonus = bonus + rec.salary * .01
          WHERE employee_id = rec.employee_id;
      ELSE
         INSERT INTO bonuses
                     (employee_id, bonus
                     )
              VALUES (rec.employee_id, rec.salary * 0.2
                     );
      END IF;
   END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE time_no_merge2 (
   dept_in   IN   employees.department_id%TYPE
)
IS
BEGIN
   FOR rec IN (SELECT employee_id, salary, department_id
                 FROM employees
                WHERE department_id = dept_in)
   LOOP
      UPDATE bonuses
         SET bonus = bonus + rec.salary * .01
       WHERE employee_id = rec.employee_id;

      IF SQL%ROWCOUNT = 0
      THEN
         INSERT INTO bonuses
                     (employee_id, bonus
                     )
              VALUES (rec.employee_id, rec.salary * 0.2
                     );
      END IF;
   END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE test_merge (count_in IN INTEGER)
IS
   merge_tmr   tmr_t := tmr_t.make ('Use Merge', count_in);
   loop1_tmr   tmr_t
                   := tmr_t.make ('Use Cursor FOR Loop with check', count_in);
   loop2_tmr   tmr_t
                := tmr_t.make ('Use Cursor FOR Loop without check', count_in);
BEGIN
   p.l ('Compare MERGE to Cursor FOR loop for ' || count_in || ' iterations');
   merge_tmr.go;

   FOR indx IN 1 .. count_in
   LOOP
      time_use_merge (50);
      ROLLBACK;
   END LOOP;

   merge_tmr.STOP;
   loop1_tmr.go;

   FOR indx IN 1 .. count_in
   LOOP
      time_no_merge1 (50);
      ROLLBACK;
   END LOOP;

   loop1_tmr.STOP;
   loop2_tmr.go;

   FOR indx IN 1 .. count_in
   LOOP
      time_no_merge2 (50);
      ROLLBACK;
   END LOOP;

   loop2_tmr.STOP;
END;
/

BEGIN
   test_merge (1);
/*
Compare MERGE to Cursor FOR loop for 1000 iterations
Elapsed time for "Use Merge" = 16.53 seconds. Per repetition timing = .01653 seconds.
Elapsed time for "Use Cursor FOR Loop with check" = 39.05 seconds. Per repetition timing = .03905 seconds.
Elapsed time for "Use Cursor FOR Loop without check" = 29.27 seconds. Per repetition timing = .02927 seconds.
*/
END;
/

/*

Does MERGE work with FORALL?
* The answer is YES in Oracle11...

*/

CREATE OR REPLACE PROCEDURE time_use_merge
IS
   TYPE dept_ids_t IS TABLE OF employees.department_id%TYPE
      INDEX BY PLS_INTEGER;

   dept_ids   dept_ids_t;
BEGIN
   SELECT department_id
   BULK COLLECT INTO dept_ids
     FROM departments;

   FORALL indx IN 1 .. dept_ids.COUNT
      MERGE INTO bonuses d
         USING (SELECT employee_id, salary, department_id
                  FROM employees
                 WHERE department_id = dept_ids (indx)) s
         ON (d.employee_id = s.employee_id)
         WHEN MATCHED THEN
            UPDATE
               SET d.bonus = d.bonus + s.salary * .01
         WHEN NOT MATCHED THEN
            INSERT (d.employee_id, d.bonus)
            VALUES (s.employee_id, s.salary * 0.2);
END;
/

BEGIN
   time_use_merge;
END;
/