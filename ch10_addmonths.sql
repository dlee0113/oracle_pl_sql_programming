/* The following code is from the "Getting Around ADD_MONTH's
   Month-end Quirk" Sidebar. This code wraps the my_add_months
   function in an anonymous block, and also invokes it on the
   dates mentioned in the sidebar. */
DECLARE
    FUNCTION my_add_months (
        date_in IN DATE, months_shift IN NUMBER)
        RETURN DATE IS
            date_out DATE;
            day_in NUMBER;
            day_out NUMBER;
    BEGIN
        date_out := ADD_MONTHS(date_in, months_shift);
        day_in := TO_NUMBER(TO_CHAR(date_in,'DD'));
        day_out := TO_NUMBER(TO_CHAR(date_out,'DD'));
        IF day_out > day_in
        THEN
            date_out := date_out - (day_out - day_in);
        END IF;

        RETURN date_out;
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(my_add_months(
        TO_DATE('31-Jan-2002 13:14:15','dd-mon-yyyy hh24:mi:ss'),1),
        'dd-Mon-yyyy hh24:mi:ss'));

    DBMS_OUTPUT.PUT_LINE(TO_CHAR(my_add_months(
        TO_DATE('28-Feb-2002 13:14:15','dd-mon-yyyy hh24:mi:ss'),1),
        'dd-Mon-yyyy hh24:mi:ss'));
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
