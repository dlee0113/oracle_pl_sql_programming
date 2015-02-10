CREATE OR REPLACE PROCEDURE make_colors_superset (first_colors IN Color_tab_t,
   second_colors IN Color_tab_t, superset OUT Color_tab_t)
AS
   working_colors Color_tab_t := Color_tab_t();
   element INTEGER := 1;
   which INTEGER;
BEGIN
   /* Invoke the EXTEND method to allocate enough storage
   || to the nested table working_colors.
   */
   working_colors.EXTEND (first_colors.COUNT + second_colors.COUNT);

   /* Loop through each of the input parameters, reading their
   || contents, and assigning each element to an element of
   || working_colors. Input collections may be sparse.
   */

   which := first_colors.FIRST;
   LOOP
      EXIT WHEN which IS NULL;
      working_colors(element) := first_colors(which);
      element := element + 1;
      which := first_colors.NEXT(which);
   END LOOP;

   which := second_colors.FIRST;
   LOOP
      EXIT WHEN which IS NULL;
      working_colors(element) := second_colors(which);
      element := element + 1;
      which := second_colors.NEXT(which);
   END LOOP;

   superset := working_colors;
END;
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
