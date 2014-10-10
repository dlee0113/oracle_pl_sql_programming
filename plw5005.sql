CREATE OR REPLACE FUNCTION no_return (check_in IN BOOLEAN)
   RETURN VARCHAR2
AS
BEGIN
   IF check_in
   THEN
      RETURN 'abc';
   ELSE
      DBMS_OUTPUT.put_line ('Here I am, here I stay');

      IF check_in
      THEN
         RETURN 'def';
      ELSIF SYSDATE IS NOT NULL
      THEN
         RETURN 'qrs';
      ELSE
         DBMS_OUTPUT.put_line ('Hello!');
      END IF;
   END IF;
END no_return;
/

SHOW ERRORS FUNCTION no_return



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
