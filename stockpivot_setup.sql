

CREATE OR REPLACE DIRECTORY dir AS 'd:\oracle\dir';

DECLARE
   f UTL_FILE.FILE_TYPE := UTL_FILE.FOPEN('DIR', 'stocktable.dat', 'w');
BEGIN
   FOR r IN (WITH opening_prices AS (
                     SELECT 'STK' || TO_CHAR(ROWNUM) AS ticker
                     ,      ROUND(DBMS_RANDOM.VALUE(0, 2000), 4) AS open_price
                     ,      SYSDATE-ABS(DBMS_RANDOM.VALUE(0,30)) AS trade_date
                     FROM   dual
                     CONNECT BY ROWNUM <= &num_rows
                     )
             SELECT ticker 
             ,      open_price 
             ,      ROUND(open_price * ABS(DBMS_RANDOM.VALUE(0.1,2)),4) AS close_price
             ,      trade_date
             FROM   opening_prices)
   LOOP
      UTL_FILE.PUT_LINE(f, r.ticker || ',' || r.open_price || ',' || 
                           r.close_price || ',' || TO_CHAR(r.trade_date, 'DD/MM/YYYY'));
   END LOOP;
   UTL_FILE.FCLOSE(f);
END;
/

CREATE TABLE stocktable
( ticker      VARCHAR2(10)
, open_price  NUMBER
, close_price NUMBER 
, trade_date  DATE
)
ORGANIZATION EXTERNAL
(
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY dir
  ACCESS PARAMETERS
  (
     RECORDS DELIMITED by NEWLINE
     NOBADFILE
     NOLOGFILE
     NODISCARDFILE
     FIELDS TERMINATED BY ','
     ( ticker
     , open_price
     , close_price
     , trade_date CHAR(20) DATE_FORMAT DATE MASK "DD/MM/YYYY"
     )
  )
  LOCATION ('stocktable.dat')
)
REJECT LIMIT UNLIMITED;

exec DBMS_STATS.GATHER_TABLE_STATS(USER, 'STOCKTABLE', estimate_percent=>NULL);

CREATE TABLE tickertable
( ticker      VARCHAR2(10)
, price_type  VARCHAR2(1)
, price       NUMBER 
, price_date  DATE
);

CREATE TYPE stockpivot_ot AS OBJECT
( ticker      VARCHAR2(10)
, price_type  VARCHAR2(1)
, price       NUMBER 
, price_date  DATE
);
/

CREATE TYPE stockpivot_ntt AS TABLE OF stockpivot_ot;
/

CREATE PACKAGE stockpivot_pkg AS

   c_default_limit CONSTANT PLS_INTEGER := 100;

   TYPE stocktable_rct IS REF CURSOR
      RETURN stocktable%ROWTYPE;

   TYPE stocktable_aat IS TABLE OF stocktable%ROWTYPE
      INDEX BY PLS_INTEGER;

   SUBTYPE stocktable_rt IS stocktable%ROWTYPE;

   TYPE tickertable_aat IS TABLE OF tickertable%ROWTYPE
      INDEX BY PLS_INTEGER;

   SUBTYPE tickertable_rt IS tickertable%ROWTYPE;

   PROCEDURE load_stocks_legacy;

   PROCEDURE load_stocks_forall(
             p_limit_size  IN PLS_INTEGER DEFAULT stockpivot_pkg.c_default_limit
             );

   FUNCTION pipe_stocks( 
            p_source_data IN stockpivot_pkg.stocktable_rct 
            ) RETURN stockpivot_ntt PIPELINED;

   FUNCTION pipe_stocks_array( 
            p_source_data IN stockpivot_pkg.stocktable_rct,
            p_limit_size  IN PLS_INTEGER DEFAULT stockpivot_pkg.c_default_limit
            ) RETURN stockpivot_ntt PIPELINED;

   FUNCTION pipe_stocks_parallel( 
            p_source_data IN stockpivot_pkg.stocktable_rct,
            p_limit_size  IN PLS_INTEGER DEFAULT stockpivot_pkg.c_default_limit
            ) RETURN stockpivot_ntt 
              PIPELINED
              PARALLEL_ENABLE (PARTITION p_source_data BY ANY);

   PROCEDURE load_stocks;
   PROCEDURE load_stocks_array;
   PROCEDURE load_stocks_parallel;

END stockpivot_pkg;
/

CREATE PACKAGE BODY stockpivot_pkg AS

   -----------------------------------------------------------------------
   PROCEDURE load_stocks_legacy IS

      CURSOR c_source_data IS
         SELECT ticker, open_price, close_price, trade_date
         FROM   stocktable;

      r_source_data stockpivot_pkg.stocktable_rt;
      r_target_data stockpivot_pkg.tickertable_rt;

   BEGIN
      OPEN c_source_data;
      LOOP
         FETCH c_source_data INTO r_source_data;
         EXIT WHEN c_source_data%NOTFOUND;

         /* Opening price... */
         r_target_data.ticker      := r_source_data.ticker;
         r_target_data.price_type  := 'O';
         r_target_data.price       := r_source_data.open_price;
         r_target_data.price_date  := r_source_data.trade_date;
      
         INSERT INTO tickertable VALUES r_target_data;

         /* Closing price... */
         r_target_data.price_type := 'C';
         r_target_data.price      := r_source_data.close_price;
         
         INSERT INTO tickertable VALUES r_target_data;

      END LOOP;

      DBMS_OUTPUT.PUT_LINE( 
         c_source_data%ROWCOUNT * 2 || ' rows inserted.' );

      CLOSE c_source_data;
   END load_stocks_legacy;

   -----------------------------------------------------------------------
   FUNCTION pipe_stocks( 
            p_source_data IN stockpivot_pkg.stocktable_rct 
            ) RETURN stockpivot_ntt PIPELINED IS

      r_target_data stockpivot_ot := stockpivot_ot(NULL, NULL, NULL, NULL);
      r_source_data stockpivot_pkg.stocktable_rt;

   BEGIN
      LOOP
         FETCH p_source_data INTO r_source_data;
         EXIT WHEN p_source_data%NOTFOUND;

         /* First row... */
         r_target_data.ticker     := r_source_data.ticker;
         r_target_data.price_type := 'O';
         r_target_data.price      := r_source_data.open_price;
         r_target_data.price_date := r_source_data.trade_date;
         PIPE ROW (r_target_data);

         /* Second row... */
         r_target_data.price_type := 'C';
         r_target_data.price      := r_source_data.close_price;
         PIPE ROW (r_target_data);

      END LOOP;
      CLOSE p_source_data;
      RETURN;
   END pipe_stocks;

   -----------------------------------------------------------------------
   FUNCTION pipe_stocks_array( 
            p_source_data IN stockpivot_pkg.stocktable_rct,
            p_limit_size  IN PLS_INTEGER DEFAULT stockpivot_pkg.c_default_limit
            ) RETURN stockpivot_ntt PIPELINED IS

      r_target_data  stockpivot_ot := stockpivot_ot(NULL, NULL, NULL, NULL);
      aa_source_data stockpivot_pkg.stocktable_aat;

   BEGIN
      LOOP
         FETCH p_source_data BULK COLLECT INTO aa_source_data LIMIT p_limit_size;
         EXIT WHEN aa_source_data.COUNT = 0;

         /* Process the batch of (p_limit_size) records... */
         FOR i IN 1 .. aa_source_data.COUNT LOOP
   
            /* First row... */
            r_target_data.ticker     := aa_source_data(i).ticker;
            r_target_data.price_type := 'O';
            r_target_data.price      := aa_source_data(i).open_price;
            r_target_data.price_date := aa_source_data(i).trade_date;
            PIPE ROW (r_target_data);

            /* Second row... */
            r_target_data.price_type := 'C';
            r_target_data.price      := aa_source_data(i).close_price;
            PIPE ROW (r_target_data);

         END LOOP;

      END LOOP;
      CLOSE p_source_data; 
      RETURN;

   END pipe_stocks_array;

   -----------------------------------------------------------------------
   FUNCTION pipe_stocks_parallel( 
            p_source_data IN stockpivot_pkg.stocktable_rct,
            p_limit_size  IN PLS_INTEGER DEFAULT stockpivot_pkg.c_default_limit
            ) RETURN stockpivot_ntt 
              PIPELINED
              PARALLEL_ENABLE (PARTITION p_source_data BY ANY) IS

      r_target_data  stockpivot_ot := stockpivot_ot(NULL, NULL, NULL, NULL);
      aa_source_data stockpivot_pkg.stocktable_aat;

   BEGIN
      LOOP
         FETCH p_source_data BULK COLLECT INTO aa_source_data LIMIT p_limit_size;
         EXIT WHEN aa_source_data.COUNT = 0;

         /* Process the batch of (p_limit_size) records... */
         FOR i IN 1 .. aa_source_data.COUNT LOOP
   
            /* First row... */
            r_target_data.ticker     := aa_source_data(i).ticker;
            r_target_data.price_type := 'O';
            r_target_data.price      := aa_source_data(i).open_price;
            r_target_data.price_date := aa_source_data(i).trade_date;
            PIPE ROW (r_target_data);

            /* Second row... */
            r_target_data.price_type := 'C';
            r_target_data.price      := aa_source_data(i).close_price;
            PIPE ROW (r_target_data);

         END LOOP;

      END LOOP;
      CLOSE p_source_data; 
      RETURN;

   END pipe_stocks_parallel;

   -----------------------------------------------------------------------
   PROCEDURE load_stocks IS
   BEGIN

      INSERT INTO tickertable (ticker, price_type, price, price_date)
      SELECT ticker, price_type, price, price_date
      FROM   TABLE(
                stockpivot_pkg.pipe_stocks(
                   CURSOR(SELECT * FROM stocktable)));

      DBMS_OUTPUT.PUT_LINE( SQL%ROWCOUNT || ' rows inserted.' );

   END load_stocks;

   -----------------------------------------------------------------------
   PROCEDURE load_stocks_array IS
   BEGIN

      INSERT INTO tickertable (ticker, price_type, price, price_date)
      SELECT ticker, price_type, price, price_date
      FROM   TABLE(
                stockpivot_pkg.pipe_stocks_array(
                   CURSOR(SELECT * FROM stocktable)));

      DBMS_OUTPUT.PUT_LINE( SQL%ROWCOUNT || ' rows inserted.' );

   END load_stocks_array;

   -----------------------------------------------------------------------
   PROCEDURE load_stocks_parallel IS
   BEGIN

      EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

      INSERT /*+ PARALLEL(t, 4) */ INTO tickertable t
            (ticker, price_type, price, price_date)
      SELECT ticker, price_type, price, price_date
      FROM   TABLE(
                stockpivot_pkg.pipe_stocks_parallel(
                   CURSOR(SELECT /*+ PARALLEL(s, 4) */ * FROM stocktable s)));

      DBMS_OUTPUT.PUT_LINE( SQL%ROWCOUNT || ' rows inserted.' );

   END load_stocks_parallel;

   -----------------------------------------------------------------------
   PROCEDURE load_stocks_forall(
             p_limit_size  IN PLS_INTEGER DEFAULT stockpivot_pkg.c_default_limit
             ) IS

      CURSOR c_source_data IS
         SELECT ticker, open_price, close_price, trade_date
         FROM   stocktable;

      aa_source_data stockpivot_pkg.stocktable_aat;
      aa_target_data stockpivot_pkg.tickertable_aat;
      v_indx         PLS_INTEGER;
      v_rowcount     PLS_INTEGER := 0;

   BEGIN
      OPEN c_source_data;
      LOOP
         FETCH c_source_data BULK COLLECT INTO aa_source_data LIMIT p_limit_size;
         EXIT WHEN aa_source_data.COUNT = 0;

         aa_target_data.DELETE;

         FOR i IN 1 .. aa_source_data.COUNT LOOP

            /* Opening price... */
            v_indx := aa_target_data.COUNT + 1;
            aa_target_data(v_indx).ticker      := aa_source_data(i).ticker;
            aa_target_data(v_indx).price_type  := 'O';
            aa_target_data(v_indx).price       := aa_source_data(i).open_price;
            aa_target_data(v_indx).price_date  := aa_source_data(i).trade_date;
      
            /* Closing price... */
            v_indx := aa_target_data.COUNT + 1;
            aa_target_data(v_indx).ticker      := aa_source_data(i).ticker;
            aa_target_data(v_indx).price_type  := 'C';
            aa_target_data(v_indx).price       := aa_source_data(i).close_price;
            aa_target_data(v_indx).price_date  := aa_source_data(i).trade_date;
         
         END LOOP;

         FORALL i IN INDICES OF aa_target_data
            INSERT INTO tickertable 
            VALUES aa_target_data(i);

         v_rowcount := v_rowcount + SQL%ROWCOUNT;

      END LOOP;

      DBMS_OUTPUT.PUT_LINE( v_rowcount || ' rows inserted.' );

      CLOSE c_source_data;
   END load_stocks_forall;

END stockpivot_pkg;
/

