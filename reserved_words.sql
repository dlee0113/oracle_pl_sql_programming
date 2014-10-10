DECLARE
   l_count                 PLS_INTEGER;
   l_use_in_plsql          DBMS_SQL.varchar2a;
   l_cannot_use_in_plsql   DBMS_SQL.varchar2a;
BEGIN
   SELECT COUNT ( * )
     INTO l_count
     FROM v$reserved_words;

   FOR rword_rec IN (SELECT *
                       FROM v$reserved_words)
   LOOP
      BEGIN
         EXECUTE IMMEDIATE   'DECLARE '
                          || rword_rec.keyword
                          || ' NUMBER; BEGIN '
                          || rword_rec.keyword
                          || ' := 1; END;';

         l_use_in_plsql (l_use_in_plsql.COUNT + 1) := rword_rec.keyword;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_cannot_use_in_plsql (l_cannot_use_in_plsql.COUNT + 1) :=
               rword_rec.keyword;
      END;
   END LOOP;

   DBMS_OUTPUT.put_line ('Reserved Word Analysis Summary');
   DBMS_OUTPUT.put_line ('Total count in V$RESERVED_WORDS = ' || l_count);
   DBMS_OUTPUT.put_line (
      'Total number of reserved words = ' || l_cannot_use_in_plsql.COUNT
   );
   DBMS_OUTPUT.put_line (
      'Total number of non-reserved words = ' || l_use_in_plsql.COUNT
   );

   DBMS_OUTPUT.put_line (
      CHR (10) || 'Reserved Words in PL/SQL - Cannot Use as Identifiers'
   );

   FOR indx IN 1 .. l_cannot_use_in_plsql.COUNT
   LOOP
      DBMS_OUTPUT.put_line (l_cannot_use_in_plsql (indx));
   END LOOP;

   DBMS_OUTPUT.put_line(CHR (10)
                        || 'Not Really Reserved Words in PL/SQL - Can Use as Identifiers');

   FOR indx IN 1 .. l_use_in_plsql.COUNT
   LOOP
      DBMS_OUTPUT.put_line (l_use_in_plsql (indx));
   END LOOP;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
