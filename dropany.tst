@ssoo

BEGIN  
   dropany ('TABLE', 'blip');
EXCEPTION
   WHEN OTHERS
   THEN 
      DECLARE  
         v_errcode PLS_INTEGER;
         v_errtext VARCHAR2(1000);
      BEGIN
         getErrorInfo (v_errcode, v_errtext);
         DBMS_OUTPUT.PUT_LINE (v_errcode);
         DBMS_OUTPUT.PUT_LINE (v_errtext);
      END;
END;
/

/* Or write to a log table using the log81
   package found in log81.pkg. */

BEGIN  
   dropany ('TABLE', 'blip');
EXCEPTION
   WHEN OTHERS
   THEN 
      DECLARE  
         v_errcode PLS_INTEGER;
         v_errtext VARCHAR2(1000);
      BEGIN
         getErrorInfo (v_errcode, v_errtext);
         log81.saveline (v_errcode, v_errtext);
      END;
END;
/


   


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
