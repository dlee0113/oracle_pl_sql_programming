DECLARE
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
   bpl (authors_pkg.steven_authors 
            SUBMULTISET OF authors_pkg.eli_authors
      , 'Father follows son?');
   bpl (authors_pkg.eli_authors
            SUBMULTISET OF authors_pkg.steven_authors
      , 'Son follows father?');

   bpl (authors_pkg.steven_authors 
            NOT SUBMULTISET OF authors_pkg.eli_authors
      , 'Father doesn''t follow son?');
   bpl (authors_pkg.eli_authors 
            NOT SUBMULTISET OF authors_pkg.steven_authors
      , 'Son doesn''t follow father?');
END;
/