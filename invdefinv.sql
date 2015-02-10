CREATE OR REPLACE PROCEDURE showestack
IS
BEGIN
   p.l (RPAD ('=', 60, '='));
   p.l (DBMS_UTILITY.format_call_stack);
   p.l (RPAD ('=', 60, '='));
END;
/
CREATE OR REPLACE PROCEDURE Proc1
AUTHID CURRENT_USER
IS
   num   PLS_INTEGER;
BEGIN
   SELECT COUNT (*)        
     INTO num
     FROM EMP;
   showestack;
   DBMS_OUTPUT.put_line (   'proc 1 invoker emp count '
                         || num);
END;
/
GRANT EXECUTE ON Proc1 TO demo;

CREATE OR REPLACE PROCEDURE Proc2
AUTHID DEFINER
IS
   num   PLS_INTEGER;
BEGIN
   SELECT COUNT (*)
     INTO num
     FROM EMP;
   showestack;
   DBMS_OUTPUT.put_line (   'proc 2 definer emp count '
                         || num);
   Proc1;
END;
/
GRANT EXECUTE ON Proc2 TO demo;

CREATE OR REPLACE PROCEDURE Proc3
AUTHID CURRENT_USER
IS
   num   PLS_INTEGER;
BEGIN
   SELECT COUNT (*)
     INTO num
     FROM EMP;
   showestack;
   DBMS_OUTPUT.put_line (   'proc 3 invoker emp count '
                         || num);
   Proc2;
END;
/

GRANT EXECUTE ON Proc3 TO demo;


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
