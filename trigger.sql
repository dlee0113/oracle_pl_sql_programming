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
       
create or replace trigger tr_customer_bru
before update
 on customer
for each row
when (new.id is null)
--as
begin
  if (:new.ID is null) then :new.id := 1; end if;
end;
/
sho err;
insert into customer (id, name) values (10,'Test');
select * from customer;
update customer set id = null where id = 10;
select * from customer;
commit;
