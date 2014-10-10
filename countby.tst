DECLARE
   results grp.results_tt;
   indx PLS_INTEGER;
   minrow PLS_INTEGER;
   maxrow PLS_INTEGER;
BEGIN
   results := grp.countby ('employee', 'department_id');
   
   indx := results.FIRST;
   LOOP
      EXIT WHEN indx IS NULL;
      
      IF minrow IS NULL OR
         minrow > results(indx).countby
      THEN 
         minrow := indx; 
      END IF;
      
      IF maxrow IS NULL OR
         maxrow < results(indx).countby
      THEN   
         maxrow := indx; 
      END IF;
      
      DBMS_OUTPUT.PUT_LINE (
         results(indx).val || ' - ' || results(indx).countby);

      indx := results.NEXT(indx);
   END LOOP;
END;
/




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/