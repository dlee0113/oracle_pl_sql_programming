DECLARE
   our_favorites   
      strings_nt := strings_nt ();
BEGIN
   our_favorites := 
      authors_pkg.steven_authors 
	     MULTISET UNION 
	  authors_pkg.veva_authors;
	  
   authors_pkg.show_authors (
      'STEVEN then VEVA', our_favorites);
END;
/