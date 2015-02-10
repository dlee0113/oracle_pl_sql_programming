/* File on web: 12c_bind_record.sql */
CREATE OR REPLACE PACKAGE rec_pkg AUTHID CURRENT_USER
AS
   TYPE rec_t IS RECORD (
      number1   NUMBER,
      number2   NUMBER
   );

   PROCEDURE set_rec (n1_in IN NUMBER, n2_in IN NUMBER, 
      rec_out OUT rec_t);
END rec_pkg;
/

SHO ERR

CREATE OR REPLACE PACKAGE BODY rec_pkg
AS
   PROCEDURE set_rec (n1_in IN NUMBER, n2_in IN NUMBER, 
      rec_out OUT rec_t)
   AS
   BEGIN
      rec_out.number1 := n1_in;
      rec_out.number2 := n2_in;
   END set_rec;
END rec_pkg;
/

SHO ERR

DECLARE
   l_record  rec_pkg.rec_t;
BEGIN
   EXECUTE IMMEDIATE 'BEGIN rec_pkg.set_rec (10, 20, :rec); END;' 
      USING OUT l_record;

   DBMS_OUTPUT.put_line ('number1 = ' || l_record.number1);
   DBMS_OUTPUT.put_line ('number2 = ' || l_record.number2);
END;
/