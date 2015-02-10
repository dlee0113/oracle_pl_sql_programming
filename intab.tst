@intab_dbms_sql.sp

DROP TABLE intab_test
/
CREATE TABLE intab_test (
   NAME VARCHAR(100),
   ID NUMBER (5),
   amount NUMBER (10,2),
   dob DATE)
/

BEGIN
   INSERT INTO intab_test
               (NAME, ID, amount, dob
               )
        VALUES ('Steven', 304, 500.46, ADD_MONTHS (SYSDATE, -12 * 46)
               );

   INSERT INTO intab_test
               (NAME, ID, amount, dob
               )
        VALUES ('Roger', 111, 7080.90, ADD_MONTHS (SYSDATE, -12 * 12)
               );

   INSERT INTO intab_test
               (NAME, ID, amount, dob
               )
        VALUES ('Sally', 1000, 100000, ADD_MONTHS (SYSDATE, -12 * 25)
               );

   COMMIT;
END;
/

BEGIN
   -- Show all rows in the table.
   intab (table_in => 'INTAB_TEST');
END;
/

BEGIN
   -- Show all rows whose name column values contain the letter "S".
   intab (table_in => 'INTAB_TEST', where_in => 'name like ''S%''');
END;
/

BEGIN
   -- Order data displayed by NAME.
   intab (table_in => 'INTAB_TEST', where_in => 'order by name');
END;
/

BEGIN
   -- Order by name and show only columns whose names contain an "A".
   intab (table_in             => 'INTAB_TEST'
         ,where_in             => 'order by name'
         ,colname_like_in      => '%A%'
         );
END;
/