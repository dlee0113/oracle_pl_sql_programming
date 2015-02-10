-- _____________________________________________________________________
-- |                                                                    |
-- |                Recompile Utility                                   |
-- |____________________________________________________________________|
--
-- FILE:    recompile.sql
-- LOCATION:
-- TITLE:   Recompile Utility
-- TYPE:    ORACLE PL/SQL Stored Function
-- VERSION: 2.0
-- CREATED: August 3, 1998
-- AUTHOR:  Solomon Yakobson
-- WARNING:
-- SCOPE:   Recompile  Utility can  be  used for  Oracle 7.3.x  and
--      Oracle 8.0.x object compilation.
--
-- MODIFICATION
-- HISTORY: September 9, 1998 - fixed obj_cursor to include objects
--                  with no dependencies.
--
--      May 12, 1999      - fix for DBMS_SQL behavior change in
--                  Oracle 8 (most likely it is a bug).
--                  If object recompilation has errors,
--                  ORACLE 8 DBMS_SQL raises exception:
--                  ORA-24333: success with compilation
--                  error, followed by host environment
--                  (e.g. SQL*Plus) internal  error and
--                  Unsafe to proceed message.
--
--      May 12, 1999      - added COMPILE_ERRORS return code.
--
--      May 12, 1999      - added TYPE and TYPE BODY objects.
--
--      January 15, 2009  - exclude RECYCLEBIN objects.
--
--
-- DESCRIPTION: Recompile Utility is designed  to compile the following
--      types of objects:
--
--        PROCEDURE (ORACLE 7 && 8),
--        FUNCTION (ORACLE 7 && 8),
--        PACKAGE - specification and body (ORACLE 7 && 8),
--        PACKAGE BODY - body only (ORACLE 7 && 8),
--        TRIGGER (ORACLE 7 && 8),
--        VIEW (ORACLE 7 && 8),
--        TYPE - specification only (ORACLE 8),
--        TYPE BODY - body only (ORACLE 8).
--
--      Objects are recompiled based on object dependencies and
--      therefore compiling  all requested objects in one path.
--      Recompile Utility skips every object which is either of
--      unsupported object type or depends on INVALID object(s)
--      outside of current request (which means we know upfront
--      compilation will fail anyway).  If object recompilation
--      is not successful, Recompile Utility continues with the
--      next object. Recompile Utility has five parameters:
--
--        o_owner  - IN  mode  parameter is a VARCHAR2 defining
--               owner  of to  be  recompiled  objects.  It
--               accepts operator LIKE widcards.  Backslash
--               (\)  is used  for escaping  wildcards.  If
--               omitted, parameter defaults to USER.
--        o_name   - IN  mode  parameter is a VARCHAR2 defining
--               names  of to  be  recompiled  objects.  It
--               accepts operator LIKE widcards.  Backslash
--               (\)  is used  for escaping  wildcards.  If
--               omitted, it defaults to '%' - any name.
--        o_type   - IN  mode  parameter is a VARCHAR2 defining
--               types  of to  be  recompiled  objects.  It
--               accepts operator LIKE widcards.  Backslash
--               (\)  is used  for escaping  wildcards.  If
--               omitted, it defaults to '%' - any type.
--        o_status - IN  mode  parameter is a VARCHAR2 defining
--               status of to  be  recompiled  objects.  It
--               accepts operator LIKE widcards.  Backslash
--               (\)  is used  for escaping  wildcards.  If
--               omitted, it defaults  to 'INVALID'.
--        display  - IN  mode parameter is a  BOOLEAN  defining
--               whether object recompile status is written
--               to  DBMS_OUTPUT  buffer.  If  omitted,  it
--               defaults to TRUE.
--
--      Recompile Utility returns the following values or their
--      combinations:
--
--        0 - Success. All requested objects are recompiled and
--            are VALID.
--        1 - INVALID_TYPE. At least one  of to  be  recompiled
--            objects is not of supported object type.
--        2 - INVALID_PARENT. At  least one of to be recompiled
--            objects depends on an  invalid object outside  of
--            current request.
--        4 - COMPILE_ERRORS. At  least one of to be recompiled
--            objects was compiled with errors and is INVALID.
--
--      If parameter  display is set to TRUE, Recompile Utility
--      writes the following information to DBMS_OUTPUT buffer:
--
--              RECOMPILING OBJECTS
--
--              Object Owner is  o_owner
--              Object Name is   o_name
--              Object Type is   o_type
--              Object Status is o_status
--
--      TTT OOO.NNN is recompiled. Object status is SSS.
--      TTT OOO.NNN references  invalid object(s) outside of
--      this request.
--      OOO.NNN is TTT and can not be recompiled.
--
--      where  o_owner  is  parameter  o_owner value, o_name is
--      parameter  o_name value,  o_type  is  parameter  o_type
--      value and o_status is is parameter o_status  value. TTT
--      is object type, OOO is object owner, NNN is object name
--      and SSS is object status after compilation.
--
-- NOTES:   If  parameter  display is set to TRUE, you  MUST ensure
--      DBMS_OUTPUT buffer is large enough for produced output.
--      Otherwise Recompile Utility will not recompile all  the
--      objects. If used in SQL*Plus, issue:
--
--          SET SERVEROUTPUT ON SIZE xxx FORMAT WRAPPED
--
--      FORMAT WRAPPED is needed for text alignment.
-- ______________________________________________________________________
--

CREATE OR REPLACE FUNCTION sf_recompile (o_owner IN VARCHAR2:= USER
                                       , o_name IN VARCHAR2:= '%'
                                       , o_type IN VARCHAR2:= '%'
                                       , o_status IN VARCHAR2:= 'INVALID'
                                       , display IN BOOLEAN:= TRUE
                                        )
   RETURN NUMBER
   AUTHID CURRENT_USER
IS
   -- Exceptions

   successwithcompilationerror exception;
   PRAGMA EXCEPTION_INIT (successwithcompilationerror, -24344);

   -- Return Codes

   invalid_type       CONSTANT INTEGER := 1;
   invalid_parent     CONSTANT INTEGER := 2;
   compile_errors     CONSTANT INTEGER := 4;

   cnt                NUMBER;
   dyncur             INTEGER;
   type_status        INTEGER := 0;
   parent_status      INTEGER := 0;
   recompile_status   INTEGER := 0;
   object_status      VARCHAR2 (30);

   CURSOR invalid_parent_cursor (
      oowner        VARCHAR2
    , oname         VARCHAR2
    , otype         VARCHAR2
    , ostatus       VARCHAR2
    , oid           NUMBER
   )
   IS
      SELECT                                                       /*+ RULE */
            o.object_id
        FROM public_dependency d, dba_objects o
       WHERE     d.object_id = oid
             AND o.object_id = d.referenced_object_id
             AND o.status != 'VALID'
      MINUS
      SELECT                                                       /*+ RULE */
            object_id
        FROM dba_objects
       WHERE     owner LIKE UPPER (oowner)
             AND object_name LIKE UPPER (oname)
             AND object_type LIKE UPPER (otype)
             AND status LIKE UPPER (ostatus);

   CURSOR recompile_cursor (
      oid NUMBER
   )
   IS
      SELECT                                                       /*+ RULE */
            'ALTER '
             || DECODE (object_type,
                        'PACKAGE BODY', 'PACKAGE',
                        'TYPE BODY', 'TYPE',
                        object_type
                       )
             || ' '
             || owner
             || '.'
             || object_name
             || ' COMPILE '
             || DECODE (object_type,
                        'PACKAGE BODY', ' BODY',
                        'TYPE BODY', 'BODY',
                        'TYPE', 'SPECIFICATION',
                        ''
                       )
                stmt
           , object_type
           , owner
           , object_name
        FROM dba_objects
       WHERE object_id = oid;

   recompile_record   recompile_cursor%ROWTYPE;

   CURSOR obj_cursor (
      oowner        VARCHAR2
    , oname         VARCHAR2
    , otype         VARCHAR2
    , ostatus       VARCHAR2
   )
   IS
          SELECT                                                   /*+ RULE */
                MAX (LEVEL) dlevel, object_id
            FROM sys.public_dependency
      START WITH object_id IN
                       (SELECT object_id
                          FROM dba_objects
                         WHERE     owner LIKE UPPER (oowner)
                               AND object_name LIKE UPPER (oname)
                               AND object_type LIKE UPPER (otype)
                               AND status LIKE UPPER (ostatus)
                        -- Added by Steve Goucher, 15/Jan/2008.  Exclude objects in the RECYCLEBIN.
                        MINUS
                        SELECT                                     /*+ RULE */
                              purge_object
                          FROM recyclebin)
      CONNECT BY object_id = PRIOR referenced_object_id
        GROUP BY object_id
          HAVING MIN (LEVEL) = 1
      UNION ALL
      SELECT 1 dlevel, object_id
        FROM dba_objects o
       WHERE     owner LIKE UPPER (oowner)
             AND object_name LIKE UPPER (oname)
             AND object_type LIKE UPPER (otype)
             AND status LIKE UPPER (ostatus)
             AND NOT EXISTS (SELECT 1
                               FROM sys.public_dependency d
                              WHERE d.object_id = o.object_id)
      ORDER BY 1 DESC;

   CURSOR status_cursor (oid NUMBER)
   IS
      SELECT                                                       /*+ RULE */
            status
        FROM dba_objects
       WHERE object_id = oid;
BEGIN
   -- Recompile requested objects based on their dependency levels.

   IF display
   THEN
      DBMS_OUTPUT.put_line (CHR (0));
      DBMS_OUTPUT.put_line ('                            RECOMPILING OBJECTS'
                           );
      DBMS_OUTPUT.put_line (CHR (0));
      DBMS_OUTPUT.put_line (
         '                            Object Owner is  ' || o_owner
      );
      DBMS_OUTPUT.put_line (
         '                            Object Name is   ' || o_name
      );
      DBMS_OUTPUT.put_line (
         '                            Object Type is   ' || o_type
      );
      DBMS_OUTPUT.put_line (
         '                            Object Status is ' || o_status
      );
      DBMS_OUTPUT.put_line (CHR (0));
   END IF;

   dyncur := DBMS_SQL.open_cursor;

   FOR obj_record IN obj_cursor (o_owner, o_name, o_type, o_status)
   LOOP
      OPEN recompile_cursor (obj_record.object_id);

      FETCH recompile_cursor INTO recompile_record;

      CLOSE recompile_cursor;

      -- We can recompile only Functions, Packages, Package Bodies,
      -- Procedures, Triggers, Views, Types and Type Bodies.

      IF recompile_record.object_type IN
               ('FUNCTION'
              , 'PACKAGE'
              , 'PACKAGE BODY'
              , 'PROCEDURE'
              , 'TRIGGER'
              , 'VIEW'
              , 'TYPE'
              , 'TYPE BODY')
      THEN
         -- There is no sense to recompile an object that depends on
         -- invalid objects outside of the current recompile request.

         OPEN invalid_parent_cursor (o_owner
                                   , o_name
                                   , o_type
                                   , o_status
                                   , obj_record.object_id);

         FETCH invalid_parent_cursor INTO cnt;

         IF invalid_parent_cursor%NOTFOUND
         THEN
            -- Recompile object.

            BEGIN
               DBMS_SQL.parse (dyncur
                             , recompile_record.stmt
                             , DBMS_SQL.native
                              );
            EXCEPTION
               WHEN successwithcompilationerror
               THEN
                  NULL;
            END;

            OPEN status_cursor (obj_record.object_id);

            FETCH status_cursor INTO object_status;

            CLOSE status_cursor;

            IF display
            THEN
               DBMS_OUTPUT.put_line(   recompile_record.object_type
                                    || ' '
                                    || recompile_record.owner
                                    || '.'
                                    || recompile_record.object_name
                                    || ' is recompiled. Object status is '
                                    || object_status
                                    || '.');
            END IF;

            IF object_status <> 'VALID'
            THEN
               recompile_status := compile_errors;
            END IF;
         ELSE
            IF display
            THEN
               DBMS_OUTPUT.put_line(   recompile_record.object_type
                                    || ' '
                                    || recompile_record.owner
                                    || '.'
                                    || recompile_record.object_name
                                    || ' references invalid object(s)'
                                    || ' outside of this request.');
            END IF;

            parent_status := invalid_parent;
         END IF;

         CLOSE invalid_parent_cursor;
      ELSE
         IF display
         THEN
            DBMS_OUTPUT.put_line(   recompile_record.owner
                                 || '.'
                                 || recompile_record.object_name
                                 || ' is a '
                                 || recompile_record.object_type
                                 || ' and can not be recompiled.');
         END IF;

         type_status := invalid_type;
      END IF;
   END LOOP;

   DBMS_SQL.close_cursor (dyncur);
   RETURN type_status + parent_status + recompile_status;
EXCEPTION
   WHEN OTHERS
   THEN
      IF obj_cursor%ISOPEN
      THEN
         CLOSE obj_cursor;
      END IF;

      IF recompile_cursor%ISOPEN
      THEN
         CLOSE recompile_cursor;
      END IF;

      IF invalid_parent_cursor%ISOPEN
      THEN
         CLOSE invalid_parent_cursor;
      END IF;

      IF status_cursor%ISOPEN
      THEN
         CLOSE status_cursor;
      END IF;

      IF DBMS_SQL.is_open (dyncur)
      THEN
         DBMS_SQL.close_cursor (dyncur);
      END IF;

      RAISE;
END sf_recompile;
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/