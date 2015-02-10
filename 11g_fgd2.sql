-- first create a table
CREATE TABLE my_table (col1 NUMBER)
/

-- make a depedency on all columns (SELECT splat)
CREATE OR REPLACE PROCEDURE splat
IS
BEGIN
   FOR rec IN (SELECT *
                 FROM my_table)
   LOOP
      DBMS_OUTPUT.put_line (rec.col1);
   END LOOP;
END;
/

-- make a dependency on only one column
CREATE OR REPLACE PROCEDURE nosplat
IS
BEGIN
   FOR rec IN (SELECT col1
                 FROM my_table)
   LOOP
      DBMS_OUTPUT.put_line (rec.col1);
   END LOOP;
END;
/

-- confirm objects are valid
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_name LIKE '%SPLAT%'
/

-- invalidate dependent objects
ALTER TABLE my_table ADD col2 date
/

-- show invalidations
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_name LIKE '%SPLAT%'
/