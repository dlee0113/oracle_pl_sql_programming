CREATE OR REPLACE PACKAGE valstd AUTHID CURRENT_USER
IS
   c_encap_std CONSTANT VARCHAR2(10) := 'TE_%';
   
   PROCEDURE progwith (str IN VARCHAR2);

   PROCEDURE exception_handling;

   PROCEDURE encap_compliance;
END valstd;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

