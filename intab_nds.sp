CREATE OR REPLACE PROCEDURE intab (
   table_in            IN   VARCHAR2
 , string_length_in    IN   INTEGER := 20
 , where_in            IN   VARCHAR2 := NULL
 , date_format_in      IN   VARCHAR2 := 'MM/DD/YY HHMISS'
 , collike_filter_in   IN   VARCHAR2 := '%'
 , colin_filter_in     IN   VARCHAR2 := NULL
 , trace_in            IN   BOOLEAN := FALSE
)
AUTHID CURRENT_USER
IS
   -- Use the cursor to establish the collection of records.
   -- A different cursor will be used for the bulk fetch,
   -- because an explicit cursor is not yet allowed (9iR2).
   CURSOR col_cur (owner_in IN VARCHAR2, table_in IN VARCHAR2)
   IS
      SELECT column_name, data_type, data_length, data_precision, data_scale
           , 1 column_width
        -- placeholder for column width
      FROM   all_tab_columns
       WHERE owner = owner_in AND table_name = table_in;

   TYPE col_tt IS TABLE OF col_cur%ROWTYPE
      INDEX BY BINARY_INTEGER;

   l_columns          col_tt;
   line_length        PLS_INTEGER := 0;
   no_columns_found   EXCEPTION;

   PROCEDURE pl (
      str         IN   VARCHAR2
    , len         IN   INTEGER := 255
    , expand_in   IN   BOOLEAN := TRUE
   )
   IS
      v_len   PLS_INTEGER     := LEAST (len, 255);
      v_str   VARCHAR2 (32767);
   BEGIN
      IF LENGTH (str) > v_len
      THEN
         v_str := SUBSTR (str, 1, v_len);
         DBMS_OUTPUT.put_line (v_str);
         pl (SUBSTR (str, len + 1), v_len, expand_in);
      ELSE
         v_str := str;
         DBMS_OUTPUT.put_line (v_str);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF expand_in
         THEN
            DBMS_OUTPUT.ENABLE (1000000);
            DBMS_OUTPUT.put_line (v_str);
         ELSE
            RAISE;
         END IF;
   END;

   PROCEDURE show_trace (title_in IN VARCHAR2, info_in IN VARCHAR2)
   IS
   BEGIN
      IF trace_in
      THEN
         pl (title_in || ': ' || info_in);
      END IF;
   END show_trace;

   FUNCTION ifelse (
      condition_in   IN   BOOLEAN
    , iftrue         IN   VARCHAR2
    , iffalse        IN   VARCHAR2
    , ifnull         IN   VARCHAR2 := NULL
   )
      RETURN VARCHAR2
   IS
   BEGIN
      IF condition_in
      THEN
         RETURN iftrue;
      ELSIF NOT condition_in
      THEN
         RETURN iffalse;
      ELSE
         RETURN ifnull;
      END IF;
   END;

   FUNCTION is_string (colrec_in IN col_cur%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (colrec_in.data_type IN ('CHAR', 'VARCHAR2', 'VARCHAR'));
   END;

   FUNCTION is_number (colrec_in IN col_cur%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (colrec_in.data_type IN ('FLOAT', 'INTEGER', 'NUMBER'));
   END;

   FUNCTION is_date (colrec_in IN col_cur%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (colrec_in.data_type = 'DATE');
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

   FUNCTION data_length (colrec_in IN col_cur%ROWTYPE)
      RETURN PLS_INTEGER
   IS
      retval   PLS_INTEGER;
   BEGIN
      IF is_string (colrec_in)
      THEN
         retval :=
            GREATEST (LEAST (colrec_in.data_length, string_length_in)
                    , LENGTH (colrec_in.column_name)
                     );
      ELSIF is_date (colrec_in)
      THEN
         retval :=
            GREATEST (LENGTH (date_format_in)
                    , LENGTH (colrec_in.column_name));
      ELSIF is_number (colrec_in)
      THEN
         retval :=
            GREATEST (NVL (colrec_in.data_precision, 38)
                    , LENGTH (colrec_in.column_name)
                     );
      END IF;

      RETURN retval;
   END;

   PROCEDURE retrieve_column_information (
      table_in     IN       VARCHAR2
    , length_out   OUT      PLS_INTEGER
   )
   IS
      owner_nm   VARCHAR2 (100)  := USER;
      table_nm   VARCHAR2 (100)  := UPPER (table_in);
      dot_loc    PLS_INTEGER;
      l_filter   VARCHAR2 (500)  := NULL;
      l_query    VARCHAR2 (1000);

      PROCEDURE create_col_filter
      IS
      BEGIN
         IF collike_filter_in = '%' AND colin_filter_in IS NULL
         THEN
            l_filter := NULL;
         ELSE
            l_filter :=
                      'AND (column_name like ''' || collike_filter_in || '''';

            IF colin_filter_in IS NOT NULL
            THEN
               l_filter :=
                     l_filter
                  || 'and column_name in ('''
                  || REPLACE (UPPER (colin_filter_in), ',', ''',''')
                  || ''')';
            END IF;

            l_filter := l_filter || ')';
         END IF;

         show_trace ('Column filter', l_filter);
      END create_col_filter;
   BEGIN
      dot_loc := INSTR (table_nm, '.');

      IF dot_loc > 0
      THEN
         owner_nm := SUBSTR (table_nm, 1, dot_loc - 1);
         table_nm := SUBSTR (table_nm, dot_loc + 1);
      END IF;

      create_col_filter;
      --
      l_query :=
            'SELECT column_name
            ,data_type
            ,data_length
            ,data_precision
            ,data_scale
            ,1 column_width -- placeholder for column width      
        FROM all_tab_columns
       WHERE owner = :owner_nm AND table_name = :table_nm '
         || l_filter;
      show_trace ('Query', l_query);

      EXECUTE IMMEDIATE l_query
      BULK COLLECT INTO l_columns
                  USING owner_nm, table_nm;

      IF l_columns.COUNT = 0
      THEN
         RAISE no_columns_found;
      END IF;

      length_out := 0;

      FOR indx IN l_columns.FIRST .. l_columns.LAST
      LOOP
         l_columns (indx).column_width := data_length (l_columns (indx));
         length_out := length_out + l_columns (indx).column_width + 1;
      END LOOP;
   EXCEPTION
      WHEN no_columns_found
      THEN
         pl ('No columns found for the following query:');
         pl (l_query);
         RAISE;
      WHEN OTHERS
      THEN
         pl ('intab/retrieve column info error: ');
         pl (SQLERRM);
         pl ('for the following query:');
         pl (l_query);
         RAISE;
   END retrieve_column_information;

   PROCEDURE display_header (length_in IN PLS_INTEGER)
   IS
      col_border   VARCHAR2 (32767) := RPAD ('-', length_in, '-');
      col_header   VARCHAR2 (32767);
   BEGIN
      FOR indx IN l_columns.FIRST .. l_columns.LAST
      LOOP
         col_header :=
               col_header
            || ifelse (indx = l_columns.FIRST, NULL, ' ')
            || RPAD (l_columns (indx).column_name
                   , l_columns (indx).column_width
                    );
      END LOOP;

      pl (col_border);
      pl (centered_string ('Contents of ' || table_in, length_in));
      pl (col_border);
      pl (col_header);
      pl (col_border);
   END;

   PROCEDURE generate_data
   IS
      l_block    VARCHAR2 (32767);
      col_list   VARCHAR2 (32767);

      FUNCTION query_string
         RETURN VARCHAR2
      IS
         FUNCTION where_clause
            RETURN VARCHAR2
         IS
            retval   VARCHAR2 (1000) := LTRIM (UPPER (where_in));
         BEGIN
            IF retval IS NOT NULL
            THEN
               IF (retval NOT LIKE 'GROUP BY%' AND retval NOT LIKE 'ORDER BY%'
                  )
               THEN
                  retval := 'WHERE ' || LTRIM (retval, 'WHERE');
               END IF;
            END IF;

            show_trace ('Where clause', retval);
            RETURN retval;
         END;
      BEGIN
         FOR indx IN l_columns.FIRST .. l_columns.LAST
         LOOP
            col_list :=
                  col_list
               || l_columns (indx).column_name
               || ' col'
               || indx
               || ifelse (indx = l_columns.LAST, NULL, ',');
            show_trace ('Column list', col_list);
         END LOOP;

         RETURN    'SELECT '
                || col_list
                || '  FROM '
                || table_in
                || ' '
                || where_clause;
      END query_string;

      FUNCTION concatenated_values
         RETURN VARCHAR2
      IS
         retval   VARCHAR2 (32767);

         FUNCTION one_value (value_in IN VARCHAR2, length_in IN PLS_INTEGER)
            RETURN VARCHAR2
         IS
         BEGIN
            RETURN 'RPAD (NVL (' || value_in || ', '' ''), ' || length_in
                   || ')' || CHR(10);
         END;
      BEGIN
         FOR col_ind IN l_columns.FIRST .. l_columns.LAST
         LOOP
            retval :=
                  retval
               || ifelse (col_ind = l_columns.FIRST, NULL, '|| '' '' || ')
               || CASE
                     WHEN is_string (l_columns (col_ind))
                        THEN one_value ('rec.col' || col_ind
                                      , l_columns (col_ind).column_width
                                       )
                     WHEN is_number (l_columns (col_ind))
                        THEN one_value ('TO_CHAR (rec.col' || col_ind || ')'
                                      , l_columns (col_ind).column_width
                                       )
                     WHEN is_date (l_columns (col_ind))
                        THEN one_value (   'TO_CHAR (rec.col'
                                        || col_ind
                                        || ', '''
                                        || date_format_in
                                        || ''')'
                                      , l_columns (col_ind).column_width
                                       )
                  END;
            show_trace ('Concatenated values', retval);
         END LOOP;

         RETURN retval;
      END concatenated_values;
   BEGIN                                -- Executable section of generate_data
      -- 7/2003 Ostermundigen
      -- Add pl to the dynamic block to avoid an
      -- external dependency.
    
      l_block :=
      'DECLARE 
         PROCEDURE pl (str IN VARCHAR2)
         IS
            v_len PLS_INTEGER := 255;
            v_str VARCHAR2 (255);
         BEGIN
           IF LENGTH (str) > v_len
           THEN
              v_str := SUBSTR (str, 1, v_len);
              DBMS_OUTPUT.put_line (v_str);
              pl (SUBSTR (str, v_len + 1));
           ELSE
              v_str := str;
             DBMS_OUTPUT.put_line (v_str);
           END IF;
         END pl;
       BEGIN
             FOR rec IN ('
         || query_string
         || ')
             LOOP
                pl ('
         || concatenated_values
         || ');
             END LOOP;
       END;';
      show_trace ('Dynamic block', l_block);

      EXECUTE IMMEDIATE l_block;
   EXCEPTION
      WHEN OTHERS
      THEN
         pl ('intab/data retrieval error: ');
         pl (SQLERRM);
         pl ('for the following block:');
         pl (l_block);
         RAISE;
   END;
/* MAIN intab */
BEGIN
   retrieve_column_information (table_in, line_length);
   display_header (line_length);
   generate_data;
EXCEPTION
   WHEN no_columns_found
   THEN
      pl ('Sorry, no table/columns found for specified query...');
END;
/
