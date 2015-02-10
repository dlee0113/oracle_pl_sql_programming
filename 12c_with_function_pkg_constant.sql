CREATE TABLE plch_accounts
(
   account_name     VARCHAR2 (100),
   account_status   VARCHAR2 (6)
)
/

BEGIN
   INSERT INTO plch_accounts
        VALUES ('ACME WIDGETS', 'ACTIVE');

   INSERT INTO plch_accounts
        VALUES ('BEST SHOES', 'CLOSED');

   COMMIT;
END;
/

/* Cannot reference constant directly */

CREATE OR REPLACE PACKAGE plch_constants
IS
   active   CONSTANT VARCHAR2 (6)
                        := 'ACTIVE' ;
   closed   CONSTANT VARCHAR2 (6)
                        := 'CLOSED' ;
END;
/

SELECT account_name
  FROM plch_accounts
 WHERE account_status =
          plch_constants.active
/

/* Can move it to a package body */

CREATE OR REPLACE PACKAGE plch_constants
IS
   FUNCTION active
      RETURN VARCHAR2;

   FUNCTION closed
      RETURN VARCHAR2;
END;
/

CREATE OR REPLACE PACKAGE BODY plch_constants
IS
   FUNCTION active
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'ACTIVE';
   END;

   FUNCTION closed
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'CLOSED';
   END;
END;
/

SELECT account_name
  FROM plch_accounts
 WHERE account_status =
          plch_constants.active
/
          
/* 12c only */

DROP PACKAGE plch_constants
/

CREATE OR REPLACE PACKAGE plch_constants
IS
   active   CONSTANT VARCHAR2 (6)
                        := 'ACTIVE' ;
   closed   CONSTANT VARCHAR2 (6)
                        := 'CLOSED' ;
END;
/

WITH 
   FUNCTION active
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN plch_constants.active;
   END;
SELECT account_name
  FROM plch_accounts
 WHERE account_status = active
/

/* Clean up */

DROP PACKAGE plch_constants
/

DROP TABLE plch_accounts
/
