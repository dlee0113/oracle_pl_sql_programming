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