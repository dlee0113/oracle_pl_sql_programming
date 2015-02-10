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
