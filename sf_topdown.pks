CREATE OR REPLACE PACKAGE sf_topdown
/*
| File name: topdown.pkg
|
| Overview: Help developers use top-down design to build highly
|    modular and very readable code.
|
| Author(s): Steven Feuerstein
|
| Modification History:
|   Date        Who           What
|   Sep 2007    SFeuerstein   Created in Bratislava after losing all
|                             changes on flight INTO Bratislava.
*/
IS
   c_default_error_code   CONSTANT PLS_INTEGER := -20999;

/*======= Code Refactoring Features =======*/

   /* The basic idea of TopDown is that you put "indicators" 
      in your program that will then be processed by the
      TopDown.Refactor program as described below.
      
   You place indicators in your program as follows:
   
   ** The string "--TOPDOWN.ISH" (insert stubs her) should be 
      placed at the end of the declaration section. This line
      will be replaced with stubs for all the calls to PPH and
      PFH (see below).
      
   ** Procedure call: In the executable section of code, where you want to 
      put in a call to a local procedure, write "TOPDOWN.PPH"
      (Put Procedure Here) and then pass a string that conforms to
      one of the following formats: 
      
      1. Just the procedure name

      topdown.pph ('PROGNAME');
      
      2. Procedure name and list of argument names; all will be 
         set to type VARCHAR2.

      topdown.pph ('PROGNAME|argname,....');

      3. Procedure name, plus list of arguments specifying both name
         and datatype of each argument.
         
      topdown.pph ('PROGNAME|argname:argtype,....');

      4. Procedure name, plus list of arguments specifying name
         and datatype of each argument, plus the value or expression
         that should be passed TO the procedure when it is called.
         
      topdown.pph ('PROGNAME|argname:argtype:argvalue,....');

   ** FUNCTION call: In the executable section of code, where you want to 
      put in a call to a local function, write "TOPDOWN.PFH"
      (Put Function Here) and then pass a string that conforms to
      one of the following formats: 
      
      1. Just the function name - the return type of the function will
         be set to VARCHAR2.
         
      topdown.pfh ('PROGNAME');

      2. Just the function name and the return type - this is the minimum

      topdown.pfh ('PROGNAME|RETURNTYPE');

      3. Function name, RETURN type, and list of argument names; all will be 
         set to type VARCHAR2.

      topdown.pfh ('PROGNAME|RETURNTYPE|argname,....');
      topdown.pfh ('PROGNAME|RETURNTYPE|argname:argtype,....');
      topdown.pfh ('PROGNAME|RETURNTYPE|argname:argtype:argvalue,....');

      where PROGNAME is the name of the program, RETURNTYPE is the 
      datatype of the function RETURN clause, argname is the name
      of the argument, argtype is the datatype of the argument, 
      and argvalue is the value that is passed to the program 
      when it is called.
      
   ** Restrictions and fine points:
   
      * The entire call to pfh and pph must be on one line, no matter how long.
      * You must use the specified delimiters above; no substitutions allowed.
      * Choose the appropriate from of the pfh program for your function call.
      * You can only refactor one set of TBC's at a time. That is, only one
        "ISH" tag in one declaration section. So if you want to create and
        generate stubs in more than one program, you must do so in multiple
        passes of editing and calls to TopDown.Refactor.
        
   ** Alternate format (where /+ and +/ are actually the normal block
      comment characters):
   
      /+PPH
      program_name
      return_type (if function)
      argument_name:argument_type[:argument_value]
      ...
      argument_name:argument_type[:argument_value]
      +/
      
      In other words, if you choose this format, you do so because the
      string is too long with the argument specifications, so you MUST
      have at least one argument and it MUST have the type as well as
      the name (I will use the presence of ":" to guide my parsing).
      
      AND you do NOT add a ; after the comment block for a procedure.
        
   */
   PROCEDURE pph (info_in IN VARCHAR2);

   FUNCTION pfh (info_in IN VARCHAR2)
      RETURN VARCHAR2;

   /* Refactor does all the work of finding the ish, pph and pfh
      calls and replacing them with code as described below:

      1. For each pph and pfh, load the information into an array.

      2. Find the ish program and replace that line with all
         the stubs specified in step 1.

      3. Replace each appearance of pph and pfh with calls to
         the programs as specified by the information.

      THEN you must finish up the declarations and, most importantly,
      the implementations of your programs!
   */
   PROCEDURE refactor (schema_name_in IN VARCHAR2, program_name_in IN VARCHAR2);

/*======= "To Be Completed" Features =======*/
   /*
   The following programs are used to indicate that a program is
   "to be completed", and to control the behavior of the tbc 
   indicator procedure, when it is run.
   
   By default, the TopDown.TBC will raise an exception, but you
   can have it simply display information to system output by
   calling the TopDown.tbc_show procedure.
   
   You can also adjust the error code used to stop processing
   (must be between -20000 and -20999).
   */
   
   /* To Be Completed */
   PROCEDURE tbc (program_name_in IN VARCHAR2);

   /* Raise error when tbc program is encountered */
   PROCEDURE tbc_raise;

   /* Do not raise, only show, when tbc is encountered. */
   PROCEDURE tbc_show;

   /* Set the error code raised by tbc. */
   PROCEDURE set_tbc_error_code (
      error_code_in IN PLS_INTEGER DEFAULT c_default_error_code
   );
END sf_topdown;
/