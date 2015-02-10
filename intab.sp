CREATE OR REPLACE PROCEDURE intab (
   table_in           IN   VARCHAR2
 , string_length_in   IN   INTEGER := 20
 , where_in           IN   VARCHAR2 := NULL
 , date_format_in     IN   VARCHAR2 := 'MM/DD/YY HHMISS'
)
IS
   CURSOR col_cur (owner_in IN VARCHAR2, table_in IN VARCHAR2)
   IS
      SELECT column_name, data_type, data_length, data_precision, data_scale
        FROM all_tab_columns
       WHERE owner = owner_in AND table_name = table_in;

   TYPE string_tab IS TABLE OF VARCHAR2 (100)
      INDEX BY BINARY_INTEGER;

   TYPE integer_tab IS TABLE OF PLS_INTEGER
      INDEX BY BINARY_INTEGER;

   colname        string_tab;
   coltype        string_tab;
   collen         integer_tab;
   owner_nm       VARCHAR2 (100)  := USER;
   table_nm       VARCHAR2 (100)  := UPPER (table_in);
   where_clause   VARCHAR2 (1000) := LTRIM (UPPER (where_in));
   cur            INTEGER         := DBMS_SQL.open_cursor;
   fdbk           INTEGER         := 0;
   string_value   VARCHAR2 (2000);
   number_value   NUMBER;
   date_value     DATE;
   dot_loc        INTEGER;
   col_count      INTEGER         := 0;
   col_border     VARCHAR2 (2000);
   col_header     VARCHAR2 (2000);
   col_line       VARCHAR2 (2000);
   col_list       VARCHAR2 (2000);
   line_length    INTEGER         := 0;
   v_length       INTEGER;

   FUNCTION is_string (row_in IN INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (coltype (row_in) IN ('CHAR', 'VARCHAR2'));
   END;

   FUNCTION is_number (row_in IN INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (coltype (row_in) IN ('FLOAT', 'INTEGER', 'NUMBER'));
   END;

   FUNCTION is_date (row_in IN INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (coltype (row_in) = 'DATE');
   END;

   FUNCTION centered_string (string_in IN VARCHAR2, length_in IN INTEGER)
      RETURN VARCHAR2
   IS
      len_string   INTEGER := LENGTH (string_in);
   BEGIN
      IF len_string IS NULL OR length_in <= 0
      THEN
         RETURN NULL;
      ELSE
         RETURN    RPAD ('_', (length_in - len_string) / 2 - 1)
                || LTRIM (RTRIM (string_in));
      END IF;
   END;

   PROCEDURE initialize
   IS
   BEGIN
      dot_loc := INSTR (table_nm, '.');

      IF dot_loc > 0
      THEN
         owner_nm := SUBSTR (table_nm, 1, dot_loc - 1);
         table_nm := SUBSTR (table_nm, dot_loc + 1);
      END IF;
   END initialize;

   PROCEDURE load_column_information
   IS
   BEGIN
      FOR col_rec IN col_cur (owner_nm, table_nm)
      LOOP
         col_list := col_list || ', ' || col_rec.column_name;
         /* Save datatype and length for define column calls. */
         col_count := col_count + 1;
         colname (col_count) := col_rec.column_name;
         coltype (col_count) := col_rec.data_type;

         IF is_string (col_count)
         THEN
            v_length :=
               GREATEST (LEAST (col_rec.data_length, string_length_in)
                       , LENGTH (col_rec.column_name)
                        );
         ELSIF is_date (col_count)
         THEN
            v_length :=
               GREATEST (LENGTH (date_format_in)
                       , LENGTH (col_rec.column_name)
                        );
         ELSIF is_number (col_count)
         THEN
            v_length :=
               GREATEST (NVL (col_rec.data_precision, 38)
                       , LENGTH (col_rec.column_name)
                        );
         END IF;

         collen (col_count) := v_length;
         line_length := line_length + v_length + 1;
         /* Construct column header line. */
         col_header :=
                     col_header || ' ' || RPAD (col_rec.column_name, v_length);
      END LOOP;

      col_list := RTRIM (LTRIM (col_list, ', '), ', ');
      col_header := LTRIM (col_header);
      col_border := RPAD ('-', line_length, '-');
   END load_column_information;

   PROCEDURE construct_and_parse_query
   IS
   BEGIN
      IF where_clause IS NOT NULL
      THEN
         IF (    where_clause NOT LIKE 'GROUP BY%'
             AND where_clause NOT LIKE 'ORDER BY%'
            )
         THEN
            where_clause := 'WHERE ' || LTRIM (where_clause, 'WHERE');
         END IF;
      END IF;

      DBMS_SQL.parse (cur
                    ,    'SELECT '
                      || col_list
                      || '  FROM '
                      || table_in
                      || ' '
                      || where_clause
                    , DBMS_SQL.native
                     );
   END construct_and_parse_query;

   PROCEDURE define_columns_and_execute
   IS
   BEGIN
      FOR col_ind IN 1 .. col_count
      LOOP
         IF is_string (col_ind)
         THEN
            DBMS_SQL.define_column (cur
                                  , col_ind
                                  , string_value
                                  , collen (col_ind)
                                   );
         ELSIF is_number (col_ind)
         THEN
            DBMS_SQL.define_column (cur, col_ind, number_value);
         ELSIF is_date (col_ind)
         THEN
            DBMS_SQL.define_column (cur, col_ind, date_value);
         END IF;
      END LOOP;

      fdbk := DBMS_SQL.EXECUTE (cur);
   END define_columns_and_execute;

   PROCEDURE build_and_display_output
   IS
   BEGIN
      LOOP
         fdbk := DBMS_SQL.fetch_rows (cur);
         EXIT WHEN fdbk = 0;

         IF DBMS_SQL.last_row_count = 1
         THEN
            p.l (col_border);
            p.l (centered_string ('Contents of ' || table_in, line_length));
            p.l (col_border);
            p.l (col_header);
            p.l (col_border);
         END IF;

         col_line := NULL;

         FOR col_ind IN 1 .. col_count
         LOOP
            IF is_string (col_ind)
            THEN
               DBMS_SQL.column_value (cur, col_ind, string_value);
            ELSIF is_number (col_ind)
            THEN
               DBMS_SQL.column_value (cur, col_ind, number_value);
               string_value := TO_CHAR (number_value);
            ELSIF is_date (col_ind)
            THEN
               DBMS_SQL.column_value (cur, col_ind, date_value);
               string_value := TO_CHAR (date_value, date_format_in);
            END IF;

            col_line :=
                  col_line
               || ' '
               || RPAD (NVL (string_value, ' '), collen (col_ind));
         END LOOP;

         p.l (col_line);
      END LOOP;
   END build_and_display_output;
BEGIN
   initialize;
   --
   load_column_information;
   construct_and_parse_query;
   define_columns_and_execute;
   build_and_display_output;
   --
   DBMS_SQL.close_cursor (cur);
EXCEPTION
   WHEN OTHERS
   THEN
      p.l ('Error displaying contents of ' || table_in);
      p.l (DBMS_UTILITY.FORMAT_ERROR_STACK);
      DBMS_SQL.close_cursor (cur);
END;
/