CREATE OR REPLACE PACKAGE &package_name
/*
/ Copyright Information Here
/
/ File name:
/
/ Overview:
/
/ Author(s):
/
/ Modification History:
/   Date        Who         What
/
STDHDR*/
IS
   /* Decide whether or not you want to expose the package
      initialization routine! */
   PROCEDURE initialize;
END &package_name;
/

CREATE OR REPLACE PACKAGE BODY &package_name
/*
/ Copyright Information Here
/
/ File name:
/
/ Overview:
/
/ Author(s):
/
/ Modification History:
/   Date        Who         What
/
*/
IS
   PROCEDURE initialize
   IS
   BEGIN
      NULL;
   END initialize;

   PROCEDURE proc
   /*
   / Copyright Information Here
   /
   / File name:
   /
   / Overview:
   /
   / Author(s):
   /
   / Modification History:
   /   Date        Who         What
   /
   */
   IS
      PROCEDURE initialize
      IS
      BEGIN
         /* Validate assumptions */
         assert.is_true (TRUE, 'msg');
         
         /* Initialize local variables */
         NULL;
      END initialize;

      PROCEDURE cleanup
      IS
      BEGIN
         NULL;
      END cleanup;
   BEGIN
      initialize;
      /* REMOVE AFTER REVIEW!
      
      Main body of program. Don't forget:
      
      ** Use BULK COLLECT and FORALL for multi-row SQL.
      ** Hide complex rules behind functions.
      ** Hide SQL statements behind a table API.
      ** Think about error handling now!
      ** Keep your executable sections small (< 50 lines).
      
      */
      cleanup;
   EXCEPTION
      WHEN OTHERS
      THEN
         /* Don't forget to clean up here, too! */
         cleanup;
         
         /* Use the standard error logging mechanism.
          
            Example: Quest Error Manager, available at:
            http://www.ToadWorld.com Downloads
         */
         q$error_manager.raise_error (
             error_code_in      => SQLCODE
            , name1_in           => 'NAME1'
            , value1_in          => 'VALUE'
            /* Up to five name-value pairs accepted! */
         );
   END proc;

   FUNCTION func
      RETURN datatype
   /*
   / Copyright Information Here
   /
   / File name:
   /
   / Overview:
   /
   / Author(s):
   /
   / Modification History:
   /   Date        Who         What
   /
   */
   IS
      /* The value returned by the function */
      l_return datatype;
      
      PROCEDURE initialize
      IS
      BEGIN
         /* Validate assumptions */
         assert.is_true (TRUE, 'msg');
         
         /* Initialize local variables */
         NULL;
      END initialize;

      PROCEDURE cleanup
      IS
      BEGIN
         NULL;
      END cleanup;
   BEGIN
      initialize;
      /* REMOVE AFTER REVIEW!
      
      Main body of program. Don't forget:
      
      ** Use BULK COLLECT and FORALL for multi-row SQL.
      ** Hide complex rules behind functions.
      ** Hide SQL statements behind a table API.
      ** Think about error handling now!
      ** Keep your executable sections small (< 50 lines).
      
      */
      cleanup;
      
      /* Just one return in the executable section! */
      RETURN l_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         /* Don't forget to clean up here, too! */
         cleanup;
         
         /* Use the standard error logging mechanism.
          
            Example: Quest Error Manager, available at:
            http://www.ToadWorld.com Downloads
         */
         q$error_manager.raise_error (
             error_code_in      => SQLCODE
            , name1_in           => 'NAME1'
            , value1_in          => 'VALUE'
            /* Up to five name-value pairs accepted! */
            );
   END func;
BEGIN
   initialize;
END &package_name;
/