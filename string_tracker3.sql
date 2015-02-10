DECLARE
   /* Create a constant with the list name to avoid multiple,
      hard-coded references. Notice the use of the subtype
      declared in the string_tracker package to declare the
      list name. */
   c_list_name   CONSTANT string_tracker.list_name_t  := 'outcomes';
BEGIN
   /* Create the list, wiping out anything that was there before. */
   string_tracker.create_list (list_name_in           => c_list_name
                             , case_sensitive_in      => FALSE
                             , overwrite_in           => TRUE
                              );
   string_tracker.mark_as_used (list_name_in         => c_list_name
                              , value_string_in      => 'abc'
                               );
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack ());
END;