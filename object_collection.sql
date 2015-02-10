DROP TYPE bird_t;
DROP TYPE pet_t;


CREATE TYPE pet_t IS OBJECT (
   tag_no   INTEGER
 , NAME     VARCHAR2 (60)
 , MEMBER FUNCTION set_tag_no (new_tag_no IN INTEGER)
      RETURN pet_t
)
NOT FINAL;
/

CREATE TYPE BODY pet_t
AS
   MEMBER FUNCTION set_tag_no (new_tag_no IN INTEGER)
      RETURN pet_t
   IS
      the_pet   pet_t := SELF;              -- initialize to "current" object
   BEGIN
      the_pet.tag_no := new_tag_no;
      RETURN the_pet;
   END;
END;
/

CREATE TYPE bird_t UNDER pet_t (
   wingspan   NUMBER
)
;
/

DECLARE
   TYPE pets_t IS TABLE OF pet_t;

   pets   pets_t
              := pets_t (pet_t (1050, 'Sammy'), bird_t (1075, 'Mercury', 14));
BEGIN
   FOR indx IN pets.FIRST .. pets.LAST
   LOOP
      DBMS_OUTPUT.put_line (pets (indx).NAME);
   END LOOP;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/