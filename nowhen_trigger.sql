SELECT *
  FROM user_triggers tr
 WHERE when_clause IS NULL AND 
       EXISTS (SELECT 'x'
                 FROM user_trigger_cols
                WHERE trigger_owner = USER
			    AND trigger_name = tr.trigger_name);



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

