CREATE OR REPLACE PACKAGE valstd AUTHID CURRENT_USER
IS
   c_encap_std CONSTANT VARCHAR2(10) := 'TE_%';
   
   PROCEDURE progwith (str IN VARCHAR2);

   PROCEDURE exception_handling;

   PROCEDURE encap_compliance;
END valstd;
/
