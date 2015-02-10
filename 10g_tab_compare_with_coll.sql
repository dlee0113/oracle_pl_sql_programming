CREATE TABLE employee2
AS
   SELECT * FROM employee;

DECLARE
-- Use for testing of equality between relational tables?
   TYPE employee_tt IS TABLE OF employee%ROWTYPE;

   group1    employee_tt;
   group2    employee_tt;
   l_count   INTEGER;
   t1        INTEGER;

   PROCEDURE load1 (e IN OUT employee_tt)
   IS
   BEGIN
      SELECT *
      BULK COLLECT INTO e
        FROM employee;
   END;

   PROCEDURE load2 (e IN OUT employee_tt)
   IS
   BEGIN
      SELECT *
      BULK COLLECT INTO e
        FROM employee2;
   END;
BEGIN
   -- We can use = or !=, but not < or >.
   t1 := DBMS_UTILITY.get_time;
   load1 (group1);
   load2 (group2);

   FOR n IN 1 .. 1000
   LOOP
      IF group1 = group2
      THEN
         NULL;
      END IF;
   END LOOP;

   DBMS_OUTPUT.put_line (DBMS_UTILITY.get_time - t1);
   t1 := DBMS_UTILITY.get_time;

   FOR n IN 1 .. 1000
   LOOP
      SELECT COUNT (*)
        INTO l_count
        FROM ((SELECT *
                 FROM employee
               MINUS
               SELECT *
                 FROM employee2)
              UNION
              (SELECT *
                 FROM employee2
               MINUS
               SELECT *
                 FROM employee));

      IF l_count = 0
      THEN
         NULL;
      END IF;
   END LOOP;

   DBMS_OUTPUT.put_line (DBMS_UTILITY.get_time - t1);
END;
/