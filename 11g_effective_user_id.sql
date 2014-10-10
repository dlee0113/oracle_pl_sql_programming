CREATE OR REPLACE PROCEDURE use_cursor (security_level_in IN PLS_INTEGER
                                      , cursor_out IN OUT NUMBER
                                       )
   AUTHID DEFINER
IS
BEGIN
   cursor_out := DBMS_SQL.open_cursor (security_level_in);
   DBMS_SQL.parse (cursor_out
                 , 'select count(*) from all_source'
                 , DBMS_SQL.native
                  );
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
