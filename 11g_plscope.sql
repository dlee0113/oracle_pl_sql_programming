ALTER SESSION SET plscope_settings='IDENTIFIERS:ALL'
/

CREATE OR REPLACE PACKAGE plscope_pkg
IS
   FUNCTION plscope_func (plscope_fp1 NUMBER)
      RETURN NUMBER;

   PROCEDURE plscope_proc (plscope_pp1 VARCHAR2);
END plscope_pkg;
/

CREATE OR REPLACE PROCEDURE plscope_proc1
IS
   plscope_var1   NUMBER := 0;
BEGIN
   plscope_pkg.plscope_proc (TO_CHAR (plscope_var1));
   DBMS_OUTPUT.put_line (SYSDATE);
   plscope_var1 := 1;
END plscope_proc1;
/

/* Verify PL/Scope setting. */

SELECT name, plscope_settings
  FROM user_plsql_object_settings
 WHERE name LIKE 'PLSCOPE%'
/

/* Output...

PLSCOPE_SETTINGS
-------------------
IDENTIFIERS:ALL

*/

/* Display all declarations */

  SELECT name, signature, TYPE
    FROM user_identifiers
   WHERE name LIKE 'PLSCOPE%' AND usage = 'DECLARATION'
ORDER BY object_type, usage_id
/

/* Output...

NAME            SIGNATURE                        TYPE
              
PLSCOPE_PKG     7DFBE4474A77569165B7DCB606761B81 PACKAGE           
PLSCOPE_FUNC    78168BCBE1511996C92DEA6FD93E0484 FUNCTION          
PLSCOPE_FP1     864F31A5B51B94097568688379D5959C FORMAL IN         
PLSCOPE_PROC    F51FC44CA81F59C6B428AB27C6415B2E PROCEDURE         
PLSCOPE_PP1     9124512252B0AB1320818EADAAD87162 FORMAL IN         
PLSCOPE_PROC1   4A24FD31BEA28212C696235F192E6CEE PROCEDURE         
PLSCOPE_VAR1    401F008A81C7DCF48AD7B2552BF4E684 VARIABLE 

*/

/* Find local variable declarations */

  SELECT a.name variable_name, b.name context_name, a.signature
    FROM user_identifiers a, user_identifiers b
   WHERE     a.usage_context_id = b.usage_id
         AND a.TYPE = 'VARIABLE'
         AND a.usage = 'DECLARATION'
         AND a.object_name = 'PLSCOPE_PROC1'
         AND a.object_name = b.object_name
ORDER BY a.object_type, a.usage_id
/

/* Output ...

VARIABLE_NAME   CONTEXT_NAME SIGNATURE
--------------- ------------ --------------------------------
A                F1          0F0D30D4BC6F7CC34D6BF73469DEF737
PR1              P1          AE40893577009279A269896AAD7B40F6

*/

/* Find all usages of local variable "plscope_var1" */

  SELECT usage, usage_id, object_name, object_type
    FROM user_identifiers sig
       , (SELECT a.signature
            FROM user_identifiers a, user_identifiers b
           WHERE     a.usage_context_id = b.usage_id
                 AND a.TYPE = 'VARIABLE'
                 AND a.usage = 'DECLARATION'
                 AND a.object_name = 'PLSCOPE_PROC1'
                 AND a.object_name = b.object_name) variables
   WHERE sig.signature = variables.signature
ORDER BY object_type, usage_id
/

/* Output....

USAGE       USAGE_ID   OBJECT_NAME                    OBJECT_TYPE
----------- ---------- ------------------------------ -------------
DECLARATION 3          PLSCOPE_PROC1                  PROCEDURE    
ASSIGNMENT  4          PLSCOPE_PROC1                  PROCEDURE    
REFERENCE   7          PLSCOPE_PROC1                  PROCEDURE    
ASSIGNMENT  9          PLSCOPE_PROC1                  PROCEDURE    


*/

/* From the declaration of "a", determine its type.
   NOTE: only useful if the STANDARD package has been
   compiled with IDENTIFIERS:ALL.
*/

SELECT a.name, a.TYPE
  FROM user_identifiers a
     , user_identifiers b
     , (SELECT a.signature
          FROM user_identifiers a, user_identifiers b
         WHERE     a.usage_context_id = b.usage_id
               AND a.TYPE = 'VARIABLE'
               AND a.usage = 'DECLARATION'
               AND a.object_name = 'PLSCOPE_PROC1'
               AND a.object_name = b.object_name) variables
 WHERE     a.usage = 'REFERENCE'
       AND a.usage_context_id = b.usage_id
       AND b.usage = 'DECLARATION'
       AND a.object_type = b.object_type
       AND a.object_name = b.object_name
       AND b.signature = variables.signature
/

ALTER SESSION SET plscope_settings='IDENTIFIERS:ALL'
/

CREATE OR REPLACE PACKAGE my_package
IS
   FUNCTION func (arg NUMBER)
      RETURN NUMBER;

   PROCEDURE proc (arg VARCHAR2);
END my_package;
/

CREATE OR REPLACE PROCEDURE use_proc
IS
BEGIN
   my_package.proc ('a');
END use_proc;
/

CREATE OR REPLACE PROCEDURE use_func
IS
BEGIN
   DBMS_OUTPUT.put_line (my_package.func (1));
END use_func;
/

SELECT called.object_name
  FROM user_identifiers called, user_identifiers declared
 WHERE     declared.usage = 'DECLARATION'
       AND declared.name = 'PROC'
       AND declared.object_name = 'MY_PACKAGE'
       AND called.usage = 'CALL'
       AND called.signature = declared.signature
       AND called.object_name <> 'MY_PACKAGE'
/