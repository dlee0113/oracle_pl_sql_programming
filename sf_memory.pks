CREATE OR REPLACE PACKAGE sf_memory
/*
Overview: Calculate and show UGA and PGA memory consumption
          by the current session.

Author: Steven Feuerstein

Dependencies:

    SELECT privileges required on:
       SYS.v_$sesstat
       SYS.v_$statname

    Here are the statements you should run:

    GRANT SELECT ON SYS.v_$sesstat TO schema;
    GRANT SELECT ON SYS.v_$statname TO schema;
*/
IS
   PROCEDURE reset_analysis;

   PROCEDURE start_analysis;

   PROCEDURE show_memory_usage;
END sf_memory;
/

