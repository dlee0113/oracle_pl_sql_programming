DECLARE 
   our_authors strings_nt := strings_nt();
BEGIN
    our_authors := authors_pkg.steven_authors 
                   MULTISET UNION authors_pkg.veva_authors;

    authors_pkg.show_authors ('MINE then VEVA', our_authors);
    
    our_authors := authors_pkg.veva_authors 
                   MULTISET UNION authors_pkg.steven_authors;

    authors_pkg.show_authors ('VEVA then MINE', our_authors);
    
    our_authors := authors_pkg.steven_authors 
                   MULTISET UNION DISTINCT authors_pkg.veva_authors;

    authors_pkg.show_authors ('MINE then VEVA with DISTINCT', our_authors);
    
    our_authors := authors_pkg.steven_authors
                   MULTISET INTERSECT authors_pkg.veva_authors;

    authors_pkg.show_authors ('IN COMMON', our_authors);    
    
    our_authors := authors_pkg.veva_authors 
                   MULTISET EXCEPT authors_pkg.steven_authors;

    authors_pkg.show_authors (q'[ONLY VEVA'S]', our_authors);       
END;
/

