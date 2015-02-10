@@plvtmr.pkg
@@tabcount81.sf
@@showtabcount.sp
SET SERVEROUTPUT ON

DROP TYPE TickerType FORCE;
DROP TYPE TickerTypeSet FORCE;
DROP TABLE StockTable;
DROP TABLE TickerTable;

CREATE TABLE StockTable (
  ticker VARCHAR2(10),
  open_price NUMBER,
  close_price NUMBER
);

BEGIN
   -- Populate the table.
   INSERT INTO stocktable
        VALUES ('ORCL', 15, 16);

   INSERT INTO stocktable
        VALUES ('QSFT', 24, 29);

   INSERT INTO stocktable
        VALUES ('MSFT', 62, 60);

   FOR indx IN 1 .. 10000
   LOOP
      -- Might as well be optimistic!
      INSERT INTO stocktable
           VALUES (   'STK'
                   || indx, indx,   indx
                                  + 15);
   END LOOP;

   COMMIT;
END;
/
CREATE TYPE TickerType AS OBJECT 
(
  ticker VARCHAR2(10),
  PriceType VARCHAR2(1),
  price NUMBER
);
/

CREATE TYPE TickerTypeSet AS TABLE OF TickerType;
/

CREATE TABLE TickerTable  
(
  ticker VARCHAR2(10),
  PriceType VARCHAR2(1),
  price NUMBER
);
/

CREATE OR REPLACE PACKAGE refcur_pkg IS
  TYPE refcur_t IS REF CURSOR RETURN StockTable%ROWTYPE;
END refcur_pkg;
/

CREATE OR REPLACE FUNCTION StockPivot (
    p refcur_pkg.refcur_t) RETURN TickerTypeSet
PIPELINED  
IS
  out_rec TickerType := TickerType(NULL,NULL,NULL);
  in_rec p%ROWTYPE;
BEGIN
  LOOP
    FETCH p INTO in_rec; 
    EXIT WHEN p%NOTFOUND;
    -- first row
    out_rec.ticker := in_rec.Ticker;
    out_rec.PriceType := 'O';
    out_rec.price := in_rec.Open_Price;
    PIPE ROW(out_rec);
    -- second row
    out_rec.PriceType := 'C';   
    out_rec.Price := in_rec.Close_Price;
    PIPE ROW(out_rec);
  END LOOP;
  CLOSE p;
  RETURN ;
END;
/

/* Now do it without pipelining */

CREATE OR REPLACE FUNCTION StockPivot_nopl (p refcur_pkg.refcur_t) 
   RETURN TickerTypeSet  
IS
  out_rec TickerType := TickerType(NULL,NULL,NULL);
  in_rec p%ROWTYPE;
  retval TickerTypeSet := TickerTypeSet();
BEGIN
  retval.DELETE;
  LOOP
    FETCH p INTO in_rec; 
    EXIT WHEN p%NOTFOUND;
    out_rec.ticker := in_rec.Ticker;
	
    out_rec.PriceType := 'O';
    out_rec.price := in_rec.Open_Price;
	retval.EXTEND;
	retval(retval.LAST) := out_rec;

    out_rec.PriceType := 'C';   
    out_rec.Price := in_rec.Close_Price;
	retval.EXTEND;
	retval(retval.LAST) := out_rec;

  END LOOP;
  CLOSE p;
  RETURN retval;
END;
/

DECLARE
   -- Compare performance of pipelining in SQL to multiple steps
   curvar     sys_refcursor;
   mystock    tickertypeset := tickertypeset ();
   indx       PLS_INTEGER;

   PROCEDURE init
   IS
   BEGIN
      DELETE FROM tickertable;

      COMMIT;
   END;
BEGIN
   init;
   sf_timer.start_timer;
   INSERT INTO tickertable 
      SELECT * 
        FROM TABLE (StockPivot (CURSOR(SELECT * FROM StockTable)));
   sf_timer.show_elapsed_time ('All SQL with Pipelining function');
   showtabcount ('tickertable');
      
   init;
   sf_timer.start_timer;
   INSERT INTO tickertable 
      SELECT * 
        FROM TABLE (StockPivot_nopl (CURSOR(SELECT * FROM StockTable)));
   sf_timer.show_elapsed_time ('All SQL with non-pipelining function');
   showtabcount ('tickertable');
   
   init;
   
   sf_timer.start_timer;
   OPEN curvar FOR
      SELECT *
        FROM stocktable;
   mystock := stockpivot_nopl (curvar);
   indx := mystock.FIRST;

   LOOP
      EXIT WHEN indx IS NULL;

      INSERT INTO tickertable
                  (ticker, pricetype,
                   price)
           VALUES (mystock (indx).ticker, mystock (indx).pricetype,
                   mystock (indx).price);

      indx := mystock.NEXT (indx);
   END LOOP;

   sf_timer.show_elapsed_time ('Intermediate collection');
   showtabcount ('tickertable');
   
   init;
   sf_timer.start_timer;

   FOR rec IN  (SELECT *
                  FROM stocktable)
   LOOP
      INSERT INTO tickertable
                  (ticker, pricetype, price)
           VALUES (rec.ticker, 'O', rec.open_price);

      INSERT INTO tickertable
                  (ticker, pricetype, price)
           VALUES (rec.ticker, 'C', rec.close_price);
   END LOOP;

   sf_timer.show_elapsed_time ('Cursor FOR Loop and two inserts');
   showtabcount ('tickertable');
   init;
END;
/

DECLARE
   -- Compare performance of pipelining retrieving just first 10 rows
   curvar     sys_refcursor;
   mystock    tickertypeset := tickertypeset ();
   indx       PLS_INTEGER;
   
   PROCEDURE init
   IS
   BEGIN
      DELETE FROM tickertable;

      COMMIT;
   END;
BEGIN
   init;
   sf_timer.start_timer;
   INSERT INTO tickertable 
      SELECT * 
        FROM TABLE (StockPivot (CURSOR(SELECT * FROM StockTable)))
		WHERE ROWNUM < 10;
   sf_timer.show_elapsed_time('Pipelining first 10 rows');
   showtabcount ('tickertable');
      
   init;
   sf_timer.start_timer;
   INSERT INTO tickertable 
      SELECT * 
        FROM TABLE (StockPivot_nopl (CURSOR(SELECT * FROM StockTable)))
		WHERE ROWNUM < 10;
   sf_timer.show_elapsed_time('No pipelining first 10 rows');
   showtabcount ('tickertable');
END;
/

/*
.Pipelining first 10 rows Elapsed: .41 seconds.
Count of SCOTT.tickertable WHERE * no filter * = 9
.No pipelining first 10 rows Elapsed: 2.07 seconds.
Count of SCOTT.tickertable WHERE * no filter * = 9
*/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
