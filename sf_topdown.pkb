CREATE OR REPLACE PACKAGE BODY sf_topdown
/*
| File name: topdown.pkg
|
| Overview: Help developers use top-down design to build highly
|    modular and very readable code.
|
| Author(s): Steven Feuerstein
|
| Modification History:
|   Date        Who           What
|   Sep 2007    SFeuerstein   Created in Bratislava after losing all
|                             changes on flight INTO Bratislava.
*/
IS
   SUBTYPE bigstring_t IS VARCHAR2 (32767);

   TYPE bigstrings_t IS TABLE OF bigstring_t
      INDEX BY PLS_INTEGER;

   g_tbc_error_code   PLS_INTEGER := c_default_error_code;
   g_tbc_raise        BOOLEAN     DEFAULT TRUE;

/*=========== Utilities ===========*/
   FUNCTION string_to_list (string_in IN VARCHAR2, delim_in IN VARCHAR2
            := ',')
      RETURN bigstrings_t
   IS
      l_item       bigstring_t;
      l_loc        PLS_INTEGER;
      l_startloc   PLS_INTEGER  := 1;
      items_out    bigstrings_t;

      PROCEDURE add_item (item_in IN VARCHAR2)
      IS
      BEGIN
         IF (item_in != delim_in OR item_in IS NULL)
         THEN
            items_out (NVL (items_out.LAST, 0) + 1) := item_in;
         END IF;
      END;
   BEGIN
      IF string_in IS NOT NULL AND delim_in IS NOT NULL
      THEN
         LOOP
            -- Find next delimiter
            l_loc := INSTR (string_in, delim_in, l_startloc);

            IF l_loc = l_startloc                    -- Previous item is NULL
            THEN
               l_item := NULL;
            ELSIF l_loc = 0                     -- Rest of string is last item
            THEN
               l_item := SUBSTR (string_in, l_startloc);
            ELSE
               l_item := SUBSTR (string_in, l_startloc, l_loc - l_startloc);
            END IF;

            add_item (l_item);

            IF l_loc = 0
            THEN
               EXIT;
            ELSE
               l_startloc := l_loc + 1;
            END IF;
         END LOOP;
      END IF;

      RETURN items_out;
   END string_to_list;

   FUNCTION showing_tbc
      RETURN BOOLEAN
   IS
   BEGIN
      /* Always show the information, at least for now. */
      RETURN TRUE;
   END showing_tbc;

   FUNCTION raising_tbc
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_tbc_raise;
   END raising_tbc;

   PROCEDURE tbc (program_name_in IN VARCHAR2)
   IS
   BEGIN
      IF showing_tbc
      THEN
         DBMS_OUTPUT.put_line ('TO BE COMPLETED: "' || program_name_in || '"');
         DBMS_OUTPUT.put_line ('This program was called as follows:');
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_call_stack);
      END IF;

      IF raising_tbc
      THEN
         raise_application_error
              (g_tbc_error_code
             ,    'Program named "'
               || program_name_in
               || '" has not yet been implemented.'
               || ' Enable SERVEROUTPUT to see callstack for this program call.'
              );
      END IF;
   END tbc;

   /* Raise error when tbc program is encountered */
   PROCEDURE tbc_raise
   IS
   BEGIN
      g_tbc_raise := TRUE;
   END tbc_raise;

   /* Do not raise, only show, when tbc is encountered. */
   PROCEDURE tbc_show
   IS
   BEGIN
      g_tbc_raise := FALSE;
   END tbc_show;

   /* Set the error code raised by tbc. */
   PROCEDURE set_tbc_error_code (
      error_code_in IN PLS_INTEGER DEFAULT c_default_error_code
   )
   IS
   BEGIN
      g_tbc_error_code := error_code_in;
   END set_tbc_error_code;

/*======= Code Creation Features =======*/

   /* Oddly enough, none of these programs need an implementation.
      They are placeholders in the code. */
   PROCEDURE pph (info_in IN VARCHAR2)
   IS
   BEGIN
      NULL;
   END pph;

   FUNCTION pfh (info_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN NULL;
   END pfh;

   /* Refactor does all the work of finding the ish, pph and pfh
      calls and replacing them with code as described in the
      specification. */
   PROCEDURE refactor (schema_name_in IN VARCHAR2, program_name_in IN VARCHAR2)
   IS
      TYPE all_source_t IS TABLE OF all_source%ROWTYPE
         INDEX BY PLS_INTEGER;

      l_source            all_source_t;
      l_before_ish        DBMS_SQL.varchar2s;
      l_in_place_of_ish   DBMS_SQL.varchar2s;
      l_after_ish         DBMS_SQL.varchar2s;

      TYPE argument_rt IS RECORD (
         NAME    bigstring_t
       , TYPE    bigstring_t
       , VALUE   bigstring_t
      );

      TYPE argument_list_t IS TABLE OF argument_rt
         INDEX BY PLS_INTEGER;

      TYPE for_replacement_rt IS RECORD (
         start_line       PLS_INTEGER
       , start_location   PLS_INTEGER
       , end_line         PLS_INTEGER
       , end_location     PLS_INTEGER
       , program_name     bigstring_t
       , program_type     bigstring_t
       , return_type      bigstring_t
       , argument_list    argument_list_t
      );

      TYPE replacements_tt IS TABLE OF for_replacement_rt
         INDEX BY PLS_INTEGER;

      l_ish               for_replacement_rt;
      l_replacements      replacements_tt;

      PROCEDURE load_source_code
      IS
      BEGIN
         SELECT   *
         BULK COLLECT INTO l_source
             FROM all_source
            WHERE owner = schema_name_in
              AND NAME = program_name_in
              AND TYPE <> 'PACKAGE'
         ORDER BY line;

         /*
         Remove CR/LF at end of lines, and also remove leading
         and trailing blanks. Need to reformat anyway.
         */
         FOR indx IN 1 .. l_source.COUNT
         LOOP
            /* Bug fixed, now it is just noise
            q$error_manager.TRACE ('last character of ' || indx
                                 , ASCII (SUBSTR (l_source (indx).text, -1))
                                  );*/
            IF SUBSTR (l_source (indx).text, -1) = CHR (10)
            THEN
               l_source (indx).text :=
                  SUBSTR (l_source (indx).text
                        , 1
                        , LENGTH (l_source (indx).text) - 1
                         );
            END IF;

            l_source (indx).text := LTRIM (RTRIM (l_source (indx).text));
         END LOOP;
      END load_source_code;

      PROCEDURE load_arrays_for_pfh_pph
      IS
         l_index                   PLS_INTEGER  := l_source.FIRST;
         c_source_count   CONSTANT PLS_INTEGER  := l_source.COUNT;
         l_more_source             BOOLEAN      := c_source_count > 0;
         l_pipe_items              bigstrings_t;

         PROCEDURE mark_ish (index_inout IN PLS_INTEGER)
         IS
         BEGIN
            l_ish.start_location :=
                   INSTR (UPPER (l_source (index_inout).text), 'TOPDOWN.ISH');

            IF l_ish.start_location > 0
            THEN
               l_ish.start_line := l_source (index_inout).line;
            END IF;
         END mark_ish;

         PROCEDURE add_replacement (
            program_type_in IN VARCHAR2
          , marker_name_in IN VARCHAR2
          , index_inout IN OUT PLS_INTEGER
         )
         IS
            l_replacement   for_replacement_rt;
            l_marker1       PLS_INTEGER;
            l_marker2       PLS_INTEGER;
            l_info          VARCHAR2 (32767);

            PROCEDURE populate_arguments (
               arguments_in IN bigstring_t
             , replacement_inout IN OUT for_replacement_rt
            )
            IS
               l_arg_list   bigstrings_t;
               l_one_arg    bigstrings_t;
               l_index      PLS_INTEGER;
            BEGIN
               l_arg_list := string_to_list (arguments_in, ',');
               q$error_manager.TRACE ('populate_arguments argument count'
                                    , l_arg_list.COUNT
                                     );

               FOR indx IN 1 .. l_arg_list.COUNT
               LOOP
                  q$error_manager.TRACE ('populate_arguments argument '
                                         || indx
                                       , l_arg_list (indx)
                                        );
                  l_one_arg := string_to_list (l_arg_list (indx), ':');
                  l_index := replacement_inout.argument_list.COUNT + 1;

                  BEGIN
                     replacement_inout.argument_list (l_index).NAME :=
                                                                l_one_arg (1);
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;
                  END;

                  BEGIN
                     replacement_inout.argument_list (l_index).TYPE :=
                                                                l_one_arg (2);
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;
                  END;

                  BEGIN
                     replacement_inout.argument_list (l_index).VALUE :=
                                                                l_one_arg (3);
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;
                  END;
               END LOOP;
            END populate_arguments;

            PROCEDURE load_program_call (
               index_in IN PLS_INTEGER
             , replacement_out OUT for_replacement_rt
            )
            IS
               l_replacement   for_replacement_rt;
               l_arguments     bigstring_t;
            BEGIN
               l_replacement.start_location :=
                  INSTR (UPPER (l_source (index_inout).text)
                       , 'TOPDOWN.' || marker_name_in
                        );
               l_replacement.start_line := l_source (index_in).line;
               l_replacement.end_line := l_source (index_in).line;
               l_replacement.end_location :=
                  INSTR (l_source (index_in).text
                       , ')'
                       , l_replacement.start_location
                        );
               l_marker1 :=
                  INSTR (l_source (index_in).text
                       , ''''
                       , l_replacement.start_location
                        );
               l_marker2 :=
                         INSTR (l_source (index_in).text, '''', l_marker1 + 1);
               l_info :=
                  SUBSTR (l_source (index_in).text
                        , l_marker1 + 1
                        , l_marker2 - l_marker1 - 1
                         );
               q$error_manager.TRACE ('info string extracted', l_info);
               l_pipe_items := string_to_list (l_info, '|');
               l_replacement.program_name := l_pipe_items (1);
               l_replacement.program_type := program_type_in;

               BEGIN
                  IF program_type_in = 'FUNCTION'
                  THEN
                     l_replacement.return_type := l_pipe_items (2);
                     l_arguments := l_pipe_items (3);
                  ELSE
                     l_arguments := l_pipe_items (2);
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;

               l_replacement.return_type :=
                                   NVL (l_replacement.return_type, 'VARCHAR2');
               populate_arguments (l_arguments, l_replacement);
               replacement_out := l_replacement;
            END load_program_call;

            PROCEDURE load_comment_block (
               index_inout IN OUT PLS_INTEGER
             , replacement_out OUT for_replacement_rt
            )
            IS
               l_arguments   bigstring_t;
            BEGIN
               replacement_out.start_line := l_source (index_inout).line;
               replacement_out.start_location := 1;
               replacement_out.program_name :=
                                              l_source (index_inout + 1).text;
               replacement_out.program_type := program_type_in;

               IF program_type_in = 'FUNCTION'
               THEN
                  replacement_out.return_type :=
                                              l_source (index_inout + 2).text;
                  index_inout := index_inout + 3;
               ELSE
                  index_inout := index_inout + 2;
               END IF;

               /* Time to check for arguments.
                  Read ahead to the end block line. */
               WHILE (l_source (index_inout).text NOT LIKE '%*/%')
               LOOP
                  q$error_manager.TRACE ('argument ' || index_inout
                                       , l_source (index_inout).text
                                        );
                  l_arguments :=
                        l_arguments
                     || CASE
                           WHEN l_arguments IS NULL
                              THEN NULL
                           ELSE ','
                        END
                     || l_source (index_inout).text;
                  index_inout := index_inout + 1;
               END LOOP;

               q$error_manager.TRACE ('full list of arguments', l_arguments);
               populate_arguments (l_arguments, replacement_out);
               replacement_out.end_line := l_source (index_inout).line;
               replacement_out.end_location := NULL;         -- Not applicable
            END load_comment_block;
         BEGIN
            IF INSTR (UPPER (l_source (index_inout).text)
                    , 'TOPDOWN.' || marker_name_in
                     ) > 0
            THEN
               load_program_call (index_inout, l_replacement);
            /* Check for the alternate format. */
            ELSIF UPPER (l_source (index_inout).text) LIKE
                                                 '/*' || marker_name_in || '%'
            THEN
               load_comment_block (index_inout, l_replacement);
            END IF;

            IF l_replacement.start_line IS NOT NULL
            THEN
               q$error_manager.TRACE
                                ('adding replacement for program-returntype'
                               ,    l_replacement.program_name
                                 || '-'
                                 || l_replacement.return_type
                                );
               q$error_manager.TRACE
                                   ('> start_line-start_loc-end_line-end_loc'
                                  ,    l_replacement.start_line
                                    || '-'
                                    || l_replacement.start_location
                                    || '-'
                                    || l_replacement.end_line
                                    || '-'
                                    || l_replacement.end_location
                                   );
               l_replacements (l_replacements.COUNT + 1) := l_replacement;
            END IF;
         END add_replacement;
      BEGIN
         WHILE (l_index < c_source_count)
         LOOP
            /*Not needed
            q$error_manager.TRACE ('checking line ' || l_index
                                 , l_source (l_index).text
                                  );*/
            mark_ish (l_index);
            add_replacement ('PROCEDURE', 'PPH', l_index);
            add_replacement ('FUNCTION', 'PFH', l_index);
            l_index := l_index + 1;
         END LOOP;
      END load_arrays_for_pfh_pph;

      PROCEDURE transfer_source
      IS
      BEGIN
         q$error_manager.TRACE ('transfer_source ish start line'
                              , l_ish.start_line
                               );

         FOR indx IN 1 .. l_source.COUNT
         LOOP
            IF indx < l_ish.start_line
            THEN
               l_before_ish (indx) := l_source (indx).text;
            ELSIF indx > l_ish.start_line
            THEN
               l_after_ish (indx) := l_source (indx).text;
            END IF;
         END LOOP;
      END transfer_source;

      PROCEDURE replace_ish
      IS
         FUNCTION arg_list (arguments_in IN argument_list_t)
            RETURN VARCHAR2
         IS
            l_list   bigstring_t := '(';
         BEGIN
            IF arguments_in.COUNT = 0
            THEN
               RETURN NULL;
            ELSE
               FOR indx IN 1 .. arguments_in.COUNT
               LOOP
                  l_list :=
                        l_list
                     || CASE indx
                           WHEN 1
                              THEN NULL
                           ELSE ','
                        END
                     || arguments_in (indx).NAME
                     || ' IN '
                     || NVL (arguments_in (indx).TYPE, 'VARCHAR2');
               END LOOP;

               RETURN l_list || ')';
            END IF;
         END arg_list;
      BEGIN
         FOR indx IN 1 .. l_replacements.COUNT
         LOOP
            l_in_place_of_ish (l_in_place_of_ish.COUNT + 1) :=
                  l_replacements (indx).program_type
               || ' '
               || l_replacements (indx).program_name
               || arg_list (l_replacements (indx).argument_list)
               || CASE
                     WHEN l_replacements (indx).program_type = 'FUNCTION'
                        THEN ' RETURN ' || l_replacements (indx).return_type
                     ELSE NULL
                  END
               || ' IS BEGIN topdown.tbc ('''
               || l_replacements (indx).program_name
               || '''); '
               || CASE
                     WHEN l_replacements (indx).program_type = 'FUNCTION'
                        THEN 'RETURN NULL;'
                     ELSE NULL
                  END
               || ' END '
               || l_replacements (indx).program_name
               || ';';
         END LOOP;
      END replace_ish;

      PROCEDURE replace_pfh_pph
      IS
         FUNCTION arg_list (arguments_in IN argument_list_t)
            RETURN VARCHAR2
         IS
            l_list   bigstring_t := '(';
         BEGIN
            IF arguments_in.COUNT = 0
            THEN
               RETURN '()';
            ELSE
               FOR indx IN 1 .. arguments_in.COUNT
               LOOP
                  l_list :=
                        l_list
                     || CASE indx
                           WHEN 1
                              THEN NULL
                           ELSE ','
                        END
                     || arguments_in (indx).NAME
                     || ' => '
                     || NVL (arguments_in (indx).VALUE, 'NULL');
               END LOOP;

               RETURN l_list || ')';
            END IF;
         END arg_list;
      BEGIN
         FOR indx IN 1 .. l_replacements.COUNT
         LOOP
            IF l_replacements (indx).start_line =
                                               l_replacements (indx).end_line
            THEN
               /* Program call replacement */
               l_after_ish (l_replacements (indx).start_line) :=
                     SUBSTR (l_after_ish (l_replacements (indx).start_line)
                           , 1
                           , l_replacements (indx).start_location - 1
                            )
                  || l_replacements (indx).program_name
                  || arg_list (l_replacements (indx).argument_list)
                  || SUBSTR (l_after_ish (l_replacements (indx).start_line)
                           , l_replacements (indx).end_location + 1
                            );
            ELSE
               /* Comment block replacement. */
               l_after_ish.DELETE (l_replacements (indx).start_line
                                 , l_replacements (indx).end_line
                                  );
               l_after_ish (l_replacements (indx).start_line) :=
                     l_replacements (indx).program_name
                  || arg_list (l_replacements (indx).argument_list);

               IF l_replacements (indx).program_type = 'PROCEDURE'
               THEN
                  l_after_ish (l_replacements (indx).start_line) :=
                         l_after_ish (l_replacements (indx).start_line)
                         || ';';
               END IF;
            END IF;
         END LOOP;
      END replace_pfh_pph;

      PROCEDURE replace_source
      IS
         l_index        PLS_INTEGER;
         l_cur          PLS_INTEGER        := DBMS_SQL.open_cursor;
         l_dummy        PLS_INTEGER;
         l_new_source   DBMS_SQL.varchar2s;
      BEGIN
         /* Put the source pieces together. */
         l_new_source (1) := 'CREATE OR REPLACE ';
         --
         l_index := l_before_ish.FIRST;

         WHILE l_index IS NOT NULL
         LOOP
            l_new_source (l_new_source.COUNT + 1) := l_before_ish (l_index);
            l_index := l_before_ish.NEXT (l_index);
         END LOOP;

         --
         l_index := l_in_place_of_ish.FIRST;

         WHILE l_index IS NOT NULL
         LOOP
            l_new_source (l_new_source.COUNT + 1) :=
                                                  l_in_place_of_ish (l_index);
            l_index := l_in_place_of_ish.NEXT (l_index);
         END LOOP;

         --
         l_index := l_after_ish.FIRST;

         WHILE l_index IS NOT NULL
         LOOP
            l_new_source (l_new_source.COUNT + 1) := l_after_ish (l_index);
            l_index := l_after_ish.NEXT (l_index);
         END LOOP;

         DBMS_SQL.parse (l_cur
                       , l_new_source
                       , l_new_source.FIRST
                       , l_new_source.LAST
                       , TRUE
                       , DBMS_SQL.native
                        );
         l_dummy := DBMS_SQL.EXECUTE (l_cur);
         DBMS_SQL.close_cursor (l_cur);
      EXCEPTION
         WHEN OTHERS
         THEN
            FOR indx IN l_new_source.FIRST .. l_new_source.LAST
            LOOP
               DBMS_OUTPUT.put_line (l_new_source (indx));
            END LOOP;

            RAISE;
      END replace_source;
   BEGIN
      load_source_code;
      load_arrays_for_pfh_pph;
      transfer_source;
      replace_ish;
      replace_pfh_pph;
      replace_source;
   END refactor;
END sf_topdown;
/