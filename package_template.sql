CREATE OR REPLACE PACKAGE BODY <package_name>
IS
   -- Place private data structures below.
   -- Avoid assigning default values here.
   -- Instead, assign in the initialization procedure and
   --   verify success in the verification program.
  
   -- Place private programs here.
  
   -- Initialization section (optional)
   PROCEDURE initialize IS
   BEGIN
      NULL;
   END initialize;
  
   PROCEDURE verify_initialization (optional)
   -- Use this program to verify the state of the package.
   -- Were default values assigned properly? Were all
   -- necessary steps performed?
   IS
   BEGIN
      NULL;
   END verify_initialization;
  
   -- Place public programs here.
  
BEGIN
   initialize;
   verify_initialization;
END <package_name>;
/
