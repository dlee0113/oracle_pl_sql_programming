DECLARE
   msg     VARCHAR2 (1000);
   isval   BOOLEAN;

   PROCEDURE plsb (str IN VARCHAR2, val IN BOOLEAN)
   IS
   BEGIN
      IF val
      THEN
         DBMS_OUTPUT.put_line (str || ' - TRUE');
      ELSIF NOT val
      THEN
         DBMS_OUTPUT.put_line (str || ' - FALSE');
      ELSE
         DBMS_OUTPUT.put_line (str || ' - NULL');
      END IF;
   END plsb;
BEGIN
   oracle_error_info.validate_oracle_error (100, msg, isval);
   plsb (msg, isval);
   oracle_error_info.validate_oracle_error (-1403, msg, isval);
   plsb (msg, isval);
   oracle_error_info.validate_oracle_error (1, msg, isval);
   plsb (msg, isval);
   oracle_error_info.validate_oracle_error (-1850, msg, isval);
   plsb (msg, isval);
   oracle_error_info.validate_oracle_error (120000, msg, isval);
   plsb (msg, isval);
   oracle_error_info.validate_oracle_error (1200000000, msg, isval);
   plsb (msg, isval);
   oracle_error_info.validate_oracle_error (-20000, msg, isval);
   plsb (msg, isval);
END;