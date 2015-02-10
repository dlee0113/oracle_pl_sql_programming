/* Create objects needed for the various LOB examples.
   READ ALL COMMENTS IN THIS FILE BEFORE EXECUTING IT! */
CREATE TABLE waterfalls (
   falls_name VARCHAR2(80),
   falls_photo BLOB,
   falls_directions CLOB,
   falls_description NCLOB,
   falls_web_page BFILE);

/* Replace the c:\xxx\xxx directory path with path that is valid for your
   system. Place the "Tannery Falls.htm" file into that directory. */
CREATE DIRECTORY bfile_data AS 'c:\xxx\xxx';


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
