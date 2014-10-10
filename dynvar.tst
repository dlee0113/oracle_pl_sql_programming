CREATE OR REPLACE PACKAGE tstvar
IS
   str1   VARCHAR2 (2000);
   str2   VARCHAR2 (2000);
END;
/

DECLARE
   v_pkgname   CHAR (7)       := 'tstvar.';
   localstr    VARCHAR2 (100);
BEGIN
   dynvar.notrc;
   dynvar.assign ('abc', localstr);
   DBMS_OUTPUT.put_line ('local string SET TO ' || localstr);
   
   dynvar.copyto ('abcdefghi', v_pkgname || 'str1');
   DBMS_OUTPUT.put_line ('global string SET TO ' || tstvar.str1);
   
   DBMS_OUTPUT.put_line (   'value retrieved dynamically '
                         || dynvar.val (v_pkgname || 'str1')
                        );
						
   tstvar.str2 := 'tstvar.str1';
   
   DBMS_OUTPUT.put_line (   'DOUBLE indirection gets us '
                         || dynvar.val (dynvar.val (v_pkgname || 'str2'))
                        );
						
   DBMS_OUTPUT.put_line (   'expression retrieved dynamically '
                         || dynvar.val (v_pkgname || 'str1' || '|| '' wow!''')
                        );
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/