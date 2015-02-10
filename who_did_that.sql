CREATE OR REPLACE PROCEDURE who_did_that (
   emp_in IN emp.empno%TYPE)
IS
   v_ename emp.ename%TYPE;
   
   line VARCHAR2(1023);
   fid UTL_FILE.FILE_TYPE;
   eof EXCEPTION;
   
   list_of_numbers PLVtab.number_table;
   undefined_row EXCEPTION;
   
   PROCEDURE read_file IS
   BEGIN
      fid := UTL_FILE.FOPEN ('c:\temp', 'notme.sql', 'R');
      UTL_FILE.GET_LINE (fid, line);
      UTL_FILE.GET_LINE (fid, line);
   EXCEPTION 
      WHEN NO_DATA_FOUND
      THEN
         RAISE eof;
   END;

   PROCEDURE process_collection IS
   BEGIN
      IF list_of_numbers (100) > 0
      THEN
         dbms_output.put_line ('Positive value at row 100');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RAISE undefined_row;
   END;
BEGIN
   SELECT ename INTO v_ename
     FROM emp
    WHERE empno = emp_in;

   read_file;
      
   process_collection;

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      dbms_output.put_line ('implicit query failure only');
      
   WHEN eof
   THEN
      dbms_output.put_line ('Read past end of file');
	  
   WHEN UNDEFINED_ROW 
   THEN
      dbms_output.put_line ('No row in table');

END who_did_that;
/
