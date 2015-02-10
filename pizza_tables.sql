/*-- pizza_tables.sql */
CREATE TABLE delivery
(delivery_id	NUMBER,
 delivery_start	DATE,
 delivery_end	DATE,
 area_id	NUMBER,
 driver_id	NUMBER);

CREATE TABLE area
(area_id	NUMBER,
 area_desc	VARCHAR2(30));

CREATE TABLE driver
(driver_id	NUMBER,
 driver_name	VARCHAR2(30));

CREATE SEQUENCE delivery_id_seq;
CREATE SEQUENCE area_id_seq;
CREATE SEQUENCE driver_id_seq;

CREATE OR REPLACE VIEW delivery_info AS
SELECT d.delivery_id,
       d.delivery_start,
       d.delivery_end,
       a.area_desc,
       dr.driver_name
  FROM delivery      d,
       area             a,
       driver          dr
 WHERE a.area_id = d.area_id
   AND dr.driver_id = d.driver_id;


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
