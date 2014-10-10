DECLARE
   l_myname   string_tracker.value_string_t := 'steven';
BEGIN
   string_tracker.clear_used_list;
   string_tracker.mark_as_used (l_myname);
   p.l (string_tracker.string_in_use ('george'));
   p.l (string_tracker.string_in_use (l_myname));
END;



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
