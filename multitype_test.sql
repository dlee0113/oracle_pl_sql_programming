
--
-- Note: Uses a modified version of Tom Kyte's runstats_pkg available at www.oracle-developer.net/utilities.php
--

set timing on
set autotrace traceonly statistics

SELECT *
FROM   TABLE(
          customer_pkg.customer_transform_denorm(
             CURSOR( SELECT * FROM customer_staging ) ) ) nt;


SELECT ilv.record_type
,      NVL(ilv.cust_rec.customer_id,
           ilv.addr_rec.customer_id) AS customer_id
,      ilv.cust_rec.first_name       AS first_name
,      ilv.cust_rec.last_name        AS last_name
,      ilv.cust_rec.birth_date       AS birth_date
,      ilv.addr_rec.address_id       AS address_id
,      ilv.addr_rec.primary          AS primary
,      ilv.addr_rec.street_address   AS street_address
,      ilv.addr_rec.postal_code      AS postal_code
FROM  (
       SELECT CASE
                 WHEN VALUE(nt) IS OF TYPE (customer_detail_ot)
                 THEN 'C'
                 ELSE 'A'
              END                                    AS record_type
       ,      TREAT(VALUE(nt) AS customer_detail_ot) AS cust_rec
       ,      TREAT(VALUE(nt) AS address_detail_ot)  AS addr_rec
       FROM   TABLE(
                 customer_pkg.customer_transform_multi(
                    CURSOR( SELECT * FROM customer_staging ) ) ) nt
      ) ilv;

set autotrace off

TRUNCATE TABLE customers;
TRUNCATE TABLE addresses;
set echo on
exec runstats_pkg.rs_start;
exec customer_pkg.load_customers_denorm;
exec runstats_pkg.rs_pause;
TRUNCATE TABLE customers;
TRUNCATE TABLE addresses;
exec runstats_pkg.rs_resume;
exec customer_pkg.load_customers_multi;
exec runstats_pkg.rs_stop(1000);
set echo off


