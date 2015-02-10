/*-- pizza_triggers.sql */
CREATE OR REPLACE TRIGGER delivery_info_insert
INSTEAD OF INSERT ON delivery_info
DECLARE

  -- cursor to get the driver ID by name
  CURSOR curs_get_driver_id ( cp_driver_name VARCHAR2 ) IS
  SELECT driver_id
    FROM driver
   WHERE driver_name = cp_driver_name;
  v_driver_id NUMBER;

  -- cursor to get the area ID by name
  CURSOR curs_get_area_id ( cp_area_desc VARCHAR2 ) IS
  SELECT area_id
    FROM area
   WHERE area_desc = cp_area_desc;
  v_area_id NUMBER;

BEGIN

  /*
    || Make sure the delivery_end value is NULL
  */
  IF :new.delivery_end IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000,'Delivery end date value must be NULL when delivery created');
  END IF;

  /*
    || Try to get the driver ID using the name. If not found
    || then create a brand new driver ID from the sequence
  */
  OPEN curs_get_driver_id(UPPER(:new.driver_name));
  FETCH curs_get_driver_id INTO v_driver_id;
  IF curs_get_driver_id%NOTFOUND THEN
    SELECT driver_id_seq.nextval
      INTO v_driver_id
      FROM DUAL;
    INSERT INTO driver(driver_id,driver_name)
    VALUES(v_driver_id,UPPER(:new.driver_name));
  END IF;
  CLOSE curs_get_driver_id;

  /*
    || Try to get the area ID using the name. If not found
    || then create a brand new area ID from the sequence
  */
  OPEN curs_get_area_id(UPPER(:new.area_desc));
  FETCH curs_get_area_id INTO v_area_id;
  IF curs_get_area_id%NOTFOUND THEN
    SELECT area_id_seq.nextval
      INTO v_area_id
      FROM DUAL;
    INSERT INTO area(area_id,area_desc)
    VALUES(v_area_id,UPPER(:new.area_desc));
  END IF;
  CLOSE curs_get_area_id;

  /*
    || Create the delivery entry
  */
  INSERT INTO delivery(delivery_id,
                       delivery_start,
                       delivery_end,
                       area_id,
                       driver_id)
  VALUES(delivery_id_seq.nextval,
         NVL(:NEW.delivery_start,SYSDATE),
         NULL,
         v_area_id,
         v_driver_id);

END;
/
CREATE OR REPLACE TRIGGER delivery_info_update
INSTEAD OF UPDATE ON delivery_info
DECLARE

  -- cursor to get the delivery entry
  CURSOR curs_get_delivery ( cp_delivery_id NUMBER ) IS
  SELECT delivery_end
    FROM delivery
   WHERE delivery_id = cp_delivery_id
  FOR UPDATE OF delivery_end;
  v_delivery_end DATE;

BEGIN

  OPEN curs_get_delivery(:NEW.delivery_id);
  FETCH curs_get_delivery INTO v_delivery_end;
  IF v_delivery_end IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000,'The delivery end date has already been set');
  ELSE
    UPDATE delivery
    SET delivery_end = :new.delivery_end
    WHERE CURRENT OF curs_get_delivery;
  END IF;
  CLOSE curs_get_delivery;

END;
/

CREATE OR REPLACE TRIGGER delivery_info_delete
INSTEAD OF DELETE
ON delivery_info
BEGIN
  IF :new.delivery_end IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000,'Completed deliveries cannot be deleted');
  END IF;
  DELETE delivery
  WHERE delivery_id = :new.delivery_id;
END;
/

SHO ERR

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
