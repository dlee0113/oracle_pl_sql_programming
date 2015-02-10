/* The INTERVAL example involving the good_for table */
CREATE TABLE good_for (
   product_id NUMBER,
   good_for INTERVAL YEAR(2) TO MONTH NOT NULL
);

CREATE OR REPLACE FUNCTION get_expiration (p_product_id NUMBER)
   RETURN DATE
AS
   v_good_for good_for.good_for%type;
   expiration_date DATE;
   found_flag BOOLEAN;
BEGIN
  --Use a nested block to catch exceptions from singleton SELECT.
  --Steven hates singleton SELECTs, but we'll use one anyway.
  BEGIN
    SELECT gf.good_for INTO v_good_for
    FROM good_for gf
    WHERE gf.product_id = p_product_id;

    --If we reach this point, no exception was thrown, so
    --we know we found a row and retrieved a value.
    found_flag := TRUE;
  EXCEPTION
     WHEN OTHERS THEN
       found_flag := FALSE;
  END;

  --Return an expiration date if we found a "good for" interval,
  --otherwise return NULL to signify an invalid product ID
  --or other problem. Truncate the current date so that we are left
  --with only the date, and not the time-of-day.
  IF found_flag THEN
    expiration_date := TRUNC(SYSDATE) + v_good_for;
  ELSE
    expiration_date := null;
  END IF;

  RETURN expiration_date;
END;
/

INSERT INTO good_for (product_id, good_for)
   VALUES (1, INTERVAL '1-4' YEAR TO MONTH);

SELECT get_expiration(1) FROM DUAL;



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
