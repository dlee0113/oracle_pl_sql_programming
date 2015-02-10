CREATE OR REPLACE FUNCTION wordcount (str IN VARCHAR2)
   RETURN PLS_INTEGER
AS
   words PLS_INTEGER := 0;
   len PLS_INTEGER := NVL(LENGTH(str),0);
   inside_a_word BOOLEAN;
BEGIN
   FOR i IN 1..len + 1
   LOOP
      IF ASCII(SUBSTR(str, i, 1)) < 33 OR i > len
      THEN
         IF inside_a_word
         THEN
            words := words + 1;
            inside_a_word := FALSE;
         END IF;
      ELSE
         inside_a_word := TRUE;
      END IF;
   END LOOP;
   RETURN words;
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
