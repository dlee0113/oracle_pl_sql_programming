/* Formatted on 2001/12/29 20:40 (Formatter Plus v4.5.2) */
CREATE OR REPLACE PACKAGE nicknames
IS
   french           CONSTANT PLS_INTEGER := 1005;
   american_english CONSTANT PLS_INTEGER := 1013;
   german           CONSTANT PLS_INTEGER := 2005;
   arabic           CONSTANT PLS_INTEGER := 3107;
   
   from_family       CONSTANT PLS_INTEGER := 88;
   from_friends      CONSTANT PLS_INTEGER := 99;
   from_colleagues   CONSTANT PLS_INTEGER := 111;

   TYPE strings_t IS TABLE OF VARCHAR2 (30)
      INDEX BY BINARY_INTEGER;

   TYPE nickname_set_t IS TABLE OF strings_t
      INDEX BY BINARY_INTEGER;

   TYPE multiple_sets_t IS TABLE OF nickname_set_t
      INDEX BY BINARY_INTEGER;

   FUNCTION to_french (nicknames_in IN nickname_set_t)
      RETURN nickname_set_t;

   FUNCTION to_german (nicknames_in IN nickname_set_t)
      RETURN nickname_set_t;

   FUNCTION to_arabic (nicknames_in IN nickname_set_t)
      RETURN nickname_set_t;
END nicknames;
/

CREATE OR REPLACE PACKAGE BODY nicknames
IS
   FUNCTION to_french (nicknames_in IN nickname_set_t)
      RETURN nickname_set_t
   IS
   BEGIN
      RETURN nicknames_in;
   END;

   FUNCTION to_german (nicknames_in IN nickname_set_t)
      RETURN nickname_set_t
   IS
   BEGIN
      RETURN nicknames_in;
   END;

   FUNCTION to_arabic (nicknames_in IN nickname_set_t)
      RETURN nickname_set_t
   IS
   BEGIN
      RETURN nicknames_in;
   END;
END nicknames;
/

create or replace procedure set_steven_nicknames
is
   steven_nicknames      nicknames.nickname_set_t;
   universal_nicknames   nicknames.multiple_sets_t;
BEGIN
   -- Without use of named constant:
   steven_nicknames (99) (1000) := 'Steve';
   
   -- With literals properly hidden:
   steven_nicknames (nicknames.from_colleagues) (2000) := 'Troublemaker';
   steven_nicknames (nicknames.from_colleagues) (3000) := 'All-around Great Guy';

   -- Translate to three other languages and put all
   -- translations in the universal nicknames collection.
   universal_nicknames (nicknames.american_english) := steven_nicknames;
   universal_nicknames (nicknames.french) := 
      nicknames.to_french (steven_nicknames);
   universal_nicknames (nicknames.german) := 
      nicknames.to_german (steven_nicknames);
   universal_nicknames (nicknames.arabic) := 
      nicknames.to_arabic (steven_nicknames);
      
   -- Apply collection methods
   DBMS_OUTPUT.PUT_LINE (steven_nicknames.COUNT);
   DBMS_OUTPUT.PUT_LINE (steven_nicknames (nicknames.from_colleagues).COUNT);
   DBMS_OUTPUT.PUT_LINE (universal_nicknames.COUNT);
   
   -- Triple-nested reference with named constants:
   DBMS_OUTPUT.PUT_LINE (
      universal_nicknames(nicknames.french)(nicknames.from_colleagues)(2000));
	  
   -- Triple-nested reference without named constants:
   DBMS_OUTPUT.PUT_LINE (
      universal_nicknames(1005)(111)(2000));	  
END;
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
