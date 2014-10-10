CREATE OR REPLACE PROCEDURE get_nextline 
	(file_in IN UTL_FILE.FILE_TYPE, 
	 line_out OUT VARCHAR2, 
	 eof_out OUT BOOLEAN)
IS
BEGIN
	UTL_FILE.GET_LINE (file_in, line_out);
	eof_out := FALSE;
EXCEPTION
	WHEN NO_DATA_FOUND
	THEN
		line_out := NULL;
		eof_out  := TRUE;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
