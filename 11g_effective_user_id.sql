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