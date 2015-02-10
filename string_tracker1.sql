DECLARE
   l_myname   string_tracker.value_string_t := 'steven';
BEGIN
   string_tracker.clear_used_list;
   string_tracker.mark_as_used (l_myname);
   p.l (string_tracker.string_in_use ('george'));
   p.l (string_tracker.string_in_use (l_myname));
END;