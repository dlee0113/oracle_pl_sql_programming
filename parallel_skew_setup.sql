
-- impact of parallel options on skew

CREATE TABLE parallel_skew_test
( parallel_option VARCHAR2(20)
, session_number  NUMBER
, record_count    NUMBER
);

CREATE PACKAGE stocks_skew_pkg AS

   TYPE source_rct IS REF CURSOR RETURN tickertable%ROWTYPE;

   FUNCTION pipe_stocks_any( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY ANY);

   FUNCTION pipe_stocks_range_high( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY RANGE(ticker));

   FUNCTION pipe_stocks_hash_high( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY HASH(ticker));

   FUNCTION pipe_stocks_range_low( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY RANGE(price_date));

   FUNCTION pipe_stocks_hash_low( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY HASH(price_date));

END stocks_skew_pkg;
/

CREATE PACKAGE BODY stocks_skew_pkg AS

   TYPE source_aat IS TABLE OF tickertable%ROWTYPE
      INDEX BY PLS_INTEGER;

   FUNCTION pipe_stocks_any( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY ANY) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  SYS_CONTEXT('userenv','sid'), aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_any;

   FUNCTION pipe_stocks_range_high( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY RANGE(ticker)) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  SYS_CONTEXT('userenv','sid'), aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_range_high;

   FUNCTION pipe_stocks_hash_high( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY HASH(ticker)) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  SYS_CONTEXT('userenv','sid'), aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_hash_high;

   FUNCTION pipe_stocks_range_low( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY RANGE(price_date)) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  SYS_CONTEXT('userenv','sid'), aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_range_low;

   FUNCTION pipe_stocks_hash_low( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY HASH(price_date)) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  SYS_CONTEXT('userenv','sid'), aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_hash_low;

END stocks_skew_pkg;
/



