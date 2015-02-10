CREATE OR REPLACE PACKAGE dyn_placeholder
/*
Dynamic PL/SQL Placeholder Analyzer Package

Author: Steven Feuerstein, steven@stevenfeuerstein.com
Created: December 20, 2005

Overview: Helps you analyze strings for placeholders, which is defined as the
colon character ":" followed by anything but =.

Most programs have a parameter named dyn_plsql_in. If your string is part of
a dynamic PL/SQL block, you should pass TRUE for this argument. If you pass
NULL and the string ends with a semi-colon, then I will assume it is a
dynamic PL/SQL block. Why bother with this? In a dynamic SQL block, you need
to provide a bind variable for each placeholder, even if there are multiple
with the same name. In a dynamic PL/SQL block, you only provide a value for
the first occurrence of each placeholder (by name).

Note: these programs do not take into account : characters that occur
within a comment or within a literal.
*/
IS
   /* Return two pieces of information about each placeholder:
      1. The name (without the colon) upper-cased.
      2. The location in the string (starting with the colon)
   */
   TYPE placeholder_rt IS RECORD (
      name VARCHAR2 ( 100 )
    , POSITION PLS_INTEGER
   );

   -- Associative array type to hold information about all placeholders.
   TYPE placeholder_aat IS TABLE OF placeholder_rt
      INDEX BY PLS_INTEGER;

   -- Return the number of placeholders found in the string.
   FUNCTION count_in_string (
      string_in      IN   VARCHAR2
    , dyn_plsql_in   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN PLS_INTEGER DETERMINISTIC;

   -- Return the nth placeholder in the string.
   FUNCTION nth_in_string (
      string_in      IN   VARCHAR2
    , nth_in         IN   PLS_INTEGER
    , dyn_plsql_in   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN placeholder_rt DETERMINISTIC;

   -- Return all the placeholders in an associative array.
   FUNCTION all_in_string (
      string_in      IN   VARCHAR2
    , dyn_plsql_in   IN   BOOLEAN DEFAULT FALSE
   )
      RETURN placeholder_aat DETERMINISTIC;

   -- Display all the placeholders.
   PROCEDURE show_placeholders (
      list_in        IN   placeholder_aat
    , dyn_plsql_in   IN   BOOLEAN DEFAULT FALSE
   );

   PROCEDURE show_placeholders (
      string_in      IN   VARCHAR2
    , dyn_plsql_in   IN   BOOLEAN DEFAULT FALSE
   );

   FUNCTION eq (
      rec1_in       IN   placeholder_rt
    , rec2_in       IN   placeholder_rt
    , nullq_eq_in   IN   BOOLEAN DEFAULT TRUE
   )
      RETURN BOOLEAN DETERMINISTIC;
END dyn_placeholder;
/
