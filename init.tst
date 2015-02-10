/* 
   The first time this is run, especially after a fresh compile, 
   you should see the first access take more time, and then the
	second access less time (probably 0 hundredths of seconds, actually).

   If you the script a second time, both accesses with take "no" time.
*/
begin
   sf_timer.start_timer;
   do.pl /* do.pkg */ (sessinit.printer);
   do.pl /* do.pkg */ (sessinit.show_lov);
   sf_timer.show_elapsed_time;
   
   sf_timer.start_timer;
   do.pl /* do.pkg */ (sessinit.printer);
   do.pl /* do.pkg */ (sessinit.show_lov);
   sf_timer.show_elapsed_time;
end;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
