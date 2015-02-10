CREATE OR REPLACE PACKAGE BODY string_tracker
/*
Overview: String_tracker allows you to keep track of whether a
certain name has already been used within a particular list.
Author: Steven Feuerstein
You are permitted to use this code in your own applications.
Requirements:
   * Oracle9i Database Release 2 and above
*/
IS
   SUBTYPE who_cares_t IS BOOLEAN;
   
   TYPE used_aat
   IS
      TABLE OF who_cares_t
         INDEX BY value_string_t;

   TYPE list_rt
   IS
      RECORD ( description maxvarchar2_t, 
               list_of_values used_aat );

   TYPE list_of_lists_aat
   IS
      TABLE OF list_rt
         INDEX BY list_name_t;

   g_list_of_lists list_of_lists_aat;

   PROCEDURE clear_all_lists
   IS
   BEGIN
      g_list_of_lists.DELETE;
   END clear_all_lists;

   PROCEDURE CLEAR_LIST( list_name_in IN list_name_t )
   IS
   BEGIN
      g_list_of_lists.DELETE( list_name_in );
   END CLEAR_LIST;

   PROCEDURE create_list(
                          list_name_in IN list_name_t,
                          description_in IN maxvarchar2_t DEFAULT NULL ,
                          overwrite_in IN BOOLEAN DEFAULT TRUE
   )
   IS
      l_create_list BOOLEAN DEFAULT TRUE ;
      l_new_list list_rt;
   BEGIN
      IF g_list_of_lists.EXISTS( list_name_in )
      THEN
         l_create_list := overwrite_in;
      END IF;

      IF l_create_list
      THEN
         l_new_list.description := description_in;
         g_list_of_lists( list_name_in ) := l_new_list;
      END IF;
   END create_list;

   PROCEDURE mark_as_used(
                           list_name_in IN list_name_t,
                           value_string_in IN value_string_t
   )
   IS
   BEGIN
      g_list_of_lists( list_name_in ).list_of_values( value_string_in ) :=
         TRUE;
   END mark_as_used;

   FUNCTION string_in_use(
                           list_name_in IN list_name_t,
                           value_string_in IN value_string_t
   )
      RETURN BOOLEAN
   IS
   BEGIN
      IF g_list_of_lists.EXISTS (list_name_in)
      THEN
         RETURN g_list_of_lists (list_name_in).list_of_values.EXISTS
                                                             (value_string_in);
      ELSE
         RETURN FALSE;
      END IF;

      /* Des Moines IFMC May 2008 - do not rely on exception for failure
      RETURN g_list_of_lists(
                              list_name_in
             ).list_of_values.EXISTS( value_string_in );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;*/
   END string_in_use;
END string_tracker;
/
