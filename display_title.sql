CREATE OR REPLACE PROCEDURE display_title (title_in IN VARCHAR2)
IS
BEGIN
   DBMS_OUTPUT.put_line (RPAD ('=', 80, '='));
   DBMS_OUTPUT.put_line (title_in);
   DBMS_OUTPUT.put_line (RPAD ('=', 80, '='));
END;
/

DECLARE
   happy_title CONSTANT VARCHAR2(30)    := 'HAPPY BIRTHDAY';
   changing_title VARCHAR2(30) := 'Happy Anniversary';
   spc CONSTANT VARCHAR2(1) := CHR(32); -- ASCII code for a single space;
BEGIN
   display_title ('Happy Birthday');             -- a literal
   display_title (happy_title);                  -- a constant

   changing_title := happy_title;
   display_title (changing_title);               -- a variable
   display_title ('Happy' || spc || 'Birthday'); -- an expression
   display_title (INITCAP (happy_title));        -- another expression
END;
/
