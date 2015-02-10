drop type pet_t force;
drop type vet_visit_t force;
drop type vet_visits_t force;

CREATE TYPE vet_visit_t IS OBJECT (
   visit_date  DATE,
   reason      VARCHAR2 (100)
   );
/

create type vet_visits_t is table of vet_visit_t
/

CREATE TYPE pet_t IS OBJECT (
   tag_no                        INTEGER,
   NAME                          VARCHAR2 (60),
   petcare vet_visits_t, 
   MEMBER FUNCTION set_tag_no (new_tag_no IN INTEGER)
      RETURN pet_t);
/

CREATE TYPE BODY Pet_t 
AS
   MEMBER FUNCTION set_tag_no (new_tag_no IN INTEGER) RETURN Pet_t 
   IS
      the_pet Pet_t := SELF;  -- initialize to "current" object
   BEGIN
      the_pet.tag_no := new_tag_no;
      RETURN the_pet;
   END;
END;
/

DECLARE
   TYPE bunch_of_pets_t IS TABLE OF pet_t
      INDEX BY BINARY_INTEGER;

   my_pets   bunch_of_pets_t;
BEGIN
   my_pets (1) :=
         pet_t (
            100,
            'Mercury',
            vet_visits_t (
               vet_visit_t (
                  '01-Jan-2001',
                  'Clip wings'
               ),
               vet_visit_t (
                  '01-Apr-2002',
                  'Check cholesterol'
               )
            )
         );
   DBMS_OUTPUT.put_line (my_pets (1).NAME);
   DBMS_OUTPUT.put_line (
      my_pets (1).petcare (my_pets(1).petcare.LAST).reason
   );
   DBMS_OUTPUT.put_line (my_pets.COUNT);
   DBMS_OUTPUT.put_line (my_pets(1).petcare.FIRST);
END;
/

 
