DECLARE
   old_date    DATE;
   curr_date   DATE := SYSDATE;
BEGIN
   BEGIN
      LOOP
         old_date := curr_date;
         curr_date := curr_date + 1;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
         DBMS_OUTPUT.put_line (
            'Latest date: ' || TO_CHAR (old_date, 'MM-DD-YYYY')
         );
   END;

   BEGIN
      curr_date := SYSDATE;

      LOOP
         old_date := curr_date;
         curr_date := curr_date - 1;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
         DBMS_OUTPUT.put_line (
            'Earliest date: ' || TO_CHAR (old_date, 'MM-DD-YYYY')
         );
   END;
END;
/
