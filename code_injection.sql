DROP TABLE nasty_data;

DROP PROCEDURE backdoor;

REM This program is left wide-open to code injection through the 
REM dynamic WHERE clause.

CREATE OR REPLACE PROCEDURE get_rows (
   table_in   IN   VARCHAR2, where_in   IN   VARCHAR2
)
IS
BEGIN
   EXECUTE IMMEDIATE
      'DECLARE l_row ' || table_in || '%ROWTYPE;
       BEGIN 
          SELECT * INTO l_row 
       FROM ' || table_in || ' WHERE ' || where_in || ';
       END;';
END get_rows;
/

BEGIN
   get_rows ('EMPLOYEE'
     ,'employee_id=7369; 
	   EXECUTE IMMEDIATE ''CREATE TABLE nasty_data (mycol NUMBER)''' );
END;
/

BEGIN
   get_rows ('EMPLOYEE'
     ,'employee_id=7369; 
	   EXECUTE IMMEDIATE 
	      ''CREATE PROCEDURE backdoor (str VARCHAR2) 
		    AS BEGIN EXECUTE IMMEDIATE str; END;''' );
END;
/
	
REM One way to minimize the danger of injection is to avoid the
REM completely generic WHERE clause and instead code for
REM specific, anticipated variations.

CREATE OR REPLACE PROCEDURE get_rows (
   table_in   IN   VARCHAR2, value1_in in VARCHAR2, value2_in IN DATE
)
IS
   l_where VARCHAR2(32767);
BEGIN
   IF table_in = 'EMPLOYEE'
   THEN
      l_where := 'last_name = :name AND hire_date < :hdate';
   ELSIF table_in = 'DEPARTMENT'
   THEN
      l_where := 'name LIKE :name AND incorporation_date = :hdate';
   ELSE 
      RAISE_APPLICATION_ERROR (-20000, 'Invalid table name for get_rows: ' || table_in);  
   END IF; 
   
   EXECUTE IMMEDIATE
      'DECLARE l_row ' || table_in || '%ROWTYPE;
       BEGIN 
          SELECT * INTO l_row 
       FROM ' || table_in || ' WHERE ' || l_where || ';
       END;';
	   USING value1_in, value2_in
END get_rows;
/
      
