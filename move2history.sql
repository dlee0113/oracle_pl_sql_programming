-- according to tahiti.oracle.com
-- from: Oracle Database 10g Release 2 (10.2)
-- and onwards
clear screen
set serveroutput on
drop table occupancy purge;
drop table occupancy_history purge;
drop table occupancy_history_error purge;
create table occupancy
(
  pet_id number
, name varchar2(30)
, checkout_date date
);
create table occupancy_history
(
  pet_id number
, name varchar2(30) not null
, checkout_date date
);
-- Create the error logging table.
BEGIN
  DBMS_ERRLOG.create_error_log ( dml_table_name => 'occupancy_history'
                               , err_log_table_name => 'occupancy_history_error'
                               , err_log_table_owner => user );
END;
/

insert into occupancy (pet_id, name, checkout_date) values (1,'Patrick',null);
insert into occupancy (pet_id, name, checkout_date) values (2,'Dana',null);
insert into occupancy (pet_id, name, checkout_date) values (3,'Quinty',null);
insert into occupancy (pet_id, name, checkout_date) values (4,'Kayleigh',null);
insert into occupancy (pet_id, name, checkout_date) values (5,'Mitchell',null);
insert into occupancy (pet_id, name, checkout_date) values (6,null,null);
select * from occupancy;
update occupancy
   set checkout_date = sysdate
 where pet_id > 2;
 
insert into occupancy_history(pet_id, name, checkout_date)
  select pet_id, name, checkout_date
    from occupancy where checkout_date is not null
    log errors into occupancy_history_error reject limit unlimited;
delete from occupancy where checkout_date is not null
and not exists (select 1
                  from occupancy_history_error
                 where occupancy_history_error.pet_id = occupancy.pet_id);
select * from occupancy;
select * from occupancy_history;
select * from occupancy_history_error;
drop table occupancy purge;
drop table occupancy_history purge;
drop table occupancy_history_error purge;
