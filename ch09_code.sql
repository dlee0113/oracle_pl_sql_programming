/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 9

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

DECLARE
   tiny_nbr   NUMBER := 1e-130;
   test_nbr   NUMBER;
   --                              1111111111222222222233333333334
   --                     1234567890123456789012345678901234567890
   big_nbr    NUMBER := 9.999999999999999999999999999999999999999e125;
   --                                 1111111111222222222233333333334444444
   --                        1234567890123456789012345678901234567890123456
   fmt_nbr VARCHAR2 (50)
         := '9.99999999999999999999999999999999999999999EEEE';
BEGIN
   DBMS_OUTPUT.put_line (
      'tiny_nbr          =' || TO_CHAR (tiny_nbr, '9.9999EEEE')
   );
   -- NUMBERs that are too small round down to zero
   test_nbr := tiny_nbr / 1.0001;
   DBMS_OUTPUT.put_line ('tiny made smaller =' || TO_CHAR (test_nbr, fmt_nbr)
                        );
   -- NUMBERs that are too large throw an error
   DBMS_OUTPUT.put_line ('big_nbr           =' || TO_CHAR (big_nbr, fmt_nbr));
   test_nbr := big_nbr * 1.0001;                                    -- too big
   DBMS_OUTPUT.put_line ('big made bigger   =' || TO_CHAR (test_nbr, fmt_nbr)
                        );
END;
/

DECLARE
   low_nbr   NUMBER (38, 127);
       high_nbr number(38,-84);
BEGIN
   /* 127 is largest scale, so begin with 1 and move
      decimal point 127 places to the left. Easy. */
   low_nbr := 1E-127;
   DBMS_OUTPUT.put_line ('low_nbr = ' || low_nbr);

   /* -84 is smallest scale value. Add 37 to normalize
      the scientific-notation, and we get E+121. */
   high_nbr := 9.9999999999999999999999999999999999999E+121;
   DBMS_OUTPUT.put_line ('high_nbr = ' || high_nbr);
END;
/

DECLARE
   loop_counter            PLS_INTEGER;
   days_in_standard_year   CONSTANT PLS_INTEGER := 365;
   emp_vacation_days       PLS_INTEGER DEFAULT 14;
BEGIN
   NULL;
END;
/

DECLARE
   int1   PLS_INTEGER;
   int2   PLS_INTEGER;
   int3   PLS_INTEGER;
   nbr    NUMBER;
BEGIN
   int1 := 100;
   int2 := 49;
   int3 := int2 / int1;
   nbr := int2 / int1;
   DBMS_OUTPUT.put_line ('integer 100/49 =' || TO_CHAR (int3));
   DBMS_OUTPUT.put_line ('number  100/49 =' || TO_CHAR (nbr));
   int2 := 50;
   int3 := int2 / int1;
   nbr := int2 / int1;
   DBMS_OUTPUT.put_line ('integer 100/50 =' || TO_CHAR (int3));
   DBMS_OUTPUT.put_line ('number  100/50 =' || TO_CHAR (nbr));
END;

DECLARE
   my_binary_float    BINARY_FLOAT := .95f;
   my_binary_double   BINARY_DOUBLE := .95d;
   my_number          NUMBER := .95;
BEGIN
   NULL;
END;
/

BEGIN
   DBMS_OUTPUT.put_line (0.95f);                                --BINARY_FLOAT
   DBMS_OUTPUT.put_line (0.95d);                               --BINARY_DOUBLE
   DBMS_OUTPUT.put_line (0.95);                                       --NUMBER
END;
/

BEGIN
   IF 0.95f = 0.95d
   THEN
      DBMS_OUTPUT.put_line ('TRUE');
   ELSE
      DBMS_OUTPUT.put_line ('FALSE');
   END IF;

   IF ABS (0.95f - 0.95d) < 0.000001d
   THEN
      DBMS_OUTPUT.put_line ('TRUE');
   ELSE
      DBMS_OUTPUT.put_line ('FALSE');
   END IF;
END;
/

DECLARE
   nbr    NUMBER := 0.95;
   bf     BINARY_FLOAT := 2;
   nbr1   NUMBER;
   nbr2   NUMBER;
BEGIN
   --Default precedence, promote to binary_float
   nbr1 := nbr * bf;

   --Demote BINARY_FLOAT to NUMBER instead
   nbr2 := nbr * TO_NUMBER (bf);

   DBMS_OUTPUT.put_line (nbr1);
   DBMS_OUTPUT.put_line (nbr2);
END;
/

DECLARE
   a    NUMBER;
   b    NUMBER;
   c    NUMBER;
   d    NUMBER;
   e    BINARY_FLOAT;
   f    BINARY_DOUBLE;
   g    BINARY_DOUBLE;

   n1   VARCHAR2 (20) := '-123456.78';
   n2   VARCHAR2 (20) := '+123456.78';
BEGIN
   a := TO_NUMBER ('123.45');
   b := TO_NUMBER (n1);
   c := TO_NUMBER (n2);
   d := TO_NUMBER ('1.25E2');
   e := TO_BINARY_FLOAT ('123.45');
   f := TO_BINARY_DOUBLE ('inf');
   g := TO_BINARY_DOUBLE ('NAN');
END;
/

DECLARE
   a   NUMBER;
BEGIN
   a := TO_NUMBER ('$123,456.78', 'L999G999D99');
   a := TO_NUMBER ('$123,456.78', 'L999G999G999D99');
   a := TO_NUMBER ('$1234,567,890.78', 'L999G999G999D99');
   a := TO_NUMBER ('$234,567,890.789', 'L999G999G999D99');
   a := TO_NUMBER ('001,234', '000G000');
   a := TO_NUMBER ('<123.45>', '999D99PR');
   a := TO_NUMBER ('cxxiii', 'rn');
   a := TO_NUMBER ('1.23456E-24');
END;
/

SELECT *
  FROM nls_session_parameters
/

DECLARE
   a   NUMBER;
BEGIN
   a :=
      TO_NUMBER (
         'F123.456,78'
       , 'L999G999D99'
       ,    'NLS_NUMERIC_CHARACTERS='',.'''
         || ' NLS_CURRENCY=''F'''
         || ' NLS_ISO_CURRENCY=FRANCE'
      );
END;
/

DECLARE
   b   VARCHAR2 (30);
BEGIN
   b := TO_CHAR (123456789.01);
   DBMS_OUTPUT.put_line (b);
END;
/

DECLARE
   b   VARCHAR2 (30);
BEGIN
   b := TO_CHAR (123456789.01, 'L999G999G999D99');
   DBMS_OUTPUT.put_line (b);
END;
/

DECLARE
   b   VARCHAR2 (30);
   c   VARCHAR2 (30);
BEGIN
   b := TO_CHAR (123.01, 'LB000G000G009D99');
   DBMS_OUTPUT.put_line (b);

   c := TO_CHAR (0, 'LB000G000G009D99');
   DBMS_OUTPUT.put_line (c);
END;
/

DECLARE
   b   VARCHAR2 (30);
   c   VARCHAR2 (30);
BEGIN
   b := TO_CHAR (123.01, 'LB000G000G009D99');
   DBMS_OUTPUT.put_line (b);

   c := TO_CHAR (0, 'LB000G000G009D99');
   DBMS_OUTPUT.put_line (c);
END;
/

DECLARE
   b   VARCHAR2 (30);
BEGIN
   b := TO_CHAR (123.4567, '99.99');
   DBMS_OUTPUT.put_line (b);
END;
/

BEGIN
   DBMS_OUTPUT.put_line (TO_CHAR (123.4567, '999.99'));
   DBMS_OUTPUT.put_line (TO_CHAR (123.4567, '999'));
END;
/

DECLARE
   b   VARCHAR2 (30);
   c   VARCHAR2 (30);
BEGIN
   b := TO_CHAR (-123.4, '999.99');
   c := TO_CHAR (123.4, '999.99');
   DBMS_OUTPUT.put_line (':' || b || ' ' || TO_CHAR (LENGTH (b)));
   DBMS_OUTPUT.put_line (':' || c || ' ' || TO_CHAR (LENGTH (c)));
END;
/

DECLARE
   b   VARCHAR2 (30);
   c   VARCHAR2 (30);
BEGIN
   b := TO_CHAR (-123.4, 'TM9');
   c := TO_CHAR (123.4, 'TM9');
   DBMS_OUTPUT.put_line (':' || b || ' ' || TO_CHAR (LENGTH (b)));
   DBMS_OUTPUT.put_line (':' || c || ' ' || TO_CHAR (LENGTH (c)));
END;
/

DECLARE
   b   VARCHAR2 (30);
   c   VARCHAR2 (30);
BEGIN
   b := LTRIM (TO_CHAR (-123.4, '999.99'));
   c := LTRIM (TO_CHAR (123.4, '999.99'));
   DBMS_OUTPUT.put_line (':' || b || ' ' || TO_CHAR (LENGTH (b)));
   DBMS_OUTPUT.put_line (':' || c || ' ' || TO_CHAR (LENGTH (c)));
END;
/

BEGIN
   DBMS_OUTPUT.put_line (
      TO_CHAR (123456.78, '999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''')
   );
END;
/

DECLARE
   a    NUMBER := -123.45;
   a1   VARCHAR2 (30);
   b    VARCHAR2 (30) := '-123.45';
   b1   NUMBER;
   b2   BINARY_FLOAT;
   b3   BINARY_DOUBLE;
BEGIN
   a1 := CAST (a AS varchar2);
   b1 := CAST (b AS number);
   b2 := CAST (b AS binary_float);
   b3 := CAST (b AS binary_double);
   DBMS_OUTPUT.put_line (a1);
   DBMS_OUTPUT.put_line (b1);
   DBMS_OUTPUT.put_line (b2);
   DBMS_OUTPUT.put_line (b3);
END;
/

CREATE OR REPLACE FUNCTION is_odd (num_in IN NUMBER)
   RETURN BOOLEAN
IS
BEGIN
   RETURN MOD (num_in, 2) = 1;
END;
/

CREATE OR REPLACE FUNCTION is_even (num_in IN NUMBER)
   RETURN BOOLEAN
IS
BEGIN
   RETURN MOD (num_in, 2) = 0;
END;
/