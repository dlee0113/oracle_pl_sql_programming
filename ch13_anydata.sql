/* Demonstrate the use of SYS.AnyData. */

/* First, create two object types */
CREATE OR  REPLACE TYPE waterfall AS OBJECT (
   name VARCHAR2(30),
   height NUMBER
);
/

CREATE OR REPLACE TYPE river AS OBJECT (
   name VARCHAR2(30),
   length NUMBER
);
/

/* Use SYS.AnyData as the basis for creating a heterogeneous array
   of objects */
DECLARE
   TYPE feature_array IS VARRAY(2) OF SYS.AnyData;
   features feature_array;
   wf waterfall;
   rv river;
   ret_val NUMBER;
BEGIN
   --Create an array where each element is of
   --a different object type
   features := feature_array(
                  SYS.AnyData.ConvertObject(
                     waterfall('Grand Sable Falls',30)),
                  SYS.AnyData.ConvertObject(
                     river('Manistique River', 85.40))
               );

   --Display the feature data
   FOR x IN 1..features.COUNT LOOP
      --Execute code pertaining to whatever object type
      --we are currently looking at. NOTE! Replace GENNICK
      --with whatever schema you are using.
       CASE features(x).GetTypeName
       WHEN 'GENNICK.WATERFALL' THEN
          ret_val := features(x).GetObject(wf);
          DBMS_OUTPUT.PUT_LINE('Waterfall: '
             || wf.name || ', Height = ' || wf.height || ' feet.');
       WHEN 'GENNICK.RIVER' THEN
          ret_val := features(x).GetObject(rv);
          DBMS_OUTPUT.PUT_LINE('River: '
             || rv.name || ', Length = ' || rv.length || ' miles.');
       END CASE;
   END LOOP;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
