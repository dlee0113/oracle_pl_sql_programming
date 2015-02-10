CREATE OR REPLACE PACKAGE sf_config
IS
   /* "No error" error code */
   c_no_error                CONSTANT PLS_INTEGER := 0;
   /* User defined error code */
   c_user_error              CONSTANT PLS_INTEGER := 1;
   /* Other common errors, which need names */
   bulk_errors                        EXCEPTION;
   PRAGMA EXCEPTION_INIT (bulk_errors, -24381);
   /* Range of allowable user-defined error codes */
   c_min_user_code           CONSTANT PLS_INTEGER := -20000;
   c_max_user_code           CONSTANT PLS_INTEGER := -20999;

   -- Maximum size for VARCHAR2 in PL/SQL
   SUBTYPE maxvarchar2 IS VARCHAR2 (32767);

   -- Maximum size for VARCHAR2 in database
   SUBTYPE dbmaxvarchar2 IS VARCHAR2 (4000);

   -- Maximum size of Oracle identifier
   c_max_identifier_length   CONSTANT PLS_INTEGER := 30;

   SUBTYPE identifier_t IS VARCHAR2 (30);

   -- Maximum and minimum BINARY_ and PLS_INTEGER values
   c_max_pls_integer         CONSTANT PLS_INTEGER := POWER (2, 31) - 1;
   c_min_pls_integer         CONSTANT PLS_INTEGER := -1 * POWER (2, 31) + 1;
   -- Maximum number of columns in table
   c_max_columns             CONSTANT PLS_INTEGER := 1000;
END sf_config;
/