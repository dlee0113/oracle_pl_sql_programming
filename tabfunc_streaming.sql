DROP  TYPE tickertype FORCE;
DROP  TYPE tickertypeset FORCE;
DROP  TABLE stocktable;
DROP  TABLE tickertable;

CREATE TABLE  stocktable (
  ticker VARCHAR2(20),
  trade_date DATE,
  open_price NUMBER,
  close_price NUMBER
)
/

BEGIN
   -- Populate the table.
   INSERT INTO stocktable
        VALUES ('ORCL', SYSDATE, 15.2, 15.7);

   INSERT INTO stocktable
        VALUES ('QSFT', SYSDATE, 13.1, 13.5);

   INSERT INTO stocktable
        VALUES ('MSFT', SYSDATE, 27, 27.04);

   FOR indx IN 1 .. 100000
   LOOP
      -- Might as well be optimistic!
      INSERT INTO stocktable
           VALUES ('STK' || indx, SYSDATE, indx, indx + 15);
   END LOOP;

   COMMIT;
END;
/

CREATE TABLE tickertable
(
  ticker VARCHAR2(20),
  pricedate DATE,
  pricetype VARCHAR2(1),
  price NUMBER
)
/
/* 
   Note: Must use a nested table or varray of objects
   for the return type of a pipelined function
*/

CREATE TYPE tickertype AS OBJECT (
   ticker      VARCHAR2 (20)
 , pricedate   DATE
 , pricetype   VARCHAR2 (1)
 , price       NUMBER
);
/

/*
Cannot use %ROWTYPE collection in package:

PLS-00642: local collection types not allowed in SQL statements

Even in 10g!
*/

CREATE TYPE tickertypeset AS TABLE OF tickertype;
/

CREATE OR REPLACE PACKAGE refcur_pkg
IS
   TYPE refcur_t IS REF CURSOR
      RETURN stocktable%ROWTYPE;
END refcur_pkg;
/

CREATE OR REPLACE FUNCTION stockpivot (dataset refcur_pkg.refcur_t)
   RETURN tickertypeset
IS
   out_obj     tickertype    := tickertype (NULL, NULL, NULL, NULL);
   
   TYPE dataset_tt IS TABLE OF stocktable%ROWTYPE
      INDEX BY PLS_INTEGER;
   l_dataset   dataset_tt;
   
   /* The nested table that will be returned. */
   retval      tickertypeset := tickertypeset ();
BEGIN
   LOOP
      /* Move N rows from cursor variable (SELECT) to local collection. */
      FETCH dataset
      BULK COLLECT INTO l_dataset LIMIT 100;

      EXIT WHEN l_dataset.COUNT = 0;
      
      /* Iterate through each row.... */
      FOR l_row IN 1 .. l_dataset.COUNT
      LOOP
         /* START application specific logic.
            This will vary depending on your transformation. */
            
         /* Create open price object type and add to collection. */
         out_obj.ticker := l_dataset (l_row).ticker;
         out_obj.pricetype := 'O';
         out_obj.price := l_dataset (l_row).open_price;
         out_obj.pricedate := l_dataset (l_row).trade_date;
         retval.EXTEND;
         retval (retval.LAST) := out_obj;
         
         /* Create close price object type and add to collection. */
         out_obj.pricetype := 'C';
         out_obj.price := l_dataset (l_row).close_price;
         out_obj.pricedate := l_dataset (l_row).trade_date;
         retval.EXTEND;
         retval (retval.LAST) := out_obj;
      END LOOP;
   END LOOP;

   CLOSE dataset;

   RETURN retval;
END;
/

BEGIN
   INSERT INTO tickertable
      SELECT *
        FROM TABLE (stockpivot (CURSOR (SELECT *
                                          FROM stocktable)));
END;
/

/* Example of multiple transformations */

DECLARE
   CV   sys_refcursor;
BEGIN
   OPEN CV FOR
      SELECT *
        FROM TABLE
                (transformation_2
                      (CURSOR (SELECT *
                                 FROM TABLE
                                          (stockpivot (CURSOR (SELECT *
                                                                 FROM stocktable)
                                                      )
                                          )
                              )
                      )
                );
END;
/