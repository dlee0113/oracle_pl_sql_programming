DROP TRIGGER error_logger;

DROP TABLE error_log;

CREATE SEQUENCE error_seq;

CREATE TABLE error_log
(error_id     NUMBER,
 username     VARCHAR2(30),
 error_number NUMBER,
 sequence     NUMBER,
 timestamp    DATE);

CREATE OR REPLACE TRIGGER error_logger
AFTER SERVERERROR
ON SCHEMA
DECLARE

  v_errnum    NUMBER;          -- the Oracle error #
  v_now       DATE := SYSDATE; -- current time

BEGIN

  -- for every error in the error stack...
  FOR e_counter IN 1..ORA_SERVER_ERROR_DEPTH LOOP

    -- write the error out to the log table; no
    -- commit is required because we are in an
    -- autonomous transaction
    INSERT INTO error_log(error_id,
                          username,
                          error_number,
                          sequence,
                          timestamp)
    VALUES(error_seq.nextval,
           USER,
           ORA_SERVER_ERROR(e_counter),
           e_counter,
           v_now);

  END LOOP;  -- every error on the stack

END;
/


