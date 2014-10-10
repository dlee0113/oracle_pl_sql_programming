CREATE OR REPLACE FUNCTION expiration_date (
    good_for_period_in IN INTERVAL YEAR TO MONTH
)
    RETURN TIMESTAMP
IS
   bad_month EXCEPTION;
   PRAGMA EXCEPTION_INIT (bad_month, -1839);

   todays_date TIMESTAMP;
   result_date TIMESTAMP;
BEGIN
   todays_date := TRUNC(SYSTIMESTAMP);
   LOOP
      BEGIN
         result_date := todays_date + good_for_period_in;
      EXCEPTION
         WHEN bad_month THEN
            todays_date := todays_date - INTERVAL '1' DAY;
         WHEN OTHERS THEN
            RAISE;
      END;

      EXIT WHEN result_date IS NOT NULL;
   END LOOP;
   RETURN result_date;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/