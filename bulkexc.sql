DECLARE
   bulk_errors   EXCEPTION;
   PRAGMA EXCEPTION_INIT (bulk_errors, -24381);
   TYPE namelist_t IS TABLE OF employees.last_name%TYPE;

   enames_with_errors   namelist_t
      := namelist_t ('ABC',
           'DEF',
           NULL, /* Last name cannot be NULL */
           'LITTLE',
           RPAD ('BIGBIGGERBIGGEST', 250, 'ABC'), /* Value too long */
           'SMITHIE'
          );
BEGIN
   FORALL indx IN enames_with_errors.FIRST .. enames_with_errors.LAST 
      SAVE EXCEPTIONS
      EXECUTE IMMEDIATE    
	    'UPDATE employees SET last_name = :new_name'
         USING enames_with_errors (indx);
EXCEPTION
   WHEN bulk_errors 
   THEN
      DBMS_OUTPUT.put_line ('Updated ' || SQL%ROWCOUNT || ' rows.');

      FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
      LOOP
        DBMS_OUTPUT.PUT_LINE ('Error '
              || indx
              || ' occurred during '
              || 'iteration '
              || SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX
              || ' updating name to '
              || enames_with_errors (SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX);
        DBMS_OUTPUT.PUT_LINE ('Oracle error is '
               || SQLERRM (  -1 * SQL%BULK_EXCEPTIONS (indx).ERROR_CODE)
              );
      END LOOP;
END;
/
