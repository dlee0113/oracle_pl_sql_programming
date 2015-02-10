DROP TABLE books;

CREATE TABLE books(
  book_id  NUMBER  NOT NULL  PRIMARY KEY,
  title  VARCHAR2(200),
  author  VARCHAR2(200) );
  
BEGIN
   INSERT INTO books
        VALUES (1, 'Oracle SQL*Plus', 'GENNICK,JONATHAN');

   INSERT INTO books
        VALUES (2, 'Oracle PL/SQL Programming', 'FEUERSTEIN, STEVEN WITH BILL PRIBYL');

   INSERT INTO books
        VALUES (3, 'Oracle PL/SQL Best Practices', 'FEUERSTEIN,STEVEN');

   INSERT INTO books
        VALUES (4, 'Oracle PL/SQL Built-in Packages', 'FEUERSTEIN,STEVEN AND JOHN BERESNIEWICZ AND CHARLES DYE');

   COMMIT;
END;
/

BEGIN
   DBMS_OUTPUT.put_line (
      'Fill and show in same block:'
   );
   book_info.fill_list;
   book_info.show_list;
END;
/
BEGIN
   DBMS_OUTPUT.put_line ('Fill in first block:');
   book_info.fill_list;
END;
/
BEGIN
   DBMS_OUTPUT.put_line ('Show in second block:');
   book_info.show_list;
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
