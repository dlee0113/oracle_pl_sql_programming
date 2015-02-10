CREATE TABLE sql_varchar2 (really_big_name VARCHAR2 (32767))
/

DECLARE
   l_name   VARCHAR2 (32767)
               := RPAD ('Steven', 32767, 'Feuerstein');
BEGIN
   INSERT INTO sql_varchar2
        VALUES (l_name);
END;
/