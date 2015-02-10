DROP TYPE pet_t FORCE;

DROP TYPE pet_nt FORCE;

CREATE TYPE pet_t IS OBJECT (
   NAME    VARCHAR2 (60)
 , breed   VARCHAR2 (100)
 , dob     DATE
);
/

CREATE TYPE pet_nt IS TABLE OF pet_t;
/

CREATE OR REPLACE FUNCTION pet_family (dad_in IN pet_t, mom_in IN pet_t)
   RETURN pet_nt
IS
   l_count   PLS_INTEGER;
   retval    pet_nt      := pet_nt ();
BEGIN
   retval.EXTEND;
   retval (retval.LAST) := dad_in;
   retval.EXTEND;
   retval (retval.LAST) := mom_in;

   IF mom_in.breed = 'RABBIT'
   THEN
      l_count := 12;
   ELSIF mom_in.breed = 'DOG'
   THEN
      l_count := 4;
   ELSIF mom_in.breed = 'KANGAROO'
   THEN
      l_count := 1;
   END IF;

   FOR indx IN 1 .. l_count
   LOOP
      retval.EXTEND;
      retval (retval.LAST) :=
                         pet_t ('BABY' || indx, mom_in.breed, SYSDATE - indx);
   END LOOP;

   RETURN retval;
END pet_family;
/

REM Call the table function within a SELECT staement.

SELECT pets.NAME, pets.dob
  FROM TABLE (pet_family (pet_t ('Hoppy', 'RABBIT', SYSDATE)
                        , pet_t ('Hippy', 'RABBIT', SYSDATE)
                         )
             ) pets;

REM Place the same query inside a PL/SQL function returning a cursor variable.
 
CREATE OR REPLACE FUNCTION pet_family_cv
   RETURN sys_refcursor
IS
   retval   sys_refcursor;
BEGIN
   OPEN retval FOR
      SELECT *
        FROM TABLE (pet_family (pet_t ('Hoppy', 'RABBIT', SYSDATE)
                              , pet_t ('Hippy', 'RABBIT', SYSDATE)
                               )
                   );

   RETURN retval;
END pet_family_cv;
/

REM Now call this function and process the data as if it came from a table.
REM This same function can easily be called from Java and other host
REM environments, thereby hiding all the data construction complexities.

DECLARE
   TYPE pet_r IS RECORD (
      NAME    VARCHAR2 (60)
    , breed   VARCHAR2 (100)
    , dob     DATE
   );

   rec   pet_r;
   cv    sys_refcursor;
BEGIN
   cv := pet_family_cv;

   LOOP
      FETCH cv
       INTO rec;

      EXIT WHEN cv%NOTFOUND;
      DBMS_OUTPUT.put_line (rec.NAME);
   END LOOP;
   
   CLOSE cv;
END;
/
