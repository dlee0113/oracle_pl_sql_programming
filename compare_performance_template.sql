CREATE OR REPLACE PROCEDURE compare_implementations (
   title_in     IN   VARCHAR2
 , iterations_in   IN   INTEGER
/*
And now any parameters you need to pass data to the
programs you are comparing....
*/
)
IS
BEGIN
   DBMS_OUTPUT.put_line ('Compare Performance of <CHANGE THIS>: ');
   DBMS_OUTPUT.put_line (title_in);
   DBMS_OUTPUT.put_line ('Each program execute ' || iterations_in || ' times.');
   /*
   For each implementation, start the timer, run the program N times,
   then show elapsed time. 
   */
   sf_timer.start_timer;

   FOR indx IN 1 .. iterations_in
   LOOP
      /* Call your program here. */
      NULL;
   END LOOP;

   sf_timer.show_elapsed_time ('<CHANGE THIS: Implementation 1');
   --
   sf_timer.start_timer;

   FOR indx IN 1 .. iterations_in
   LOOP
      /* Call your program here. */
      NULL;
   END LOOP;

   sf_timer.show_elapsed_time ('<CHANGE THIS: Implementation 2');
   DBMS_OUTPUT.put_line ('....');
END compare_implementations;
/