clear screen
set serveroutput on

drop table cust_sales_roundup purge;
drop table customer purge;
CREATE TABLE cust_sales_roundup (
       customer_id NUMBER (5),
       customer_name VARCHAR2 (100),
       total_sales NUMBER (15,2)
       );
CREATE TABLE customer (
       id NUMBER (5),
       name VARCHAR2 (100)
       );
       
DECLARE
   cust_sales_roundup_rec cust_sales_roundup%ROWTYPE;

   CURSOR cust_sales_cur IS SELECT * FROM cust_sales_roundup;
   cust_sales_rec cust_sales_cur%ROWTYPE;

   TYPE customer_sales_rectype IS RECORD
      (customer_id NUMBER(5),
       customer_name customer.name%TYPE,
       total_sales NUMBER(15,2)
      );
   prefererred_cust_rec customer_sales_rectype;
BEGIN
   -- Assign one record to another.
   cust_sales_roundup_rec := cust_sales_rec;
   prefererred_cust_rec := cust_sales_rec;
END;
/
       
DECLARE
   cust_sales_roundup_rec cust_sales_roundup%ROWTYPE;

   CURSOR cust_sales_cur IS SELECT * FROM cust_sales_roundup;
   cust_sales_rec cust_sales_cur%ROWTYPE;

   TYPE customer_sales_rectype IS RECORD
      (customer_id NUMBER(5),
       customer_name customer.name%TYPE,
       total_sales NUMBER(15,2)
      );
   prefererred_cust_rec customer_sales_rectype;
BEGIN
   cust_sales_rec.customer_name := 'Patrick';
   -- Assign one record to another.
   cust_sales_roundup_rec := cust_sales_rec;
   prefererred_cust_rec := cust_sales_rec;
   dbms_output.put_line(prefererred_cust_rec.customer_name);
END;
/
