
-- impact of parallel partitioning and streaming options on performance

CREATE TABLE parallel_options_test
( parallel_option VARCHAR2(30)
, start_time      INTEGER
, end_time        INTEGER );

CREATE PACKAGE stocks_pkg AS

   TYPE source_rct IS REF CURSOR RETURN tickertable%ROWTYPE;

   FUNCTION pipe_stocks_any( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY ANY);

   FUNCTION pipe_stocks_range( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY RANGE(ticker));

   FUNCTION pipe_stocks_hash( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY HASH(ticker));

   FUNCTION pipe_stocks_any_ordered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY ANY)
      ORDER p_cursor BY (ticker, price_type DESC);

   FUNCTION pipe_stocks_range_ordered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY RANGE(ticker))
      ORDER p_cursor BY (ticker, price_type DESC);

   FUNCTION pipe_stocks_hash_ordered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY HASH(ticker))
      ORDER p_cursor BY (ticker, price_type DESC);

   FUNCTION pipe_stocks_any_clustered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY ANY)
      CLUSTER p_cursor BY (ticker, price_type DESC);

   FUNCTION pipe_stocks_range_clustered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY RANGE(ticker))
      CLUSTER p_cursor BY (ticker, price_type DESC);

   FUNCTION pipe_stocks_hash_clustered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY HASH(ticker))
      CLUSTER p_cursor BY (ticker, price_type DESC);

END stocks_pkg;
/

CREATE OR REPLACE PACKAGE BODY stocks_pkg AS

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
                  aa_source(i).ticker, aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_any;

   FUNCTION pipe_stocks_range( p_cursor IN source_rct )
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
                  aa_source(i).ticker, aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_range;

   FUNCTION pipe_stocks_hash( p_cursor IN source_rct )
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
                  aa_source(i).ticker, aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_hash;

   FUNCTION pipe_stocks_any_ordered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY ANY)
      ORDER p_cursor BY (ticker, price_type DESC) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  aa_source(i).ticker, aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_any_ordered;

   FUNCTION pipe_stocks_range_ordered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY RANGE(ticker))
      ORDER p_cursor BY (ticker, price_type DESC) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  aa_source(i).ticker, aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_range_ordered;

   FUNCTION pipe_stocks_hash_ordered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY HASH(ticker))
      ORDER p_cursor BY (ticker, price_type DESC) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  aa_source(i).ticker, aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_hash_ordered;

   FUNCTION pipe_stocks_any_clustered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY ANY)
      CLUSTER p_cursor BY (ticker, price_type DESC) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  aa_source(i).ticker, aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_any_clustered;

   FUNCTION pipe_stocks_range_clustered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY RANGE(ticker))
      CLUSTER p_cursor BY (ticker, price_type DESC) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  aa_source(i).ticker, aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_range_clustered;

   FUNCTION pipe_stocks_hash_clustered( p_cursor IN source_rct )
      RETURN ticker_ntt
      PIPELINED
      PARALLEL_ENABLE (PARTITION p_cursor BY HASH(ticker))
      CLUSTER p_cursor BY (ticker, price_type DESC) IS
      aa_source source_aat;
   BEGIN
      LOOP
         FETCH p_cursor BULK COLLECT INTO aa_source LIMIT 100;
         EXIT WHEN aa_source.COUNT = 0;
         FOR i IN 1 .. aa_source.COUNT LOOP
            PIPE ROW(
               ticker_ot(
                  aa_source(i).ticker, aa_source(i).price_type,
                  aa_source(i).price, aa_source(i).price_date));
         END LOOP;
      END LOOP;
      CLOSE p_cursor;
      RETURN;
   END pipe_stocks_hash_clustered;

END stocks_pkg;
/



