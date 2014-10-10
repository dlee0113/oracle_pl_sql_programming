CREATE OR REPLACE PROCEDURE move_buffer_to_log
IS
   l_buffer      DBMS_OUTPUT.chararr;
   l_num_lines   PLS_INTEGER;
BEGIN
   LOOP
      l_num_lines := 100;
      DBMS_OUTPUT.get_lines (l_buffer, l_num_lines);
	  
      EXIT WHEN l_buffer.COUNT = 0;
	  
      FORALL indx IN l_buffer.FIRST .. l_buffer.LAST
         INSERT INTO log_table
                     (text
                     )
              VALUES (l_buffer (indx)
                     );
   END LOOP;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
