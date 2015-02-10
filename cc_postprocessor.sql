CREATE OR REPLACE PROCEDURE post_processed
IS
BEGIN
$IF $$PLSQL_OPTIMIZE_LEVEL = 1
$THEN
   -- Slow and easy
   NULL;
$ELSE
   -- Fast and modern and easy
   NULL;
$END
END post_processed;
/

BEGIN
   dbms_preprocessor.print_post_processed_source (
      'PROCEDURE', USER, 'POST_PROCESSED');
END;
/

DECLARE
   l_postproc_code   dbms_preprocessor.source_lines_t;
   l_row             PLS_INTEGER;
BEGIN
   l_postproc_code :=
      dbms_preprocessor.get_post_processed_source ('PROCEDURE'
                                                 , USER
                                                 , 'POST_PROCESSED'
                                                  );
   l_row := l_postproc_code.FIRST;

   WHILE (l_row IS NOT NULL)
   LOOP
      DBMS_OUTPUT.put_line (  LPAD (l_row, 3)
                            || ' - '
                            || rtrim ( l_postproc_code (l_row),chr(10))
                           );
      l_row := l_postproc_code.NEXT (l_row);
   END LOOP;
  
END;
/