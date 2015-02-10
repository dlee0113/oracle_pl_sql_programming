DECLARE
   distinct_authors strings_nt := strings_nt ();
   
   PROCEDURE bpl (val IN BOOLEAN, str IN VARCHAR2)
   IS
   BEGIN
      IF val
      THEN
         DBMS_OUTPUT.put_line (str || '-TRUE');
      ELSIF NOT val
      THEN
         DBMS_OUTPUT.put_line (str || '-FALSE');
      ELSE
         DBMS_OUTPUT.put_line (str || '-NULL');
      END IF;
   END;	  
BEGIN
   -- Add a duplicate author to Steven's list
   authors_pkg.steven_authors.EXTEND;
   authors_pkg.steven_authors(authors_pkg.steven_authors.LAST) := 'ROBERT HARRIS';

   distinct_authors := 
      SET (authors_pkg.steven_authors);
	  
   authors_pkg.show_authors (
      'FULL SET', authors_pkg.steven_authors);

   bpl (authors_pkg.steven_authors IS A SET, 'My authors distinct?');
   bpl (authors_pkg.steven_authors IS NOT A SET, 'My authors NOT distinct?');
   DBMS_OUTPUT.PUT_LINE ('');
   	  
   authors_pkg.show_authors (
      'DISTINCT SET', distinct_authors);
      	  
   bpl (distinct_authors IS A SET, 'SET of authors distinct?');
   bpl (distinct_authors IS NOT A SET, 'SET of authors NOT distinct?');
   DBMS_OUTPUT.PUT_LINE ('');
	  
END;
/