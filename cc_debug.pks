CREATE OR REPLACE PACKAGE cc_debug
IS
   debug_active CONSTANT BOOLEAN := TRUE;
   trace_level CONSTANT PLS_INTEGER := 10;
END cc_debug;
/
