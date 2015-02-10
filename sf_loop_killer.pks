CREATE OR REPLACE PACKAGE sf_loop_killer
/*
| File name: sf_loop_killer.pkg
|
| Overview: Simple API to make it easier to insert code inside a loop
|           to check for infinite or out of control loops and kill
|           them after N iterations.
|
|           Raise the infinite_loop_detected exception.
|
|           Default "kill after": 1000 iterations
|
| Author(s): Steven Feuerstein
|
| Modification History:
|   Date          Who         What
|   23-AUG-2007   SF          Created package
*/
IS
   c_max_iterations   CONSTANT PLS_INTEGER DEFAULT 1000;
   e_infinite_loop_detected    EXCEPTION;
   c_infinite_loop_detected    CONSTANT PLS_INTEGER := -20999;
   PRAGMA EXCEPTION_INIT (e_infinite_loop_detected, -20999);

   PROCEDURE kill_after (max_iterations_in IN PLS_INTEGER);

   PROCEDURE increment_or_kill (by_in IN PLS_INTEGER DEFAULT 1);

   FUNCTION current_count
      RETURN PLS_INTEGER;
END sf_loop_killer;
/

