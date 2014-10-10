DECLARE
   TYPE clientele IS TABLE OF VARCHAR2 (64);

   group1   clientele := clientele ('Customer 1', 'Customer 2');
   group2   clientele := clientele ('Customer 1', 'Customer 3', NULL);
   group3   clientele := clientele ('Customer 3', NULL, 'Customer 1');
BEGIN
   IF group1 = group2
   THEN
      DBMS_OUTPUT.put_line ('Group 1 = Group 2');
   ELSIF group1 != group2
   THEN
      DBMS_OUTPUT.put_line ('Group 1 != Group 2');
   END IF;

   IF group2 != group3
   THEN
      DBMS_OUTPUT.put_line ('Group 2 != Group 3');
   ELSIF group2 = group3
   THEN
      DBMS_OUTPUT.put_line ('Group 2 = Group 3');	  
   END IF;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
