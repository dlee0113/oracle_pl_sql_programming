DECLARE
   our_favorites   
      strings_nt := strings_nt ();
BEGIN
   our_favorites := 
      authors_pkg.veva_authors 
	   MULTISET UNION DISTINCT
	  authors_pkg.steven_authors;
	  
   authors_pkg.show_authors (
      'VEVA THEN STEVEN DISTINCT', our_favorites);
END;
/
