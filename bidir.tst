BEGIN
   -- Not necessary: initialization section does it: Bidir.loadarray;
   bidir.accumulate;
   bidir.showmaxsal;
   bidir.showminsal;
   bidir.showall;

   DECLARE
      l_employee   employees%ROWTYPE;
   BEGIN
      LOOP
         EXIT WHEN bidir.end_of_data;
         l_employee := bidir.currrow;
         DBMS_OUTPUT.put_line (l_employee.last_name);
         bidir.nextrow;
      END LOOP;

      bidir.setrow (bidir.lastrow);

      LOOP
         EXIT WHEN bidir.end_of_data;
         l_employee := bidir.currrow;
         DBMS_OUTPUT.put_line (l_employee.last_name);
         bidir.prevrow;
      END LOOP;
   END;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
