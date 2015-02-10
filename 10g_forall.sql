DROP TABLE favorites;

CREATE TABLE favorites (
   flavor VARCHAR2(100),
   NAME VARCHAR2(100));

DECLARE
   TYPE favorites_tt IS TABLE OF favorites%ROWTYPE
      INDEX BY PLS_INTEGER;

   TYPE guide_tt IS TABLE OF PLS_INTEGER
      INDEX BY PLS_INTEGER;

   family   favorites_tt;
   guide    guide_tt;
   l_count INTEGER;
   
   PROCEDURE cleanup IS 
   BEGIN
      DELETE FROM favorites;
      guide.DELETE;
   END;
BEGIN
   family (1).flavor := 'CHOCOLATE';
   family (1).NAME := 'VEVA';
   family (25).flavor := 'STRAWBERRY';
   family (25).NAME := 'STEVEN';
   family (500).flavor := 'VANILLA';
   family (500).NAME := 'CHRIS';
   family (5000).flavor := 'ROCKY ROAD';
   family (5000).NAME := 'ELI';
   family (5001).flavor := 'PINEAPPLE';
   family (5001).NAME := 'MOSHE';
   family (5002).flavor := 'EVERYTHING';
   family (5002).NAME := 'MICA';   
   
   -- Just a subset of the family favorites...
   guide (1) := 1;
   guide (5000) := 2;
   FORALL indx IN indices OF guide -- bewteen my_list.first .. my_first.last
      INSERT INTO favorites
           VALUES family (indx);
           
   SELECT COUNT(*) into l_count FROM favorites;           
   DBMS_OUTPUT.PUT_LINE (l_count); 
   
   cleanup;         
   
   -- Insert nothing at all: no error raised!
   FORALL indx IN indices of guide -- bewteen my_list.first .. my_first.last
      INSERT INTO favorites
           VALUES family (indx);
           
   SELECT COUNT(*) into l_count FROM favorites;           
   DBMS_OUTPUT.PUT_LINE (l_count);     
   
   cleanup;         
   
   -- Use BETWEEN clause
   guide (25) := 1;
   guide (500) := 1;
   guide (5000) := 1;   
   FORALL indx IN indices of guide BETWEEN guide.FIRST AND LEAST (guide.LAST, 500)
      INSERT INTO favorites
           VALUES family (indx);
           
   SELECT COUNT(*) into l_count FROM favorites;           
   DBMS_OUTPUT.PUT_LINE (l_count);    
   
   cleanup; 
   
   -- Use BETWEEN clause with undefined row.
   -- Does NOT raise NO_DATA_FOUND. Instead:
   --    ORA-22160: element at index [7589] does not exist
   -- But rows before that are inserted. Don't forget about SAVE EXCEPTIONS   
   guide (25) := 1;
   guide (417) := 1; -- Undefined row
   guide (500) := 1;
   guide (5000) := 1;   

   BEGIN
       FORALL indx IN indices of guide BETWEEN guide.FIRST AND LEAST (guide.LAST, 500)
          INSERT INTO favorites
               VALUES family (indx);
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE (SQLERRM);
   END;
              
   SELECT COUNT(*) into l_count FROM favorites;           
   DBMS_OUTPUT.PUT_LINE (l_count);    
   
   cleanup;    
   
   -- Use VALUES OF
   guide (-1000) := 1;
   guide (1000) := 5001;
   guide (10000) := 5002;   
   FORALL indx IN VALUES OF guide 
      INSERT INTO favorites
           VALUES family (indx);
           
   SELECT COUNT(*) into l_count FROM favorites;           
   DBMS_OUTPUT.PUT_LINE (l_count);       
   
   cleanup;
   
   -- Use VALUES OF with undefined row
   -- Does NOT raise NO_DATA_FOUND. Instead:
   --    ORA-22160: element at index [7589] does not exist
   -- But rows before that are inserted. Don't forget about SAVE EXCEPTIONS
   
   guide (-1000) := 1;
   guide (1000) := 7589;
   guide (10000) := 5001;   
   BEGIN
       FORALL indx IN VALUES OF guide 
          INSERT INTO favorites
               VALUES family (indx);
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE (SQLERRM);
   END;           
   SELECT COUNT(*) into l_count FROM favorites;           
   DBMS_OUTPUT.PUT_LINE (l_count);       
END;
/

