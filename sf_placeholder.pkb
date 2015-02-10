CREATE OR REPLACE PACKAGE BODY dyn_placeholder
IS
   FUNCTION only_identifier_from (
      string_in     IN   VARCHAR2
    , position_in   IN   PLS_INTEGER
   )
      RETURN VARCHAR2
   IS
      c_delimiters CONSTANT VARCHAR2 ( 100 )
         :=    '!@%^&*()-=+\|`~{[]};:''",<.>/? '
            || CHR ( 10 )
            || CHR ( 13 )
            || CHR ( 9 );
      l_end PLS_INTEGER;
   BEGIN
      l_end :=
         INSTR ( TRANSLATE ( string_in
                           , c_delimiters
                           , RPAD ( CHR ( 2 )
                                  , LENGTH ( c_delimiters )
                                  , CHR ( 2 )
                                  )
                           )
               , CHR ( 2 )
               , position_in
               );

      IF l_end = 0
      THEN
         RETURN SUBSTR ( string_in, position_in );
      ELSE
         RETURN SUBSTR ( string_in, position_in, l_end - position_in );
      END IF;
   END only_identifier_from;

   FUNCTION all_in_string (
      string_in      IN   VARCHAR2
    , dyn_plsql_in   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN placeholder_aat
   IS
      c_is_dynplsql CONSTANT BOOLEAN
                         := NVL ( dyn_plsql_in, SUBSTR ( string_in, -1 ) =
                                                                          ';' );
      l_start PLS_INTEGER := 1;
      l_loc PLS_INTEGER;
      l_placeholders placeholder_aat;

      PROCEDURE add_placeholder ( loc_in IN PLS_INTEGER )
      IS
         l_row PLS_INTEGER := l_placeholders.FIRST;
         c_last CONSTANT PLS_INTEGER := l_placeholders.LAST;
         l_name VARCHAR2 ( 32767 );
         l_already_used BOOLEAN := FALSE;
      BEGIN
         l_name := UPPER ( only_identifier_from ( string_in, loc_in + 1 ));

         IF c_is_dynplsql
         THEN
            WHILE ( NOT l_already_used AND l_row <= c_last )
            LOOP
               l_already_used := l_name = l_placeholders ( l_row ).NAME;
               l_row := l_row + 1;
            END LOOP;
         END IF;

         IF NOT l_already_used
         THEN
            l_row := l_placeholders.COUNT + 1;
            l_placeholders ( l_row ).NAME := l_name;
            l_placeholders ( l_row ).POSITION := loc_in;
         END IF;
      END add_placeholder;
   BEGIN
      LOOP
         l_loc := INSTR ( string_in, ':', l_start );
         EXIT WHEN l_loc = 0 OR l_loc IS NULL;

         IF SUBSTR ( string_in, l_loc + 1, 1 ) != '='
         THEN
            add_placeholder ( l_loc );
         END IF;

         l_start := l_loc + 1;
      END LOOP;

      RETURN l_placeholders;
   END all_in_string;

   FUNCTION count_in_string (
      string_in      IN   VARCHAR2
    , dyn_plsql_in   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN PLS_INTEGER
   IS
      l_placeholders placeholder_aat;
   BEGIN
      l_placeholders := all_in_string ( string_in , dyn_plsql_in);
      RETURN l_placeholders.COUNT;
   END count_in_string;

   FUNCTION nth_in_string (
      string_in      IN   VARCHAR2
    , nth_in         IN   PLS_INTEGER
    , dyn_plsql_in   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN placeholder_rt
   IS
      l_placeholders placeholder_aat;
   BEGIN
      l_placeholders := all_in_string ( string_in );

      IF nth_in > l_placeholders.COUNT
      THEN
         RETURN NULL;
      ELSE
         RETURN l_placeholders ( nth_in );
      END IF;
   END nth_in_string;

   PROCEDURE show_placeholders (
      list_in        IN   placeholder_aat
    , dyn_plsql_in   IN   BOOLEAN DEFAULT FALSE
   )
   IS
      l_index PLS_INTEGER := list_in.FIRST;
   BEGIN
      WHILE ( l_index IS NOT NULL )
      LOOP
         DBMS_OUTPUT.put_line (    list_in ( l_index ).NAME
                                || ' - '
                                || list_in ( l_index ).POSITION
                              );
         l_index := list_in.NEXT ( l_index );
      END LOOP;
   END show_placeholders;

   PROCEDURE show_placeholders (
      string_in      IN   VARCHAR2
    , dyn_plsql_in   IN   BOOLEAN DEFAULT FALSE
   )
   IS
   BEGIN
      show_placeholders ( all_in_string ( string_in, dyn_plsql_in ));
   END show_placeholders;

   FUNCTION eq (
      rec1_in       IN   placeholder_rt
    , rec2_in       IN   placeholder_rt
    , nullq_eq_in   IN   BOOLEAN DEFAULT TRUE
   )
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (     (    rec1_in.NAME = rec2_in.NAME
                     OR ( rec1_in.NAME IS NULL AND rec2_in.NAME IS NULL )
                   )
               AND (    rec1_in.POSITION = rec2_in.POSITION
                     OR ( rec1_in.POSITION IS NULL
                          AND rec2_in.POSITION IS NULL
                        )
                   )
             );
   END eq;
END dyn_placeholder;
/
