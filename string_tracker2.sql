DECLARE
   c_list CONSTANT string_tracker.maxvarchar2_t := 'variables declared';
   l_myname string_tracker.maxvarchar2_t;
BEGIN
   string_tracker.CLEAR_LIST ( c_list );
   string_tracker.mark_as_used ( c_list, 'steven' );
   p.l ( string_tracker.string_in_use ( c_list, 'george' ));
   p.l ( string_tracker.string_in_use ( c_list, 'steven' ));
END;
