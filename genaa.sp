CREATE OR REPLACE PROCEDURE genaa (
   tab_in        IN   VARCHAR2,
   sch_in        IN   VARCHAR2 := NULL,
   delim_in      IN   VARCHAR2 := '^',
   pkg_name_in   IN   VARCHAR2 := NULL,
   display_in    IN   BOOLEAN := FALSE ,
   file_in       IN   VARCHAR2 := NULL,
   dir_in        IN   VARCHAR2 := NULL
)
/* Assumptions:
- Table has a primary key consisting of a single integer value.
*/
IS 
   SUBTYPE identifier_t IS VARCHAR2 (100);

   v_tab          identifier_t := UPPER (tab_in);
   v_sch          identifier_t := NVL (UPPER (sch_in), USER);
   v_pkg_name     identifier_t := NVL (pkg_name_in, tab_in || '_cache');
   
   -- Moved out of parameter list; not implemented
   do_reload_in   BOOLEAN      := FALSE ;
   
   -- Send output to file or screen?
   v_to_screen    BOOLEAN      := file_in IS NULL;
   
   -- Array of output for package
   TYPE lines_t IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   output         lines_t;

   TYPE pky_rec IS RECORD (
      NAME          identifier_t,
      column_name   identifier_t,
      column_type   identifier_t,
      array_name    identifier_t
   );

   pky_info       pky_rec;

   TYPE cols_rec IS RECORD (
      NAME            identifier_t,
      TYPE            identifier_t,
      aa_index_type   identifier_t
   );

   TYPE cols_tt IS TABLE OF cols_rec
      INDEX BY BINARY_INTEGER;
	  
   -- Additional fields to avoid hard-coding and unnecessary overhead
   TYPE inds_rec IS RECORD (
      NAME           identifier_t,
      numcols        PLS_INTEGER,
      array_name     identifier_t,
      subtype_name   identifier_t,
      val_for_name   identifier_t,
      cols           cols_tt
   );

   TYPE inds_tt IS TABLE OF inds_rec
      INDEX BY /*BINARY_INTEGER; --*/ identifier_t;
   ucols          inds_tt;
   
   -- Now pl simply writes to the array.
   PROCEDURE pl (str IN VARCHAR2)
   IS
   BEGIN
      output (NVL (output.LAST, 0) + 1) := str;
   END;
   -- Dump to screen or file.
   PROCEDURE dump_output
   IS
   BEGIN
      IF v_to_screen
      THEN
         FOR indx IN output.FIRST .. output.LAST
         LOOP
            DBMS_OUTPUT.put_line (output (indx));
         END LOOP;
      ELSE
         -- Send output to the specified file.
         DECLARE
            fid   UTL_FILE.file_type;
         BEGIN
            fid := UTL_FILE.fopen (dir_in, file_in, 'W');

            FOR indx IN output.FIRST .. output.LAST
            LOOP
               UTL_FILE.put_line (fid, output (indx));
            END LOOP;

            UTL_FILE.fclose (fid);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line (
                  'Failure to write output to ' || dir_in || '/' || file_in
               );
               UTL_FILE.fclose (fid);
         END;
      END IF;
   END dump_output;

   PROCEDURE assert (condition_in IN BOOLEAN, msg_in IN VARCHAR2)
   IS
   BEGIN
      IF NOT condition_in OR condition_in IS NULL
      THEN
         DBMS_OUTPUT.put_line ('GENAA Error on ' || v_sch || '.' || v_tab || ': ');
         DBMS_OUTPUT.put_line (msg_in);
         raise_application_error (
            -20000,
            'GENAA Error on ' || v_sch || '.' || v_tab || ': ' || msg_in
         );
      END IF;
   END;

   FUNCTION primary_key_name (tab_in IN VARCHAR2, sch_in IN VARCHAR2)
      RETURN VARCHAR2
   IS 
      retval   identifier_t;
   BEGIN
      SELECT cons.constraint_name
        INTO retval
        FROM all_constraints cons
       WHERE cons.owner = sch_in
         AND cons.table_name = tab_in
         AND cons.constraint_type = 'P';

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;
   -- Create another function that retrieves all 
   -- column info for the specified index. 
   FUNCTION index_columns (
      tab_in   IN   VARCHAR2,
      sch_in   IN   VARCHAR2 := NULL,
      ind_in   IN   VARCHAR2
   )
      RETURN cols_tt
   IS 
      retval   cols_tt;
   BEGIN
      SELECT   i.column_name, t.data_type,
               DECODE (
                  t.data_type,
                  'INTEGER',
                  'PLS_INTEGER',
                  sch_in || '.' || tab_in || '.' || i.column_name || '%TYPE'
               )
          BULK COLLECT INTO retval
          FROM all_ind_columns i,
               (SELECT column_name, data_type
                  FROM all_tab_columns
                 WHERE table_name = tab_in AND owner = sch_in) t
         WHERE i.index_owner = sch_in
           AND i.table_name = tab_in
           AND i.table_owner = sch_in
           AND i.index_name = ind_in
           AND i.column_name = t.column_name
      ORDER BY column_position;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN retval;
   END;

   FUNCTION primary_key_columns (
      tab_in   IN   VARCHAR2,
      sch_in   IN   VARCHAR2,
      pky_in   IN   VARCHAR2
   )
      RETURN cols_tt
   IS
   BEGIN
      RETURN index_columns (tab_in, sch_in, pky_in);
   END;

   FUNCTION unique_index_columns (
      tab_in   IN   VARCHAR2,
      sch_in   IN   VARCHAR2,
      pky_in   IN   VARCHAR2
   )
      RETURN inds_tt
   IS 
      CURSOR uinds_cur
      IS
         SELECT index_name
           FROM all_indexes
          WHERE table_name = tab_in
            AND table_owner = sch_in
            AND uniqueness = 'UNIQUE'
            AND index_name != pky_in;

      retval   inds_tt;
   BEGIN
      FOR rec IN uinds_cur
      LOOP
         retval (rec.index_name).NAME := rec.index_name;
         retval (rec.index_name).array_name := rec.index_name || '_aa';
         retval (rec.index_name).subtype_name := rec.index_name || '_t';
         retval (rec.index_name).val_for_name := 'val_for_' || rec.index_name;
         retval (rec.index_name).cols :=
                               index_columns (tab_in, sch_in, rec.index_name);
         retval (rec.index_name).numcols := retval (rec.index_name).cols.COUNT;
      END LOOP;

      RETURN retval;
   END;

   PROCEDURE validate_and_initialize (
      pky_info_out   IN OUT   pky_rec,
      ucols_out      IN OUT   inds_tt
   )
   IS 
      indx      identifier_t;
      pkycols   cols_tt;
   BEGIN
      -- Set primary key information: just the first row of info!
      pky_info_out.NAME := primary_key_name (v_tab, v_sch);
      assert (
         pky_info_out.NAME IS NOT NULL,
         'No primary key available for table or table does not exist.'
      );
      pkycols := primary_key_columns (v_tab, v_sch, pky_info_out.NAME);
      pky_info_out.column_name := pkycols (pkycols.FIRST).NAME;
      pky_info_out.column_type := pkycols (pkycols.FIRST).TYPE;
      pky_info_out.array_name := pky_info_out.NAME || '_aa';
      -- Obtain unique index information.
      ucols_out := unique_index_columns (v_tab, v_sch, pky_info_out.NAME);

      IF display_in
      THEN
         pl ('Columns for primary key on ' || sch_in || '.' || tab_in);

         FOR indx IN 1 .. pkycols.COUNT
         LOOP
            pl (pkycols (indx).NAME || ' - ' || pkycols (indx).TYPE);
         END LOOP;

         pl ('');
         indx := ucols_out.FIRST;

         LOOP
            EXIT WHEN indx IS NULL;
            pl ('Columns for Index ' || indx);
            pl ('Number of columns in Index ' || ucols_out (indx).numcols);

            FOR cindx IN ucols_out (indx).cols.FIRST .. ucols_out (indx).cols.LAST
            LOOP
               pl (
                     ucols_out (indx).cols (cindx).NAME
                  || ' - '
                  || ucols_out (indx).cols (cindx).TYPE
               );
            END LOOP;

            indx := ucols_out.NEXT (indx);
         END LOOP;
      END IF;
   END;

   PROCEDURE gen_package_spec (
      tab_in        IN   VARCHAR2,
      sch_in        IN   VARCHAR2,
      pkg_in        IN   VARCHAR2,
      pky_info_in   IN   pky_rec,
      ucols_in      IN   inds_tt
   )
   IS 
      v_fulltab   identifier_t := v_sch || '.' || v_tab;

      PROCEDURE gen_declarations
      IS 
         indx   identifier_t := ucols_in.FIRST;
      BEGIN
           -- Declare a named type for each index that has more
         -- than one column.
         WHILE indx <= ucols_in.LAST
         LOOP
            IF ucols_in (indx).numcols > 1
            THEN
               pl (
                     'subtype '
                  || ucols_in (indx).subtype_name
                  || ' is varchar2(32767);'
               );
            END IF;

            indx := ucols_in.NEXT (indx);
         END LOOP;
      END;

      PROCEDURE gen_retrieval_function_headers
      IS 
         indx   identifier_t := ucols_in.FIRST;
      BEGIN
         -- Declare a function for each index and pkey
         pl (
               'function onerow ( '
            || pky_info_in.column_name
            || '_in IN '
            || v_fulltab
            || '.'
            || pky_info_in.column_name
            || '%TYPE) return '
            || v_fulltab
            || '%ROWTYPE;'
         );

         WHILE indx <= ucols_in.LAST
         LOOP
            -- Generic VARCHAR2-indexed tables...
            pl ('function onerow_by_' || ucols_in (indx).NAME || ' ( ');

            FOR cindx IN ucols_in (indx).cols.FIRST .. ucols_in (indx).cols.LAST
            LOOP
               pl (
                     ucols_in (indx).cols (cindx).NAME
                  || '_in IN '
                  || v_fulltab
                  || '.'
                  || ucols_in (indx).cols (cindx).NAME
                  || '%TYPE'
               );

               IF cindx < ucols_in (indx).cols.LAST
               THEN
                  pl (',');
               END IF;
            END LOOP;

            pl (') return ' || v_fulltab || '%ROWTYPE;');
            indx := ucols_in.NEXT (indx);
         END LOOP;
      END;

      PROCEDURE gen_reload_logic
      IS
      BEGIN
         IF do_reload_in
         THEN
            -- Include headers to load and set reload interval.
            pl ('procedure load_array;');
         END IF;
      END;

      PROCEDURE gen_test_program
      IS
      BEGIN
         pl ('procedure test;');
      END;
   BEGIN
      pl ('create or replace package ' || pkg_in || ' is ');
      gen_declarations;
      gen_retrieval_function_headers;
      gen_reload_logic;
      gen_test_program;
      pl ('end ' || pkg_in || ';');
      pl ('/');
   END;

   PROCEDURE gen_package_body (
      tab_in        IN   VARCHAR2,
      sch_in        IN   VARCHAR2,
      pkg_in        IN   VARCHAR2,
      pky_info_in   IN   pky_rec,
      ucols_in      IN   inds_tt
   )
   IS 
      v_fulltab   identifier_t := v_sch || '.' || v_tab;

      PROCEDURE gen_declarations
      IS 
         indx           identifier_t := ucols_in.FIRST;
         firstcolindx   PLS_INTEGER;
      BEGIN
         -- Global package variables
         IF do_reload_in
         THEN
            pl ('g_last_load DATE;');
            pl ('g_reload_interval INTERVAL DAY TO SECOND');
            pl (':= NULL; -- Auto reload turned off');
         END IF;

         -- Associative Array types and actual arrays
         -- First cached data based on primary key.
         pl (
               'TYPE '
            || tab_in
            || '_aat IS TABLE OF '
            || v_fulltab
            || '%ROWTYPE INDEX BY PLS_INTEGER;'
         );
         pl (pky_info_in.array_name || ' ' || tab_in || '_aat;');

         -- Now types and arrays for unique indexes.
         WHILE indx <= ucols_in.LAST
         LOOP
            IF ucols_in (indx).numcols = 1
            THEN
               firstcolindx := ucols_in (indx).cols.FIRST;
               pl (
                     'TYPE '
                  || ucols_in (indx).NAME
                  || '_aat IS TABLE OF '
                  || v_fulltab
                  || '.'
                  || pky_info_in.column_name
                  || '%TYPE INDEX BY '
                  || ucols_in (indx).cols (firstcolindx).aa_index_type
                  || ';'
               );
            ELSE
               pl (
                     'TYPE '
                  || ucols_in (indx).NAME
                  || '_aat IS TABLE OF '
                  || v_fulltab
                  || '.'
                  || pky_info_in.column_name
                  || '%TYPE INDEX BY '
                  || ucols_in (indx).subtype_name
                  || ';'
               );
            END IF;

            pl (
               ucols_in (indx).array_name || ' ' || ucols_in (indx).NAME || '_aat;'
            );
            indx := ucols_in.NEXT (indx);
         END LOOP;
      END;

      PROCEDURE gen_concat_functions
      IS 
         indx   identifier_t := ucols_in.FIRST;
      BEGIN
         -- Functions that return the concatenated value.
         WHILE indx <= ucols_in.LAST
         LOOP
            IF ucols_in (indx).numcols > 1
            THEN
               -- Generic VARCHAR2-indexed tables...
               pl ('function ' || ucols_in (indx).val_for_name || ' ( ');

               FOR cindx IN
                  ucols_in (indx).cols.FIRST .. ucols_in (indx).cols.LAST
               LOOP
                  pl (
                        ucols_in (indx).cols (cindx).NAME
                     || '_in IN '
                     || v_fulltab
                     || '.'
                     || ucols_in (indx).cols (cindx).NAME
                     || '%TYPE'
                  );

                  IF cindx < ucols_in (indx).cols.LAST
                  THEN
                     pl (',');
                  END IF;
               END LOOP;

               pl (') return ' || ucols_in (indx).subtype_name);
               pl ('is begin return (');

               FOR cindx IN ucols_in (indx).cols.FIRST .. ucols_in (indx).cols.LAST
               LOOP
                  pl (ucols_in (indx).cols (cindx).NAME || '_in');

                  IF cindx < ucols_in (indx).cols.LAST
                  THEN
                     pl (' || ');
                  END IF;
               END LOOP;

               pl ('); end ' || ucols_in (indx).val_for_name || ';');
            END IF;

            indx := ucols_in.NEXT (indx);
         END LOOP;
      END;

      FUNCTION rowval (
         ind_in      IN   inds_rec,
         prefix_in   IN   VARCHAR2,
         suffix_in   IN   VARCHAR2
      )
         RETURN VARCHAR2
      IS 
         retval   VARCHAR2 (32767);
      BEGIN
         -- If single column return that column name.
         -- If > 1 column, return call to function val_for
         --   for each of the input values.
         IF ind_in.numcols = 1
         THEN
            retval :=    prefix_in
                      || ind_in.cols (ind_in.cols.FIRST).NAME
                      || suffix_in;
         ELSE
            retval := ind_in.val_for_name || '(';

            FOR cindx IN 1 .. ind_in.cols.COUNT
            LOOP
               retval :=    retval
                         || prefix_in
                         || ind_in.cols (cindx).NAME
                         || suffix_in;

               IF cindx < ind_in.cols.LAST
               THEN
                  retval := retval || ',';
               END IF;
            END LOOP;

            retval := retval || ')';
         END IF;

         RETURN retval;
      END;

      PROCEDURE gen_retrieval_functions
      IS 
         indx   identifier_t := ucols_in.FIRST;
      BEGIN
          -- For the primary key, a function to return one row
         -- from the cached data array.
         NULL;
         -- For each unique index, a function to return one row
         -- using a separate associative array to locate the
         -- data in the primary key array.
         NULL;
         -- Declare a function for each index and pkey
         pl (
               'function onerow ( '
            || pky_info_in.column_name
            || '_in IN '
            || v_fulltab
            || '.'
            || pky_info_in.column_name
            || '%TYPE) return '
            || v_fulltab
            || '%ROWTYPE is begin return '
            || pky_info_in.array_name
            || ' ('
            || pky_info_in.column_name
            || '_in); end;'
         );

         WHILE indx <= ucols_in.LAST
         LOOP
            -- Generic VARCHAR2-indexed tables...
            pl ('function onerow_by_' || ucols_in (indx).NAME || ' ( ');

            FOR cindx IN ucols_in (indx).cols.FIRST .. ucols_in (indx).cols.LAST
            LOOP
               pl (
                     ucols_in (indx).cols (cindx).NAME
                  || '_in IN '
                  || v_fulltab
                  || '.'
                  || ucols_in (indx).cols (cindx).NAME
                  || '%TYPE'
               );

               IF cindx < ucols_in (indx).cols.LAST
               THEN
                  pl (',');
               END IF;
            END LOOP;

            pl (
                  ') return '
               || v_fulltab
               || '%ROWTYPE is begin return '
               || pky_info_in.array_name
               || ' ('
               || ucols_in (indx).NAME
               || '_aa ('
            );

            IF ucols_in (indx).numcols = 1
            THEN
               pl (
                     ucols_in (indx).cols (ucols_in (indx).cols.FIRST).NAME
                  || '_in'
               );
            ELSE
               pl (rowval (ucols_in (indx), NULL, '_in'));
            END IF;

            pl (')); end;');
            indx := ucols_in.NEXT (indx);
         END LOOP;
      END;

      PROCEDURE gen_reload_logic
      IS 
         indx   identifier_t := ucols_in.FIRST;
      BEGIN
         -- Procedure to load the arrays.
         pl ('procedure load_arrays is begin');
         pl ('FOR rec IN (SELECT * FROM ' || v_fulltab || ')');
         pl ('LOOP');
         pl (
               pky_info_in.array_name
            || '(rec.'
            || pky_info_in.column_name
            || ') := rec;'
         );

         WHILE indx <= ucols_in.LAST
         LOOP
            pl (
                  ucols_in (indx).array_name
               || '('
               || rowval (ucols_in (indx), 'rec.', NULL)
               || ') := rec.'
               || pky_info.column_name
               || ';'
            );
            indx := ucols_in.NEXT (indx);
         END LOOP;

         pl ('end loop;');

         IF do_reload_in
         THEN
            pl ('g_last_load := SYSDATE;');
         END IF;

         pl ('END load_arrays;');

         IF do_reload_in
         THEN
            -- Add logic to reload arrays after specified interval.
            NULL;
         END IF;
      END;

      PROCEDURE gen_test_program
      IS 
         indx   identifier_t := ucols_in.FIRST;
      BEGIN
         pl ('procedure test is');
         pl ('pky_rec ' || v_fulltab || '%ROWTYPE;');

         WHILE indx <= ucols_in.LAST
         LOOP
            pl (
               ucols_in (indx).array_name || '_rec ' || v_fulltab || '%ROWTYPE;'
            );
            indx := ucols_in.NEXT (indx);
         END LOOP;

         pl ('begin');
         pl ('for rec in (select * from ' || v_fulltab || ') loop');
         pl ('pky_rec := onerow (rec.' || pky_info_in.column_name || ');');
         indx := ucols_in.FIRST;

         WHILE indx <= ucols_in.LAST
         LOOP
            pl (
                  ucols_in (indx).array_name
               || '_rec := '
               || 'onerow_by_'
               || ucols_in (indx).NAME
               || ' ( '
            );

            FOR cindx IN ucols_in (indx).cols.FIRST .. ucols_in (indx).cols.LAST
            LOOP
               pl ('rec.' || ucols_in (indx).cols (cindx).NAME);

               IF cindx < ucols_in (indx).cols.LAST
               THEN
                  pl (',');
               END IF;
            END LOOP;

            pl (');');
            pl (
                  'if rec.'
               || pky_info_in.column_name
               || ' = '
               || ucols_in (indx).array_name
               || '_rec.'
               || pky_info_in.column_name
               || ' then'
            );
            pl (
                  'dbms_output.put_line ('''
               || ucols_in (indx).NAME
               || '  lookup OK'');'
            );
            pl ('else');
            pl (
                  'dbms_output.put_line ('''
               || ucols_in (indx).NAME
               || '  lookup NOT OK'');'
            );
            pl ('end if;');
            indx := ucols_in.NEXT (indx);
         END LOOP;

         pl ('end loop;');
         pl ('end test;');
      END;

      PROCEDURE gen_init_section
      IS
      BEGIN
         pl ('BEGIN load_arrays;');
      END;
   BEGIN
      pl ('create or replace package body ' || pkg_in || ' is ');
      gen_declarations;
      gen_concat_functions;
      gen_retrieval_functions;
      gen_reload_logic;
      gen_test_program;
      gen_init_section;
      pl ('end ' || pkg_in || ';');
      pl ('/');
      dump_output;
   END;
BEGIN
   validate_and_initialize (pky_info, ucols);
   gen_package_spec (v_tab, v_sch, v_pkg_name, pky_info, ucols);
   gen_package_body (v_tab, v_sch, v_pkg_name, pky_info, ucols);
END;


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
