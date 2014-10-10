CREATE OR REPLACE PROCEDURE getErrorInfo (
   errcode OUT INTEGER,
   errtext OUT VARCHAR2)
IS
   c_keyword CONSTANT CHAR(23) := 'java.sql.SQLException: ';
   c_keyword_len CONSTANT PLS_INTEGER := 23;
   v_keyword_loc PLS_INTEGER;
   v_msg VARCHAR2(1000) := SQLERRM;
BEGIN
   v_keyword_loc := INSTR (v_msg, c_keyword);
   IF v_keyword_loc = 0
   THEN
      errcode := SQLCODE;
      errtext := SQLERRM;
   ELSE
      errtext := SUBSTR (
         v_msg, v_keyword_loc + c_keyword_len);
      errcode := 
         SUBSTR (errtext, 4, 6 /* ORA-NNNNN */);
   END IF;
END;
/   




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
