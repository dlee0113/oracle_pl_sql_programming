CONNECT SCOTT/TiGER

@@tmr81.ot

CREATE OR REPLACE PROCEDURE count_emp_definer
AUTHID DEFINER
IS 
   n   INTEGER;
BEGIN
   SELECT COUNT (*) into n FROM emp;
END;
/
grant execute on count_emp_definer to demo;

CREATE OR REPLACE PROCEDURE count_emp_invoker
AUTHID CURRENT_USER
IS 
   n   INTEGER;
BEGIN
   SELECT COUNT (*) into n FROM emp;
END;
/
grant execute on count_emp_invoker to demo;

CREATE OR REPLACE PROCEDURE count_emp_nds_definer
AUTHID DEFINER
IS 
   n   INTEGER;
BEGIN
   EXECUTE IMMEDIATE 
   'SELECT COUNT (*) FROM emp' INTO n;
END;
/
grant execute on count_emp_nds_definer to demo;

CREATE OR REPLACE PROCEDURE count_emp_nds_invoker
AUTHID CURRENT_USER
IS 
   n   INTEGER;
BEGIN
   EXECUTE IMMEDIATE 
   'SELECT COUNT (*) FROM emp' INTO n;
END;
/
grant execute on count_emp_nds_invoker to demo;

CONNECT demo/demo
SET SERVEROUTPUT ON SIZE 1000000 FORMAT WRAPPED

DECLARE
   v VARCHAR2(30);
   definer_tmr scott.tmr_t := scott.tmr_t.make ('Definer rights', &&1);
   invoker_tmr scott.tmr_t := scott.tmr_t.make ('Invoker rights', &&1);
   nds_definer_tmr scott.tmr_t := scott.tmr_t.make ('Definer rights with NDS', &&1);
   nds_invoker_tmr scott.tmr_t := scott.tmr_t.make ('Invoker rights with NDS', &&1);
BEGIN
   definer_tmr.go;
   FOR indx IN 1 .. &&1
   LOOP
      scott.count_emp_definer;
   END LOOP;
   definer_tmr.stop;

   invoker_tmr.go;
   FOR indx IN 1 .. &&1
   LOOP
      scott.count_emp_invoker;
   END LOOP;
   invoker_tmr.stop;
   
   nds_definer_tmr.go;
   FOR indx IN 1 .. &&1
   LOOP
      scott.count_emp_nds_definer;
   END LOOP;
   nds_definer_tmr.stop;

   nds_invoker_tmr.go;
   FOR indx IN 1 .. &&1
   LOOP
      scott.count_emp_nds_invoker;
   END LOOP;
   nds_invoker_tmr.stop;
END;
/

/*
10000 iterations

Elapsed time for "Definer rights" = 2.91 seconds. Per repetition timing = .000291 seconds.
Elapsed time for "Invoker rights" = 1.56 seconds. Per repetition timing = .000156 seconds.
Elapsed time for "Definer rights with NDS" = 5.51 seconds. Per repetition timing = .000551 seconds.
Elapsed time for "Invoker rights with NDS" = 3.33 seconds. Per repetition timing = .000333 seconds.

25000 iterations

Elapsed time for "Definer rights" = 7.4 seconds. Per repetition timing = .000296 seconds.
Elapsed time for "Invoker rights" = 3.88 seconds. Per repetition timing = .0001552 seconds.
Elapsed time for "Definer rights with NDS" = 13.61 seconds. Per repetition timing = .0005444 seconds.
Elapsed time for "Invoker rights with NDS" = 8.04 seconds. Per repetition timing = .0003216 seconds.
*/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
