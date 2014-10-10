/*-- say_nothing.sql */
DROP VIEW x_view;
DROP TABLE x;

CREATE TABLE x
(col1 NUMBER);

CREATE VIEW x_view
AS SELECT *
     FROM x;

CREATE OR REPLACE TRIGGER x_view_insert
INSTEAD OF INSERT ON x_view
BEGIN
  NULL;
END;
/

INSERT INTO x_view
VALUES(1);

EXEC DBMS_OUTPUT.PUT_LINE('SQLCODE = ' || SQLCODE);
EXEC DBMS_OUTPUT.PUT_LINE('SQLROWCOUNT = ' || SQL%ROWCOUNT);

SELECT *
  FROM x_view;

SELECT *
  FROM x;

CREATE OR REPLACE TRIGGER x_view_insert
INSTEAD OF INSERT ON x_view
BEGIN
  RAISE_APPLICATION_ERROR(-20000,'ERROR: Nothing was inserted');
END;
/

INSERT INTO x_view
VALUES(1);

EXEC DBMS_OUTPUT.PUT_LINE('SQLCODE = ' || SQLCODE);
EXEC DBMS_OUTPUT.PUT_LINE('SQLROWCOUNT = ' || SQL%ROWCOUNT);

SELECT *
  FROM x_view;

SELECT *
  FROM x;





/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
