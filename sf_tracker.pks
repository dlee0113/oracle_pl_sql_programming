CREATE OR REPLACE PACKAGE sf_tracker
/*
Overview: sf_tracker allows you to keep track of whether a
certain name has already been used within a particular list.

Author: Steven Feuerstein

You are permitted to use this code in your own applications.

Requirements:
   * Oracle9i Database Release 2 and above

*/
IS
   -- Use more specific datatype names (Vienna 2006)
   SUBTYPE maxvarchar2_t IS VARCHAR2 (32767);

   -- Add subtypes in Vienna 2006
   SUBTYPE list_name_t IS maxvarchar2_t;

   SUBTYPE value_string_t IS maxvarchar2_t;

   PROCEDURE clear_all_lists;

   PROCEDURE CLEAR_LIST (list_name_in IN list_name_t);

   PROCEDURE create_list (
      list_name_in IN list_name_t
    , case_sensitive_in IN BOOLEAN DEFAULT FALSE
    , overwrite_in IN BOOLEAN DEFAULT TRUE
   );

   -- Is the string already in use?
   FUNCTION string_in_use (
      list_name_in IN list_name_t
    , value_string_in IN value_string_t
   )
      RETURN BOOLEAN;

   -- Mark this string as being used.
   PROCEDURE mark_as_used (
      list_name_in IN list_name_t
    , value_string_in IN value_string_t
   );
END sf_tracker;
/

