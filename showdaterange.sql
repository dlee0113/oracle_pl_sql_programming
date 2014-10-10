CREATE TABLE dates (dateval DATE);

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
		 INSERT INTO dates VALUES (old_date);
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
		 INSERT INTO dates VALUES (old_date);
   END;
END;
/

SELECT * FROM dates;




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
