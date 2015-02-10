@tmr.ot

SET serveroutput on format wrapped

DROP SEQUENCE my_sequence
/
CREATE SEQUENCE my_sequence
/

DECLARE
   l_value      PLS_INTEGER;
   dual_tmr     tmr_t       := NEW tmr_t ('Select from dual', 1000000);
   direct_tmr   tmr_t       := NEW tmr_t ('Direct', 1000000);
BEGIN
   dual_tmr.go;

   FOR indx IN 1 .. 1000000
   LOOP
      SELECT my_sequence.NEXTVAL
        INTO l_value
        FROM DUAL;
   END LOOP;

   dual_tmr.STOP;
   --
   direct_tmr.go;

   FOR indx IN 1 .. 1000000
   LOOP
      l_value := my_sequence.NEXTVAL;
   END LOOP;

   direct_tmr.STOP;
END;
/

/*
No noticeable difference in performance!

Timings in seconds for "Select from dual":
Elapsed = 49.05 
Timings in seconds for "Direct":
Elapsed = 49.17 

*/