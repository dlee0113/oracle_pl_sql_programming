DECLARE
      test_grid   VARCHAR2 (1000) := '
betwnstr|1|start at 1|start at 1|abcdefgh;1;3|abc|eq|N
betwnstr|1|start at 3|start at 3|abcdefgh;3;6|cdef|eq|N
betwnstr|1|null start|null start|abcdefgh;!null;2|null|isnull|Y
betwnstr|1|null end||abcdefgh;!3;!null|null|isnull|Y
betwnstr|1|null string||!null;1;2|NULL|isnull|Y
betwnstr|1|big start small end||abcdefgh;10;5|null|isnull|Y
betwnstr|1|end past string||abcdefgh;1;100|abcdefgh|eq|N';
BEGIN
   utgen.testpkg_from_string ('betwnstr',
      test_grid,
      output_type_in=> utgen.c_file,
      dir_in=> 'TEMP'
   );
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
