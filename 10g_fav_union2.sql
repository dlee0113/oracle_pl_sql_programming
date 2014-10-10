DECLARE
   our_favorites   
      strings_nt := strings_nt ();
BEGIN
   our_favorites := 
      authors_pkg.veva_authors 
	   MULTISET UNION 
	authors_pkg.steven_authors;
	  
   authors_pkg.show_authors (
      'VEVA THEN STEVEN', our_favorites);
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

