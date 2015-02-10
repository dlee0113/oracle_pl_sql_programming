CREATE OR REPLACE PROCEDURE showcol (
   tab IN VARCHAR2,
   col IN VARCHAR2,
   dtcol IN VARCHAR2,
   dt1 IN DATE,
   dt2 IN DATE := NULL)
IS
   cv SYS_REFCURSOR; 
   val VARCHAR2(32767);  
BEGIN
   OPEN cv FOR 
      'SELECT ' || col || 
      '  FROM ' || tab ||
      ' WHERE ' || dtcol || 
         ' BETWEEN TRUNC (:startdt) 
               AND TRUNC (:enddt)'
   USING dt1, NVL (dt2, dt1+1);
      
   LOOP
      FETCH cv INTO val;
      EXIT WHEN cv%NOTFOUND;
      IF cv%ROWCOUNT = 1
      THEN
         DBMS_OUTPUT.PUT_LINE (RPAD ('-', 70, '-'));
         DBMS_OUTPUT.PUT_LINE (
            'Contents of ' || 
            UPPER (tab) || '.' || UPPER (col) ||
            ' for ' || UPPER (dtcol) || ' between ' ||
            dt1 || ' and ' || NVL (dt2, dt1));
         DBMS_OUTPUT.PUT_LINE (RPAD ('-', 70, '-'));
      END IF;
      DBMS_OUTPUT.PUT_LINE (val);
   END LOOP;
   
   CLOSE cv;
END;
/   

      


















      

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
