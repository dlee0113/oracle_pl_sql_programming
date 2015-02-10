CREATE OR REPLACE PACKAGE public_pkg
IS
   PROCEDURE do_only_this;
END;
/

CREATE OR REPLACE PACKAGE private_pkg   
   ACCESSIBLE BY (public_pkg)
IS
   PROCEDURE do_this;

   PROCEDURE do_that;
END;
/

SHO ERR

CREATE OR REPLACE PACKAGE BODY public_pkg
IS
   PROCEDURE do_only_this
   IS
   BEGIN
      private_pkg.do_this;
      private_pkg.do_that;
   END;
END;
/

SHO ERR

CREATE OR REPLACE PACKAGE BODY private_pkg
IS
   PROCEDURE do_this
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('THIS');
   END;

   PROCEDURE do_that
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('THAT');
   END;
END;
/

SHO ERR

/* Authorized use */

BEGIN
   public_pkg.do_only_this;
END;
/

/* Unauthorized use 

ERROR at line 2:
ORA-06550: line 2, column 1:
PLS-00904: insufficient privilege to access object PRIVATE_PKG
ORA-06550: line 2, column 1:
PL/SQL: Statement ignored

*/

BEGIN
   private_pkg.do_this;
END;
/
