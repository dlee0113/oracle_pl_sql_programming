CREATE TABLE hmo_coverage (
   denial VARCHAR2(100),
   patient_name VARCHAR2(100))
/

DECLARE
   TYPE denials_t IS TABLE OF hmo_coverage.denial%TYPE;

   TYPE patient_names_t IS TABLE OF hmo_coverage.denial%TYPE;

   l_denials   denials_t
                  := denials_t ('TOO SICK', 'TOO POOR', 'COMPLAINS TOO MUCH');
   l_names     patient_names_t
                    := patient_names_t ('John Lovecanal', 'Sally Works2Jobs');
BEGIN
   /* Cause an ORA-22160 error */
   l_denials.DELETE (2);
   FORALL indx IN l_denials.FIRST .. l_denials.LAST
      INSERT INTO hmo_coverage
           VALUES (l_denials (indx), l_names (indx));
END;
/