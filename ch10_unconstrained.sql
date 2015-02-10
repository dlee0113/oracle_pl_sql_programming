/* Following are all the examples relating to unconstrained intervals. */

DECLARE
   A INTERVAL DAY TO SECOND;
   C INTERVAL DAY(9) TO SECOND(2);
BEGIN
   A := '10 0:0:0.123456';
   C := A;
   DBMS_OUTPUT.PUT_LINE (A);
   DBMS_OUTPUT.PUT_LINE (C);
END;
/

DECLARE
   B INTERVAL DAY(9) TO SECOND(9);

   FUNCTION double_my_interval (
      A IN INTERVAL DAY TO SECOND) RETURN INTERVAL DAY TO SECOND
   IS
   BEGIN
      RETURN A * 2;
   END;
BEGIN
   B := '1 0:0:0.123456789';
   DBMS_OUTPUT.PUT_LINE(B);
   DBMS_OUTPUT.PUT_LINE(double_my_interval(B));
END;
/

DECLARE
   B INTERVAL DAY(9) TO SECOND(9);

   FUNCTION double_my_interval (
      A IN DSINTERVAL_UNCONSTRAINED) RETURN DSINTERVAL_UNCONSTRAINED
   IS
   BEGIN
      RETURN A * 2;
   END;
BEGIN
   B := '100 0:0:0.123456789';
   DBMS_OUTPUT.PUT_LINE(B);
   DBMS_OUTPUT.PUT_LINE(double_my_interval(B));
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
