/* Demonstrations of SQL functions being applied to CLOB values. This
   is referred to as "SQL semantics for SQL". */
DECLARE
   name CLOB;
   name_upper CLOB;
   directions CLOB;
   blank_space VARCHAR2(1) := ' ';
BEGIN
   --Retrieve a VARCHAR2 into a CLOB, apply a function to a CLOB
   SELECT falls_name, SUBSTR(falls_directions,1,500)
   INTO name, directions
   FROM waterfalls
   WHERE falls_name = 'Munising Falls';

   --Uppercase a CLOB
   name_upper := UPPER(name);

   -- Compare to CLOBs
   IF name = name_upper THEN
      DBMS_OUTPUT.PUT_LINE('We did not need to uppercase the name.');
   END IF;

   --Concatenate a CLOB with some VARCHAR2 strings
   IF INSTR(directions,'Mackinac Bridge') <> 0 THEN
      DBMS_OUTPUT.PUT_LINE('To get to ' || name_upper || blank_space
                           || 'you must cross the Mackinac Bridge.');
   END IF;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
