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