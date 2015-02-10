
CREATE TABLE pipelined_vs_table_tests
( function_type   VARCHAR2(30)
, collection_size INTEGER
, pga_memory_used INTEGER
, elapsed_secs    NUMBER
);

CREATE TYPE varchar2_ntt AS TABLE OF VARCHAR2(4000);
/

CREATE FUNCTION mem RETURN PLS_INTEGER IS
   v_mem PLS_INTEGER;
BEGIN
   SELECT value INTO v_mem
   FROM   v$mystat
   WHERE  statistic# = 25;
   RETURN v_mem;
END mem;
/

CREATE FUNCTION pipelined_function ( n IN PLS_INTEGER ) 
   RETURN varchar2_ntt PIPELINED AS
   v_mem PLS_INTEGER := mem();
BEGIN
   FOR i IN 1 .. n LOOP
      PIPE ROW (RPAD('x',100,'x'));
   END LOOP;
   DBMS_APPLICATION_INFO.SET_ACTION(mem()-v_mem);
   RETURN;
END;
/

CREATE FUNCTION table_function ( n IN PLS_INTEGER ) 
   RETURN varchar2_ntt AS
   v_rows varchar2_ntt := varchar2_ntt();
   v_mem  PLS_INTEGER := mem();
BEGIN
   FOR i IN 1 .. n LOOP
      v_rows.EXTEND;
      v_rows(v_rows.LAST) := RPAD('x',100,'x');
   END LOOP;
   DBMS_APPLICATION_INFO.SET_ACTION(mem()-v_mem);
   RETURN v_rows;
END;
/

