DECLARE
   SUBTYPE location_t IS VARCHAR2(64);
   TYPE population_type IS TABLE OF NUMBER INDEX BY location_t;
      
   l_country_population population_type;
   l_continent_population population_type;
   
   l_count PLS_INTEGER;
   l_location location_t;
BEGIN
   l_country_population('Greenland') := 100000;
   l_country_population('Iceland') := 750000;
     
   l_continent_population('Australia') := 30000000;
   l_continent_population('Antarctica') := 1000;
   l_continent_population('antarctica') := 1001; 

   l_count := l_country_population.COUNT;
   DBMS_OUTPUT.PUT_LINE ('COUNT = ' || l_count);
 
   l_location := l_continent_population.FIRST; 
   DBMS_OUTPUT.PUT_LINE ('FIRST row = ' || l_location);
   DBMS_OUTPUT.PUT_LINE ('FIRST value = ' || l_continent_population(l_location));
   
   l_location := l_continent_population.LAST; 
   DBMS_OUTPUT.PUT_LINE ('LAST row = ' || l_location);
   DBMS_OUTPUT.PUT_LINE ('LAST value = ' || l_continent_population(l_location));
END;    
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
