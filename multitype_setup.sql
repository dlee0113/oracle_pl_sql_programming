
set echo on

CREATE TABLE customer_staging
AS
   SELECT customer_id
   ,      first_name
   ,      last_name
   ,      MIN(birth_date) OVER 
             (PARTITION BY first_name, last_name) AS birth_date
   ,      address_id
   ,      CASE
             WHEN customer_rn = 1
             THEN 'Y'
             ELSE 'N'
          END AS primary
   ,      street_address
   ,      postal_code
   ,      city
   FROM  (
          SELECT MIN(cust_id) OVER
                    (PARTITION BY cust_first_name, cust_last_name) AS customer_id
          ,      cust_first_name                                   AS first_name
          ,      cust_last_name                                    AS last_name
          ,      SYSDATE - DBMS_RANDOM.VALUE(6570, 23000)          AS birth_date
          ,      ROWNUM + 10000                                    AS address_id
          ,      cust_street_address                               AS street_address
          ,      cust_postal_code                                  AS postal_code
          ,      cust_city                                         AS city
          ,      ROW_NUMBER() OVER 
                    (PARTITION BY cust_first_name, cust_last_name 
                      ORDER BY cust_id)                            AS customer_rn
          FROM   sh.customers
         )
   WHERE customer_rn <= 3;

exec DBMS_STATS.GATHER_TABLE_STATS(USER, 'CUSTOMER_STAGING');

CREATE TABLE customers
( customer_id NUMBER PRIMARY KEY
, first_name  VARCHAR2(20)
, last_name   VARCHAR2(60)
, birth_date  DATE
);

CREATE TABLE addresses
( address_id     NUMBER PRIMARY KEY
, customer_id    NUMBER 
, primary        VARCHAR2(1)
, street_address VARCHAR2(40)
, postal_code    VARCHAR2(10)
);

-- Multi-type example...
CREATE TYPE customer_ot AS OBJECT
( customer_id NUMBER
)
NOT FINAL;
/

CREATE TYPE customer_ntt AS TABLE OF customer_ot;
/

CREATE TYPE customer_detail_ot UNDER customer_ot
( first_name VARCHAR2(20)
, last_name  VARCHAR2(60)
, birth_date DATE
)
FINAL;
/

CREATE TYPE address_detail_ot UNDER customer_ot
( address_id     NUMBER
, primary        VARCHAR2(1)
, street_address VARCHAR2(40)
, postal_code    VARCHAR2(10)
)
FINAL;
/

-- Denormalised record example...
CREATE TYPE customer_address_ot AS OBJECT
( customer_id          NUMBER
, first_name           VARCHAR2(20)
, last_name            VARCHAR2(60)
, birth_date           DATE
, addr1_address_id     NUMBER
, addr1_primary        VARCHAR2(1)
, addr1_street_address VARCHAR2(40)
, addr1_postal_code    VARCHAR2(10)
, addr2_address_id     NUMBER
, addr2_primary        VARCHAR2(1)
, addr2_street_address VARCHAR2(40)
, addr2_postal_code    VARCHAR2(10)
, addr3_address_id     NUMBER
, addr3_primary        VARCHAR2(1)
, addr3_street_address VARCHAR2(40)
, addr3_postal_code    VARCHAR2(10)
, CONSTRUCTOR FUNCTION customer_address_ot 
     RETURN SELF AS RESULT
);
/

CREATE TYPE BODY customer_address_ot AS
   CONSTRUCTOR FUNCTION customer_address_ot 
      RETURN SELF AS RESULT IS
   BEGIN
      RETURN;
   END;
END;
/

CREATE TYPE customer_address_ntt AS TABLE OF customer_address_ot;
/

-- package to transform and load customer data...
CREATE PACKAGE customer_pkg AS

   c_default_limit CONSTANT PLS_INTEGER := 100;

   TYPE customer_staging_rct IS REF CURSOR
      RETURN customer_staging%ROWTYPE;

   FUNCTION customer_transform_multi(
            p_source     IN customer_staging_rct,
            p_limit_size IN PLS_INTEGER DEFAULT customer_pkg.c_default_limit
            )
      RETURN customer_ntt
      PIPELINED 
      PARALLEL_ENABLE (PARTITION p_source BY HASH(customer_id))
      ORDER p_source BY (customer_id, address_id);

   FUNCTION customer_transform_denorm(
            p_source     IN customer_staging_rct,
            p_limit_size IN PLS_INTEGER DEFAULT customer_pkg.c_default_limit
            )
      RETURN customer_address_ntt
      PIPELINED 
      PARALLEL_ENABLE (PARTITION p_source BY HASH(customer_id))
      ORDER p_source BY (customer_id, address_id);

   PROCEDURE load_customers_multi;
   PROCEDURE load_customers_denorm;

END customer_pkg;
/

CREATE PACKAGE BODY customer_pkg AS

   TYPE customer_staging_aat IS TABLE OF customer_staging%ROWTYPE
      INDEX BY PLS_INTEGER;

   ------------------------------------------------------------
   FUNCTION customer_transform_multi( 
            p_source     IN customer_staging_rct,
            p_limit_size IN PLS_INTEGER DEFAULT customer_pkg.c_default_limit
            )
      RETURN customer_ntt
      PIPELINED 
      PARALLEL_ENABLE (PARTITION p_source BY HASH(customer_id))
      ORDER p_source BY (customer_id, address_id) IS

      aa_source     customer_staging_aat;
      v_customer_id customer_staging.customer_id%TYPE := -1;

   BEGIN
      LOOP
         FETCH p_source BULK COLLECT INTO aa_source LIMIT p_limit_size;
         EXIT WHEN aa_source.COUNT = 0;

         FOR i IN 1 .. aa_source.COUNT LOOP

            /* 
            || Need to build a record with a max of 3 addresses.
            || Compare with saved customer_id and only pipe a customer record
            || when the customer_id changes ("control break logic")...
            */
            IF aa_source(i).customer_id != v_customer_id THEN
               PIPE ROW ( customer_detail_ot( aa_source(i).customer_id,
                                              aa_source(i).first_name,
                                              aa_source(i).last_name,
                                              aa_source(i).birth_date ));
            END IF;

            PIPE ROW( address_detail_ot( aa_source(i).customer_id,
                                         aa_source(i).address_id, 
                                         aa_source(i).primary,
                                         aa_source(i).street_address,
                                         aa_source(i).postal_code ));

            /* Save customer ID for "control break" logic... */
            v_customer_id := aa_source(i).customer_id;

         END LOOP;
      END LOOP;
      CLOSE p_source;
      RETURN;
   END customer_transform_multi;

   ------------------------------------------------------------
   FUNCTION customer_transform_denorm(
            p_source     IN customer_staging_rct,
            p_limit_size IN PLS_INTEGER DEFAULT customer_pkg.c_default_limit
            )
      RETURN customer_address_ntt
      PIPELINED 
      PARALLEL_ENABLE (PARTITION p_source BY HASH(customer_id))
      ORDER p_source BY (customer_id, address_id) IS

      aa_source     customer_staging_aat;
      r_outrow      customer_address_ot := customer_address_ot();
      v_customer_id customer_staging.customer_id%TYPE := -1;
      v_first_time  BOOLEAN := TRUE;

   BEGIN
      LOOP
         FETCH p_source BULK COLLECT INTO aa_source LIMIT p_limit_size;
         EXIT WHEN aa_source.COUNT = 0;

         FOR i IN 1 .. aa_source.COUNT LOOP

            /* 
            || Output one customer record regardless of number of addresses.
            || Compare with saved customer_id and only pipe a customer record
            || when the customer_id changes ("control break logic")...
            */
            IF aa_source(i).customer_id != v_customer_id THEN
               IF NOT v_first_time THEN
                  PIPE ROW (r_outrow);
                  r_outrow := customer_address_ot();
               ELSE
                  v_first_time := FALSE;
               END IF;

               /* Prepare customer and addr1 attributes... */
               r_outrow.customer_id          := aa_source(i).customer_id;
               r_outrow.first_name           := aa_source(i).first_name;
               r_outrow.last_name            := aa_source(i).last_name;
               r_outrow.birth_date           := aa_source(i).birth_date;
               r_outrow.addr1_address_id     := aa_source(i).address_id;
               r_outrow.addr1_primary        := aa_source(i).primary;
               r_outrow.addr1_street_address := aa_source(i).street_address;
               r_outrow.addr1_postal_code    := aa_source(i).postal_code;

            ELSE

               /*
               || Not the first instance of this customer so add some address
               || details...
               */
               IF r_outrow.addr2_address_id IS NULL THEN
                  r_outrow.addr2_address_id     := aa_source(i).address_id;
                  r_outrow.addr2_primary        := aa_source(i).primary;
                  r_outrow.addr2_street_address := aa_source(i).street_address;
                  r_outrow.addr2_postal_code    := aa_source(i).postal_code;
               ELSE
                  r_outrow.addr3_address_id     := aa_source(i).address_id;
                  r_outrow.addr3_primary        := aa_source(i).primary;
                  r_outrow.addr3_street_address := aa_source(i).street_address;
                  r_outrow.addr3_postal_code    := aa_source(i).postal_code;
               END IF;
 
            END IF;

            /* Save customer ID for "control break" logic... */
            v_customer_id := aa_source(i).customer_id;

         END LOOP;
      END LOOP;

      /* Pipe any remaining data... */
      PIPE ROW (r_outrow);

      CLOSE p_source;
      RETURN;
   END customer_transform_denorm;

   ------------------------------------------------------------
   PROCEDURE load_customers_multi IS
   BEGIN

      INSERT FIRST
         --
         WHEN record_type = 'C'
         THEN
            INTO customers ( customer_id, first_name, last_name, birth_date )
            VALUES ( customer_id, first_name, last_name, birth_date )
         --
         WHEN record_type = 'A'
         THEN
            INTO addresses ( address_id, customer_id, primary, street_address, postal_code )
            VALUES ( address_id, customer_id, primary, street_address, postal_code )
         --
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
      FROM (
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

      DBMS_OUTPUT.PUT_LINE( SQL%ROWCOUNT || ' rows inserted.' );

   END load_customers_multi;

   ------------------------------------------------------------
   PROCEDURE load_customers_denorm IS
   BEGIN

      INSERT ALL
         --
         WHEN 1=1 
         THEN
            INTO customers ( customer_id, first_name, last_name, birth_date )
            VALUES ( customer_id, first_name, last_name, birth_date )
         --
         WHEN 1=1
         THEN
            INTO addresses ( address_id, customer_id, primary, street_address, postal_code )
            VALUES ( addr1_address_id, customer_id, addr1_primary, addr1_street_address, addr1_postal_code )
         --
         WHEN addr2_address_id IS NOT NULL
         THEN
            INTO addresses ( address_id, customer_id, primary, street_address, postal_code )
            VALUES ( addr2_address_id, customer_id, addr2_primary, addr2_street_address, addr2_postal_code )
         --
         WHEN addr3_address_id IS NOT NULL
         THEN
            INTO addresses ( address_id, customer_id, primary, street_address, postal_code )
            VALUES ( addr3_address_id, customer_id, addr3_primary, addr3_street_address, addr3_postal_code )
         --
      SELECT *
      FROM   TABLE(
                customer_pkg.customer_transform_denorm(
                   CURSOR( SELECT * FROM customer_staging ) ) ) nt;

      DBMS_OUTPUT.PUT_LINE( SQL%ROWCOUNT || ' rows inserted.' );

   END load_customers_denorm;

END customer_pkg;
/

