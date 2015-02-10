CREATE OR REPLACE PACKAGE static_pkg
IS
   c_integer   CONSTANT PLS_INTEGER   := 100;
   c_name1     CONSTANT VARCHAR2 (100)
                                 := 'STEVEN';
   c_name2     CONSTANT VARCHAR2 (100)
                                     := USER;
   c_date      CONSTANT DATE
                 := ADD_MONTHS (SYSDATE, 10);
END static_pkg;
/
CREATE OR REPLACE PROCEDURE check_static
IS
BEGIN
$IF static_pkg.c_integer > 1
$THEN
   DBMS_OUTPUT.PUT_LINE ('OK'); 
$END
   NULL;
END check_static;
/
CREATE OR REPLACE PROCEDURE check_static
IS
BEGIN
$IF static_pkg.c_name1 = 'JOE'
$THEN
   DBMS_OUTPUT.PUT_LINE ('OK'); 
$END
   NULL;
END check_static;
/
CREATE OR REPLACE PROCEDURE check_static
IS
BEGIN
$IF static_pkg.c_name2 = 'JOE'
$THEN
   DBMS_OUTPUT.PUT_LINE ('OK'); 
$END
   NULL;
END check_static;
/
CREATE OR REPLACE PROCEDURE check_static
IS
BEGIN
$IF static_pkg.c_date > SYSDATE
$THEN
   DBMS_OUTPUT.PUT_LINE ('OK'); 
$END
   NULL;
END check_static;
/
