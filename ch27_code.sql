/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 27

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

SELECT COUNT ( * )
  FROM all_objects
 WHERE object_type LIKE 'JAVA%'
/

    /* Must be connected as a dba */

BEGIN
   DBMS_JAVA.grant_permission (grantee => 'BATCH'
                             , permission_type => 'java.io.FilePermission'
                             , permission_name => '/apps/OE/lastorder.log'
                             , permission_action => 'read,write'
                              );
END;
/

BEGIN
   /* First, grant read and write to everyone */
   DBMS_JAVA.grant_permission ('PUBLIC'
                             , 'java.io.FilePermission'
                             , '/shared/*'
                             , 'read,write'
                              );

   /* Use the "restrict" built-in to revoke read & write
   |  permission on one particular file from everyone
   */
   DBMS_JAVA.restrict_permission ('PUBLIC'
                                , 'java.io.FilePermission'
                                , '/shared/secretfile'
                                , 'read,write'
                                 );

   /* Now override the restriction so that one user can read and write
   |  that file.
   */
   DBMS_JAVA.grant_permission ('BOB'
                             , 'java.io.FilePermission'
                             , '/shared/secretfile'
                             , 'read,write'
                              );

   COMMIT;
END;
/

CREATE OR REPLACE FUNCTION fdelete (file IN VARCHAR2)
   RETURN NUMBER
AS
   LANGUAGE JAVA
   NAME 'JDelete.delete (
                java.lang.String)
                return int';
/

CREATE OR REPLACE PACKAGE nat_health_care
IS
   PROCEDURE consolidate_insurer (ins insurer)
   AS
      LANGUAGE JAVA
      NAME 'NHC_consolidation.process(oracle.sql.STRUCT)';
END nat_health_care;
/

CREATE OR REPLACE TYPE pet_t AS OBJECT
   (name VARCHAR2 (100)
  , MEMBER FUNCTION date_of_birth (NAME_IN IN VARCHAR2)
       RETURN DATE
    AS
       LANGUAGE JAVA
       NAME 'petInfo.dob (java.lang.String)
                 return java.sql.Timestamp'
   );
/

CREATE OR REPLACE PROCEDURE read_out_file (file_name IN     VARCHAR2
                                         , file_line    OUT VARCHAR2
                                          )
AS
   LANGUAGE JAVA
   NAME 'utils.ReadFile.read(java.lang.String
                             ,java.lang.String[])';
/

CREATE OR REPLACE PROCEDURE dropany (tp IN VARCHAR2, nm IN VARCHAR2)
AS
   LANGUAGE JAVA
   NAME 'DropAny.object (
                java.lang.String,
                java.lang.String)';
/

DECLARE
   tempdir   dirlist_t;
BEGIN
   tempdir := dirlist ('C:\temp');

   FOR i IN 1 .. tempdir.COUNT
   LOOP
      DBMS_OUTPUT.put_line (tempdir (i));
   END LOOP;
END;
/