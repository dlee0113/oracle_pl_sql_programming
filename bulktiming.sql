DROP TABLE parts
/

CREATE TABLE parts (
   partnum NUMBER,
   partname VARCHAR2(15)
   )
/
   
CREATE OR REPLACE PROCEDURE compare_inserting (num IN INTEGER)
IS
   TYPE NumTab IS TABLE OF parts.partnum%TYPE INDEX BY BINARY_INTEGER;
   TYPE NameTab IS TABLE OF parts.partname%TYPE INDEX BY BINARY_INTEGER;
   pnums NumTab;
   pnames NameTab;
BEGIN
   FOR indx IN 1..num LOOP
      pnums(indx) := indx;
      pnames(indx) := 'Part ' || TO_CHAR(indx);
   END LOOP;
   
   sf_timer.start_timer;
   FOR indx IN 1..num LOOP
      INSERT INTO parts VALUES (pnums(indx), pnames(indx));
   END LOOP;
   sf_timer.show_elapsed_time ('FOR loop '|| num);
   
   ROLLBACK;
   
   sf_timer.start_timer;
   FORALL indx IN 1..num
      INSERT INTO parts VALUES (pnums(indx), pnames(indx));
   
   p.l ('SQL%ROWCOUNT = ' || SQL%ROWCOUNT);
   sf_timer.show_elapsed_time ('FORALL '|| num);
   
   ROLLBACK;
END;
/
BEGIN
   compare_inserting (1000);
   compare_inserting (10000);
END;
/   

CREATE OR REPLACE PROCEDURE compare_fetching (num IN INTEGER)
IS
   TYPE NumTab IS TABLE OF parts.partnum%TYPE INDEX BY BINARY_INTEGER;
   TYPE NameTab IS TABLE OF parts.partname%TYPE INDEX BY BINARY_INTEGER;
   pnums NumTab;
   pnames NameTab;
BEGIN
   EXECUTE IMMEDIATE 'TRUNCATE TABLE parts';
   
   /* Load up the table. */
   FOR indx IN 1..num
   LOOP
      INSERT INTO parts VALUES (indx, 'Part ' || TO_CHAR(indx));
   END LOOP;
   
   COMMIT;
   
   DBMS_SESSION.FREE_UNUSED_USER_MEMORY;
   
   /* Fetch the data row by row */
   sf_timer.start_timer;
   FOR rec IN (SELECT * FROM parts)
   LOOP
      pnums(SQL%ROWCOUNT)  := rec.partnum;
      pnames(SQL%ROWCOUNT) := rec.partname;
   END LOOP;
   sf_timer.show_elapsed_time ('Single row fetch '|| num);

   /* Clean up the in-memory data structures. */   
   pnums.DELETE;
   pnames.DELETE;
   DBMS_SESSION.FREE_UNUSED_USER_MEMORY;
   
   /* Fetch the data in bulk */
   sf_timer.start_timer;
   SELECT * BULK COLLECT INTO pnums, pnames FROM parts;
   p.l ('SQL%ROWCOUNT = ' || SQL%ROWCOUNT);   
   sf_timer.show_elapsed_time ('BULK COLLECT '|| num);
END;
/
BEGIN
   compare_fetching (1000);
   compare_fetching (10000);
   -- compare_fetching (100000);
   -- compare_fetching (200000);
   --compare_fetching (1000000);
END;
/   

/* Some results...

Procedure created.

.FOR loop 1000 Elapsed: .21 seconds.
.FORALL 1000 Elapsed: .01 seconds.
.FOR loop 10000 Elapsed: 5.68 seconds.
.FORALL 10000 Elapsed: .15 seconds.

PL/SQL procedure successfully completed.


Procedure created.

Input truncated to 4 characters
.Single row fetch 1000 Elapsed: .06 seconds.
.BULK COLLECT 1000 Elapsed: .01 seconds.
.Single row fetch 10000 Elapsed: .59 seconds.
.BULK COLLECT 10000 Elapsed: .16 seconds.

*/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
