CREATE OR REPLACE PROCEDURE show_all_arguments (program_in IN VARCHAR2)
IS
   dblink VARCHAR2 (100);
   part1_type NUMBER;
   object_number NUMBER;
   l_owner all_arguments.owner%TYPE;
   l_package_name all_arguments.owner%TYPE;
   l_object_name all_arguments.owner%TYPE;

   -- Individual "break outs" for an argument
   -- May be 1-1 with arguments_t if not a composite
   TYPE breakouts_t IS TABLE OF all_arguments%ROWTYPE
      INDEX BY /* level */ BINARY_INTEGER;

   -- Arguments for a single overloading

   TYPE arguments_t IS TABLE OF breakouts_t
      INDEX BY /* position */ BINARY_INTEGER;

   -- Overloadings for a single program name

   TYPE overloadings_t IS TABLE OF arguments_t
      INDEX BY /* overloading */ BINARY_INTEGER;

   -- All distinct programs in a package/program

   TYPE programs_t IS TABLE OF overloadings_t
      INDEX BY   /* program name */
      all_arguments.object_name%type;

   -- Dump of ALL_ARGUMENTS
   l_arguments breakouts_t;
   
   -- Multi-level instant sorting of ALL_ARGUMENTS data
   l_programs programs_t;

   PROCEDURE dump_arguments_array (have_rows IN BOOLEAN)
   IS
      FUNCTION strval (num IN INTEGER, padto IN INTEGER)
         RETURN VARCHAR2
      IS
      BEGIN
         RETURN    LPAD (NVL (TO_CHAR (num), 'N/A'), padto)
                || ' ';
      END;
   BEGIN
      IF have_rows
      THEN
         DBMS_OUTPUT.put_line (   'Dump of ALL_ARGUMENTS for "'
                               || program_in
                               || '"');
         DBMS_OUTPUT.put_line ('Object               OvLd Pos Lev Type            Name                               Mode  ');
         DBMS_OUTPUT.put_line ('-------------------- ---- --- --- --------------- --------------------------------- ------ ');

         FOR argrow IN l_arguments.FIRST .. l_arguments.LAST
         LOOP
            DBMS_OUTPUT.put_line (   RPAD (l_arguments (argrow).object_name
                                          ,20)
                                  || strval (l_arguments (argrow).overload
                                            ,4)
                                  || strval (l_arguments (argrow).POSITION
                                            ,4)
                                  || strval (l_arguments (argrow).data_level
                                            ,3)
                                  || RPAD (l_arguments (argrow).data_type
                                          ,15)
                                  || RPAD (NVL (l_arguments (argrow).argument_name
                                                  ,'RETURN Value')
                                          ,35)
                                  || RPAD (l_arguments (argrow).in_out
                                          ,6));
         END LOOP;
      END IF;
   END;

   PROCEDURE dump_programs_array (have_rows IN BOOLEAN)
   IS
      l_program all_arguments.object_name%TYPE;

      FUNCTION is_function (
         prog_in IN VARCHAR2
        ,ovld_in IN PLS_INTEGER
      )
         RETURN VARCHAR2
      IS
      BEGIN
         IF l_programs (prog_in) (ovld_in).EXISTS (0)
         THEN
            RETURN 'YES';
         ELSE
            RETURN 'NO';
         END IF;
      END;
   BEGIN
      IF have_rows
      THEN
         -- Let's do this in several passes.

         DBMS_OUTPUT.put_line ('');
         DBMS_OUTPUT.put_line (   'Dump of multi-level collections for "'
                               || program_in
                               || '"');
         DBMS_OUTPUT.put_line ('');
         DBMS_OUTPUT.put_line ('Distinct program names:');
         DBMS_OUTPUT.put_line ('');
         --
         -- First, the unique program names
         l_program := l_programs.FIRST;

         LOOP
            EXIT WHEN l_program IS NULL;
            DBMS_OUTPUT.put_line (   l_program
                                  || ' has '
                                  || l_programs (l_program).COUNT
                                  || ' overloadings.');
            l_program := l_programs.NEXT (l_program);
         END LOOP;

         --
         -- Now some interesting information I can
         -- easily extract from these collections
         DBMS_OUTPUT.put_line ('');
         DBMS_OUTPUT.put_line ('Information about distinct overloadings of programs:');
         DBMS_OUTPUT.put_line ('');
         DBMS_OUTPUT.put_line ('Overloading          Is Function? # Args');
         DBMS_OUTPUT.put_line ('-------------------- ------------ ------');
         l_program := l_programs.FIRST;

         LOOP
            EXIT WHEN l_program IS NULL;

            FOR indx IN
               l_programs (l_program).FIRST .. l_programs (l_program).LAST
            LOOP
               DBMS_OUTPUT.put_line (   LPAD (   l_program
                                              || '-'
                                              || indx
                                             ,20)
                                     || ' '
                                     || LPAD (is_function (l_program
                                                          ,indx)
                                             ,12)
                                     || ' '
                                     || LPAD (TO_CHAR (l_programs (l_program) (indx).COUNT)
                                             ,6));
            END LOOP;

            l_program := l_programs.NEXT (l_program);
         END LOOP;
      END IF;
   END;
BEGIN
   DBMS_UTILITY.name_resolve (program_in, 1, l_owner, l_package_name
                             ,l_object_name, dblink, part1_type
                             ,object_number);

   FOR rec IN (SELECT   *
                   FROM all_arguments
                  WHERE owner = l_owner
                    AND (   (    package_name = l_package_name
                             AND (   object_name = l_object_name
                                  OR l_object_name IS NULL
                                 )
                            )
                         OR (    package_name IS NULL
                             AND l_package_name IS NULL
                             AND object_name = l_object_name
                            )
                        )
               ORDER BY owner, package_name, object_name, overload)
   LOOP
      l_arguments (  NVL (l_arguments.LAST, 0)
                   + 1) := rec;

      l_programs
        (rec.object_name)
           (NVL (rec.overload, 0))
              (rec.position)
                 (rec.data_level) := rec; 
   END LOOP;

   -- Now everything is loaded, and in two different ways. 
   -- Let's examine the contents of the two tables to understand
   -- better how these collections work/are filled.

   dump_arguments_array (l_arguments.COUNT > 0);
   dump_programs_array (l_programs.COUNT > 0);
END;
/

