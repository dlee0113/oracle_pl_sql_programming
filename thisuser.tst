CREATE OR REPLACE PROCEDURE test_thisuser (count_in IN PLS_INTEGER)
IS
   l_name            all_users.username%TYPE;
BEGIN
   sf_timer.start_timer;

   FOR indx IN 1 .. count_in
   LOOP
      l_name := thisuser.NAME;
   END LOOP;

   sf_timer.show_elapsed_time ('Packaged Function');
   --
   sf_timer.start_timer;

   FOR indx IN 1 .. count_in
   LOOP
      l_name := thisuser.cname;
   END LOOP;

   sf_timer.show_elapsed_time ('Packaged Constant');
   --
   sf_timer.start_timer;

   FOR indx IN 1 .. count_in
   LOOP
      l_name := USER;
   END LOOP;

   sf_timer.show_elapsed_time ('USER Function');
END test_thisuser;
/

BEGIN
   test_thisuser (100);
   test_thisuser (1000000);
/* 
Packaged Function Elapsed: .48 seconds.
Packaged Constant Elapsed: .06 seconds.
USER Function Elapsed: 32.6 seconds.
*/   
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/