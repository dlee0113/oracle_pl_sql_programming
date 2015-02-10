CREATE TYPE tickertypeset AS TABLE OF tickertype
/

CREATE OR REPLACE FUNCTION stockpivot_nopl (dataset refcur_pkg.refcur_t)
   RETURN tickertypeset
IS
   out_obj     tickertype    := tickertype (NULL, NULL, NULL, NULL);

   --
   TYPE dataset_tt IS TABLE OF stocktable%ROWTYPE
      INDEX BY PLS_INTEGER;

   l_dataset   dataset_tt;
   retval      tickertypeset := tickertypeset ();
   l_row       PLS_INTEGER;
BEGIN
   FETCH dataset
   BULK COLLECT INTO l_dataset;
   CLOSE dataset;
   
   /* Melbourne Jan 2008 - extend once based on count */
   retval.EXTEND (l_dataset.COUNT * 2);

   l_row := l_dataset.FIRST;

   WHILE (l_row IS NOT NULL)
   LOOP
      out_obj.ticker := l_dataset (l_row).ticker;
      out_obj.pricetype := 'O';
      out_obj.price := l_dataset (l_row).open_price;
      out_obj.pricedate := l_dataset (l_row).trade_date;
      --retval.EXTEND;
      retval (l_row * 2 - 1) := out_obj;
      --
      out_obj.pricetype := 'C';
      out_obj.price := l_dataset (l_row).close_price;
      --retval.EXTEND;
      retval (l_row * 2) := out_obj;
      --
      l_row := l_dataset.NEXT (l_row);
   END LOOP;

   RETURN retval;
END;
/

SHO ERR

/* Pivot data with pipelining */

CREATE OR REPLACE FUNCTION stockpivot_pl (dataset refcur_pkg.refcur_t)
   RETURN tickertypeset PIPELINED
IS
   l_row_as_object   tickertype  := tickertype (NULL, NULL, NULL, NULL);

   TYPE dataset_tt IS TABLE OF dataset%ROWTYPE
      INDEX BY PLS_INTEGER;

   l_dataset         dataset_tt;
   l_row             PLS_INTEGER;
BEGIN
   FETCH dataset
   BULK COLLECT INTO l_dataset;
   CLOSE dataset;

   l_row := l_dataset.FIRST;

   WHILE (l_row IS NOT NULL)
   LOOP
      -- first row
      l_row_as_object.ticker := l_dataset (l_row).ticker;
      l_row_as_object.pricetype := 'O';
      l_row_as_object.price := l_dataset (l_row).open_price;
      l_row_as_object.pricedate := l_dataset (l_row).trade_date;
      --
      PIPE ROW (l_row_as_object);
      -- second row
      l_row_as_object.pricetype := 'C';
      l_row_as_object.price := l_dataset (l_row).close_price;
      --
      PIPE ROW (l_row_as_object);
      l_row := l_dataset.NEXT (l_row);
   END LOOP;

   RETURN;
END;
/

CREATE OR REPLACE FUNCTION stockpivot_plnr (dataset refcur_pkg.refcur_t)
   RETURN tickertypeset PIPELINED
IS
   l_row_as_object   tickertype  := tickertype (NULL, NULL, NULL, NULL);

   TYPE dataset_tt IS TABLE OF dataset%ROWTYPE
      INDEX BY PLS_INTEGER;

   l_dataset         dataset_tt;
   l_row             PLS_INTEGER;
BEGIN
   FETCH dataset
   BULK COLLECT INTO l_dataset;
   CLOSE dataset;

   l_row := l_dataset.FIRST;

   WHILE (l_row IS NOT NULL)
   LOOP
      -- first row
      l_row_as_object.ticker := l_dataset (l_row).ticker;
      l_row_as_object.pricetype := 'O';
      l_row_as_object.price := l_dataset (l_row).open_price;
      l_row_as_object.pricedate := l_dataset (l_row).trade_date;
      --
      PIPE ROW (l_row_as_object);
      -- second row
      l_row_as_object.pricetype := 'C';
      l_row_as_object.price := l_dataset (l_row).close_price;
      --
      PIPE ROW (l_row_as_object);
      l_row := l_dataset.NEXT (l_row);
   END LOOP;
END;
/

REM Compare performance using "ROWNUM <" to demonstrate the reality
REM of row piping.

DECLARE
   PROCEDURE init
   IS
   BEGIN
      DELETE FROM tickertable;

      COMMIT;
      DBMS_SESSION.free_unused_user_memory;
      sf_timer.start_timer;
   END;

   PROCEDURE first_ten_rows_pl
   IS
   BEGIN
      init;

      INSERT INTO tickertable
         SELECT *
           FROM TABLE (stockpivot_pl (CURSOR (SELECT *
                                                FROM stocktable)))
          WHERE ROWNUM < 10;

      sf_timer.show_elapsed_time ('Pipelining first 9 rows');
   END;

   PROCEDURE first_ten_rows_nopl
   IS
   BEGIN
      init;

      INSERT INTO tickertable
         SELECT *
           FROM TABLE (stockpivot_nopl (CURSOR (SELECT *
                                                  FROM stocktable)))
          WHERE ROWNUM < 10;

      sf_timer.show_elapsed_time ('NO pipelining first 9 rows');
   -- showtabcount ('tickertable');
   END;

   PROCEDURE first_ten_rows_pl_with_oby
   IS
   BEGIN
      init;

      INSERT INTO tickertable
         SELECT   *
             FROM TABLE (stockpivot_pl (CURSOR (SELECT *
                                                  FROM stocktable)))
            WHERE ROWNUM < 10
         ORDER BY ticker, pricedate;

      sf_timer.show_elapsed_time ('Pipelining first with ORDER BY 9 rows');
   END;
BEGIN
   -- Compare "first 9 rows" performance
   first_ten_rows_pl;
   first_ten_rows_nopl;
   /*
   Order by and group by do NOT affect pipelined performance.
   */
   first_ten_rows_pl_with_oby;
/*
Some results:

On Oracle9i...

Pipelining first 9 rows Elapsed: .1 seconds.
NO pipelining first 9 rows Elapsed: 10.13 seconds.

On Oracle10g...

Pipelining first 9 rows Elapsed: .1 seconds.
NO pipelining first 9 rows Elapsed: 3.9 seconds.

Pipelining first 9 rows Elapsed: 0 seconds.
NO pipelining first 9 rows Elapsed: 3.58 seconds.

Pipelining first 9 rows Elapsed: 0 seconds.
NO pipelining first 9 rows Elapsed: 3.55 seconds.

And with bulk collect....

Pipelining first 9 rows Elapsed: .02 seconds.
NO pipelining first 9 rows Elapsed: .17 seconds.
*/
END;
/

/* 
Does a pipelined function use less PGA?

Yes, indeed!

Pointed out in Sydney January 2008 training.
*/

DECLARE
   PROCEDURE init (context_in IN VARCHAR2)
   IS
   BEGIN
      DELETE FROM tickertable;

      COMMIT;
      DBMS_SESSION.free_unused_user_memory;
      DBMS_OUTPUT.put_line (context_in || ' Memory Before:');
      my_session.MEMORY;
      sf_timer.start_timer;
   END;

   PROCEDURE pl
   IS
   BEGIN
      init ('Pipelining');

      INSERT INTO tickertable
         SELECT *
           FROM TABLE (stockpivot_pl (CURSOR (SELECT *
                                                FROM stocktable)));

      sf_timer.show_elapsed_time ('Pipelining');
      my_session.MEMORY;
      DBMS_OUTPUT.put_line ('');
   END;

   PROCEDURE nopl
   IS
   BEGIN
      init ('NO pipelining');

      INSERT INTO tickertable
         SELECT *
           FROM TABLE (stockpivot_nopl (CURSOR (SELECT *
                                                  FROM stocktable)));

      sf_timer.show_elapsed_time ('NO pipelining');
      my_session.MEMORY;
   END;
BEGIN
   pl;
   nopl;
/*

Pipelining Memory Before:
session UGA: 1282300 (delta: 1282300)
session PGA: 1629780 (delta: 1629780)
Pipelining Elapsed: 2.31 seconds.
session UGA: 1347764 (delta: 65464)
session PGA: 1760852 (delta: 131072)

NO pipelining Memory Before:
session UGA: 1347764 (delta: 0)
session PGA: 1760852 (delta: 0)
NO pipelining Elapsed: 1.64 seconds.
session UGA: 1413228 (delta: 65464)
session PGA: 67362388 (delta: 65601536)

*/
END;
/