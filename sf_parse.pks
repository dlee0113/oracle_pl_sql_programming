CREATE OR REPLACE PACKAGE sf_parse
IS
   TYPE item_tt IS TABLE OF VARCHAR2 ( 2000 )
      INDEX BY PLS_INTEGER;

   FUNCTION string_to_list (
      string_in IN VARCHAR2
    , delim_in IN VARCHAR2 := ','
   )
      RETURN item_tt;

   PROCEDURE show (
      string_in IN VARCHAR2
    , delim_in IN VARCHAR2 := ','
   );

   PROCEDURE show_variations;
END sf_parse;
/
