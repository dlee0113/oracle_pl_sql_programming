SELECT *
  FROM user_triggers tr
 WHERE when_clause IS NULL AND 
       EXISTS (SELECT 'x'
                 FROM user_trigger_cols
                WHERE trigger_owner = USER
			    AND trigger_name = tr.trigger_name);
