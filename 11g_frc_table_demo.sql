DROP TABLE loan_info
/
CREATE TABLE loan_info (
   NAME VARCHAR2(100) PRIMARY KEY,
   length_of_loan INTEGER,
   initial_interest_rate NUMBER,
   regular_interest_rate NUMBER,
   percentage_down_payment INTEGER
)
/

BEGIN
   INSERT INTO loan_info
        VALUES ('Five year fixed', 5, 6, 6, 20);

   INSERT INTO loan_info
        VALUES ('Ten year fixed', 10, 5.7, 5.7, 20);

   INSERT INTO loan_info
        VALUES ('Fifteen year fixed', 15, 5.5, 5.5, 10);

   INSERT INTO loan_info
        VALUES ('Thirty year fixed', 30, 5, 5, 10);

   INSERT INTO loan_info
        VALUES ('Two year balloon', 2, 3, 8, 0);

   INSERT INTO loan_info
        VALUES ('Five year balloon', 5, 4, 10, 5);

   COMMIT;
END;
/

CREATE OR REPLACE FUNCTION loan_info_for_name (NAME_IN IN VARCHAR2)
   RETURN loan_info%ROWTYPE
   RESULT_CACHE RELIES_ON (loan_info)
IS
   l_row   loan_info%ROWTYPE;
BEGIN
   DBMS_OUTPUT.put_line ('> Looking up loan info for ' || NAME_IN);

   SELECT * INTO l_row FROM loan_info WHERE NAME = NAME_IN;

   RETURN l_row;
END loan_info_for_name;
/

DECLARE
   l_row   loan_info%ROWTYPE;
BEGIN
   DBMS_OUTPUT.put_line
              ('First time calling loan_info_for_name for Five year fixed...');
   l_row := loan_info_for_name ('Five year fixed');
   DBMS_OUTPUT.put_line
            ('First time calling loan_info_for_name for Five year balloon...');
   l_row := loan_info_for_name ('Five year balloon');
   DBMS_OUTPUT.put_line
             ('Second time calling loan_info_for_name for Five year fixed...');
   l_row := loan_info_for_name ('Five year fixed');

   UPDATE loan_info
      SET percentage_down_payment = 25
    WHERE NAME = 'Thirty year fixed';

   COMMIT;
   DBMS_OUTPUT.put_line ('After commit, calling loan_info_for_name...');
   l_row := loan_info_for_name ('Five year fixed');
END;
/

CREATE OR REPLACE FUNCTION loan_names RETURN DBMS_SQL.VARCHAR2S
   RESULT_CACHE RELIES_ON (loan_info)
IS
   l_names   DBMS_SQL.VARCHAR2S;
BEGIN
   DBMS_OUTPUT.put_line ('> Looking up loan names....');

   SELECT name BULK COLLECT INTO l_names FROM loan_info;
   RETURN l_names;
END loan_names;
/

DECLARE
    l_names   DBMS_SQL.VARCHAR2S;
BEGIN
   DBMS_OUTPUT.put_line ('First time retrieving all names...');
   l_names := loan_names ();
   DBMS_OUTPUT.put_line('Second time retrieving all names...');
   l_names := loan_names ();

   UPDATE loan_info SET percentage_down_payment = 25
    WHERE NAME = 'Thirty year fixed';

   COMMIT;
   DBMS_OUTPUT.put_line ('After commit, third time retrieving all names...');
    l_names := loan_names ();
END;
/