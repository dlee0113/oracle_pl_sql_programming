
set echo on
col object_instance format a75
col record_type format a11
col cust_rec format a30
col addr_rec format a30
col first_name format a10
col last_name format a10
col birth_date format a10
col street_address format a25
col postal_code format a11

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';

SELECT *
FROM   TABLE(
          customer_pkg.customer_transform_multi(
             CURSOR( SELECT * FROM customer_staging ) ) ) nt
WHERE  ROWNUM <= 5;

SELECT VALUE(nt) AS object_instance
FROM   TABLE(
          customer_pkg.customer_transform_multi(
             CURSOR( SELECT * FROM customer_staging ) ) ) nt
WHERE  ROWNUM <= 5;

SELECT nt.OBJECT_VALUE AS object_instance
FROM   TABLE(
          customer_pkg.customer_transform_multi(
             CURSOR( SELECT * FROM customer_staging ) ) ) nt
WHERE  ROWNUM <= 5;

SELECT CASE
          WHEN VALUE(nt) IS OF TYPE (customer_detail_ot)
          THEN 'C'
          ELSE 'A'
       END AS record_type
FROM   TABLE(
          customer_pkg.customer_transform_multi(
             CURSOR( SELECT * FROM customer_staging ) ) ) nt
WHERE  ROWNUM <= 5;

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
WHERE  ROWNUM <= 5;

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
      ) ilv
WHERE  ROWNUM <= 5;

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

set echo off

