/* Formatted on 2001/12/26 15:47 (Formatter Plus v4.5.2) */
DROP TABLE hairstyles;

CREATE TABLE hairstyles (
   code INTEGER,
   description VARCHAR2(100)
   );

INSERT INTO hairstyles VALUES (1000, 'CREWCUT');
INSERT INTO hairstyles VALUES (1001, 'BOB');
INSERT INTO hairstyles VALUES (1002, 'SHAG');
INSERT INTO hairstyles VALUES (1003, 'BOUFFANT');
INSERT INTO hairstyles VALUES (1004, 'PAGEBOY');

CREATE OR REPLACE PACKAGE justonce
IS
   FUNCTION description (code_in IN hairstyles.code%TYPE)
      RETURN hairstyles.description%TYPE;
END justonce;
/

CREATE OR REPLACE PACKAGE BODY justonce
IS
   TYPE desc_t IS TABLE OF hairstyles.description%TYPE
      INDEX BY BINARY_INTEGER;
   descriptions   desc_t;

   FUNCTION description (code_in IN hairstyles.code%TYPE)
      RETURN hairstyles.description%TYPE
   IS
      return_value   hairstyles.description%TYPE;

      FUNCTION desc_from_database RETURN hairstyles.description%TYPE
      IS
         CURSOR desc_cur IS
            SELECT description FROM hairstyles WHERE code = code_in;
         desc_rec   desc_cur%ROWTYPE;
      BEGIN
         OPEN desc_cur;
         FETCH desc_cur INTO desc_rec;
         RETURN desc_rec.description;
      END;
   BEGIN
      RETURN descriptions (code_in);
   EXCEPTION
      WHEN NO_DATA_FOUND 
	  THEN
         descriptions (code_in) := desc_from_database;
         RETURN descriptions (code_in);
   END;
END justonce;
/

BEGIN
   DBMS_OUTPUT.PUT_LINE (justonce.description (1000));
   DBMS_OUTPUT.PUT_LINE (justonce.description (1002));
   DBMS_OUTPUT.PUT_LINE (justonce.description (1004));
END;
/
   


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
