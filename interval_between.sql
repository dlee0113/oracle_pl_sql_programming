/* File on web: interval_between.sql */
DECLARE
   start_date TIMESTAMP;
   end_date TIMESTAMP;
   service_interval INTERVAL YEAR TO MONTH;
   years_of_service NUMBER;
   months_of_service NUMBER;
BEGIN
   --Normally, we would retrieve start and end dates from a database.
   start_date := TO_TIMESTAMP('29-DEC-1988','dd-mon-yyyy');
   end_date := TO_TIMESTAMP ('26-DEC-1995','dd-mon-yyyy');

   --Determine and display years and months of service:
   service_interval := (end_date - start_date) YEAR TO MONTH;
   DBMS_OUTPUT.PUT_LINE(service_interval);

   --Use the new EXTRACT function to grab individual
   --year and month components.
   years_of_service := EXTRACT(YEAR FROM service_interval);
   months_of_service := EXTRACT(MONTH FROM service_interval);
   DBMS_OUTPUT.PUT_LINE(years_of_service || ' years and '
                        || months_of_service || ' months');
END;

