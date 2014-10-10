create table company
(company_id number)
/


create or replace
PROCEDURE calc_annual_sales 
   (company_id_in IN company.company_id%TYPE)
IS
   invalid_company_id   EXCEPTION;
   negative_balance     EXCEPTION;
     
   duplicate_company    BOOLEAN;
BEGIN
   -- ... body of executable statements ...
   null;
EXCEPTION
   WHEN NO_DATA_FOUND   -- system exception
   THEN 
      null;
   WHEN invalid_company_id 
   THEN 
     null;
   WHEN negative_balance 
   THEN 
      null;
END;
/

drop procedure calc_annual_sales
/
drop table company
/


/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/


