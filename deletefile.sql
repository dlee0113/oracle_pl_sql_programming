/* Formatted on 2002/05/22 18:56 (Formatter Plus v4.6.5) */

CREATE TYPE file_details AS OBJECT (
   dirname      VARCHAR2 (30),
   deletedate   DATE)
/


CREATE TYPE file_table AS TABLE OF file_details;
/


CREATE OR REPLACE PACKAGE delete_files
IS 
   FUNCTION fdelete (tbl IN file_table) RETURN NUMBER;
END delete_files;
/


CREATE OR REPLACE PACKAGE BODY delete_files
AS 
   FUNCTION fdelete (tbl file_table) RETURN NUMBER
   AS
   LANGUAGE JAVA
      NAME 'DeleteFile.delete(oracle.sql.ARRAY) return int';
END delete_files;
/


SET serveroutput on size 100000
EXECUTE dbms_java.set_output(2000);

DECLARE
   -- 
   filetab   file_table := file_table ();
   v_ret     NUMBER;
-- 
BEGIN
   -- 
   filetab.EXTEND (2);
   -- 
   filetab (1) :=
           file_details ('c:\temp',   SYSDATE
                                   - 3);
   filetab (2) := file_details (
                     'c:\testdelete',
                     ADD_MONTHS (SYSDATE, -2)
                  );
   -- 
   v_ret := delete_files.fdelete (filetab);
   DBMS_OUTPUT.put_line (TO_CHAR (v_ret));
-- 
END;

/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
