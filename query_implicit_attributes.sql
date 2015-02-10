DROP TABLE tbl;
CREATE TABLE tbl (onecol NUMBER);

INSERT INTO tbl
     VALUES (1);
INSERT INTO tbl
     VALUES (2);
COMMIT ;

DECLARE
   n   PLS_INTEGER := 0;

   PROCEDURE plsb (str IN VARCHAR2, val IN BOOLEAN)
   IS
   BEGIN
      IF val
      THEN
         DBMS_OUTPUT.put_line (str || ' - TRUE');
      ELSIF NOT val
      THEN
         DBMS_OUTPUT.put_line (str || ' - FALSE');
      ELSE
         DBMS_OUTPUT.put_line (str || ' - NULL');
      END IF;
   END plsb;

   PROCEDURE show_cur_attributes (scope_in IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (scope_in);
      plsb ('   SQL%ISOPEN', SQL%ISOPEN);
      plsb ('   SQL%FOUND', SQL%FOUND);
      plsb ('   SQL%NOTFOUND', SQL%NOTFOUND);
      DBMS_OUTPUT.put_line (   '   SQL%ROWCOUNT - '
                            || NVL (TO_CHAR (SQL%ROWCOUNT), 'NULL')
                           );
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         DBMS_OUTPUT.put_line ('Invalid cursor at this point!');
   END show_cur_attributes;
BEGIN
   SELECT onecol
     INTO n
     FROM tbl
    WHERE onecol = 1;

   show_cur_attributes ('SELECT INTO');

   SELECT onecol
     INTO n
     FROM tbl
    WHERE onecol = 0;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      show_cur_attributes ('SELECT INTO FAILURE');
END;
/