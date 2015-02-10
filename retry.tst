DECLARE
   law_and_order VARCHAR2(20) := 'law_and_order';
    
   TYPE string_t IS TABLE OF VARCHAR2(50);
   
   crime string_t := string_t (
      'Steal car at age 14',
      'Caught with a joint at 17',
      'Steal pack of cigarettes at age 42'
      );
      
BEGIN
   retry.set_limit (law_and_order, 2);
   
   FOR indx IN crime.FIRST .. crime.LAST
   LOOP
      DBMS_OUTPUT.PUT_LINE (crime(indx));
      IF retry.limit_reached (law_and_order)
      THEN
         DBMS_OUTPUT.PUT_LINE (
            '...Spend rest of life in prison');
      ELSE
         DBMS_OUTPUT.PUT_LINE (
            '...Receive punishment that fits the crime');
         retry.incr_attempts (law_and_order);
      END IF;
   END LOOP;
END;
/   


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
