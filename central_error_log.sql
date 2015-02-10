/*-- error_log.sql */
DROP TABLE error_log;
CREATE TABLE error_log
(username     VARCHAR2(30),
 error_number NUMBER,
 sequence     NUMBER,
 timestamp    DATE);

CREATE OR REPLACE PACKAGE central_error_log AS

  /*
    || CENTRAL_ERROR_LOG
    ||
    || This package handles the collection and manipulation of
    || Oracle error information as trapped in a SERVERERROR
    || trigger.
    ||
    || 04-JAN-02 DRH Initial Version
  */

  -- structure to hold results of error # search
  TYPE v_find_record IS RECORD ( total_found   NUMBER,
                                 min_timestamp DATE,
                                 max_timestamp DATE );

  -- structure to hold log of all errors
  TYPE v_error_table_type IS TABLE OF error_log%ROWTYPE
    INDEX BY BINARY_INTEGER;
  v_error_table v_error_table_type;

  -- main logging procedure called from the trigger
  PROCEDURE log_error;

  -- purge the in memory log
  PROCEDURE purge_log;

  -- search the log for a specific error
  PROCEDURE find_error ( p_errno      IN  NUMBER,
                         p_find_table OUT v_find_record );

  -- save (and optionally purge) the log
  PROCEDURE save_log ( p_purge BOOLEAN := FALSE);

  -- view the error log with optional specific error, start
  -- and end date ranges
  PROCEDURE view_log ( p_errno    NUMBER := NULL,
                       p_min_date DATE := NULL,
                       p_max_date DATE := NULL );

END central_error_log;
/

SHO ERR

CREATE OR REPLACE PACKAGE BODY central_error_log AS

  /*-----------------------------------------------------------*/
  PROCEDURE log_error IS
  /*-----------------------------------------------------------*/

    v_errnum  NUMBER;
    v_counter NUMBER := 1;
    v_now     DATE := SYSDATE;

  BEGIN

    LOOP

      -- get the error number off the stack
      v_errnum := ORA_SERVER_ERROR(v_counter);

      -- if the error # is zero then we are done
      EXIT WHEN v_errnum = 0;

      -- add the error to the PL/SQL table
      v_error_table(NVL(v_error_table.LAST,0) + 1).username := ORA_LOGIN_USER;
      v_error_table(v_error_table.LAST).error_number        := v_errnum;
      v_error_table(v_error_table.LAST).sequence            := v_counter;
      v_error_table(v_error_table.LAST).timestamp           := v_now;

      -- increment the counter and try again
      v_counter := v_counter + 1;

    END LOOP;  -- every error on the stack

  END log_error;

  /*-----------------------------------------------------------*/
  PROCEDURE purge_log IS
  /*-----------------------------------------------------------*/
  BEGIN
    v_error_table.DELETE;
  END purge_log;

  /*-----------------------------------------------------------*/
  PROCEDURE find_error ( p_errno      IN  NUMBER,
                         p_find_table OUT v_find_record ) IS
  /*-----------------------------------------------------------*/
  BEGIN
    FOR counter IN 1..v_error_table.COUNT LOOP
      IF v_error_table(counter).error_number = p_errno THEN
        p_find_table.total_found := NVL(p_find_table.total_found,0) + 1;
        p_find_table.min_timestamp := LEAST(NVL(p_find_table.min_timestamp,v_error_table(counter).timestamp),
                                            v_error_table(counter).timestamp);
        p_find_table.max_timestamp := GREATEST(NVL(p_find_table.min_timestamp,v_error_table(counter).timestamp),
                                               v_error_table(counter).timestamp);
      END IF;
    END LOOP;
  END find_error;

  /*-----------------------------------------------------------*/
  PROCEDURE save_log ( p_purge BOOLEAN := FALSE) IS
  /*-----------------------------------------------------------*/
  BEGIN

    FOR counter IN 1..v_error_table.COUNT LOOP

      INSERT INTO error_log(username,
                            error_number,
                            sequence,
                            timestamp)
      VALUES(v_error_table(counter).username,
             v_error_table(counter).error_number,
             v_error_table(counter).sequence,
             v_error_table(counter).timestamp);

    END LOOP;

    IF p_purge THEN
      v_error_table.DELETE;
    END IF;

  END save_log;

  /*-----------------------------------------------------------*/
  PROCEDURE view_log ( p_errno    NUMBER := NULL,
                       p_min_date DATE := NULL,
                       p_max_date DATE := NULL ) IS
  /*-----------------------------------------------------------*/
  BEGIN

    DBMS_OUTPUT.PUT_LINE('Error# Seq Timestamp');
    DBMS_OUTPUT.PUT_LINE('------ --- --------------------');

    FOR counter IN 1..v_error_table.COUNT LOOP

      IF NVL(p_errno,v_error_table(counter).error_number) = 
         v_error_table(counter).error_number AND
         GREATEST(NVL(p_min_date,v_error_table(counter).timestamp),v_error_table(counter).timestamp) =
         v_error_table(counter).timestamp AND
         LEAST(NVL(p_max_date,v_error_table(counter).timestamp),v_error_table(counter).timestamp) =
         v_error_table(counter).timestamp THEN

        DBMS_OUTPUT.PUT_LINE(LPAD(v_error_table(counter).error_number,6,0) || ' ' ||
                             LPAD(v_error_table(counter).sequence,3)       || ' ' ||
                             TO_CHAR(v_error_table(counter).timestamp,'DD-MON-YYYY HH24:MI:SS'));
      END IF;

    END LOOP;

  END view_log;

END central_error_log;
/

SHO ERR

CREATE OR REPLACE TRIGGER error_log
AFTER SERVERERROR
ON DATABASE
BEGIN
  central_error_log.log_error;
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
