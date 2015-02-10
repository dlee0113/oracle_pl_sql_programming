/*
Demonstration of Oracle 11g generalized invocation
*/
DROP TYPE cake_t FORCE;
DROP TYPE dessert_t FORCE;
DROP TYPE food_t FORCE;

CREATE TYPE food_t AS OBJECT
   (name VARCHAR2 (100)
  , food_group VARCHAR2 (100)
  , grown_in VARCHAR2 (100)
  , MEMBER FUNCTION to_string
       RETURN VARCHAR2
   )
   NOT FINAL;
/

CREATE OR REPLACE TYPE BODY food_t
IS
   MEMBER FUNCTION to_string
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    'FOOD! '
             || self.name
             || ' - '
             || self.food_group
             || ' - '
             || self.grown_in;
   END;
END;
/

CREATE TYPE dessert_t
   UNDER food_t
   (contains_chocolate CHAR (1)
  , year_created NUMBER (4)
  , OVERRIDING MEMBER FUNCTION to_string
       RETURN VARCHAR2
   )
   NOT FINAL;
/

CREATE OR REPLACE TYPE BODY dessert_t
IS
   OVERRIDING MEMBER FUNCTION to_string
      RETURN VARCHAR2
   IS
   BEGIN
      /* Add the supertype (food) string to the subtype string.... */
      RETURN    'DESSERT! With Chocolate? '
             || contains_chocolate
             || ' created in '
             || SELF.year_created
             || chr(10)
             || (SELF as food_t).to_string;
   END;
END;
/

CREATE TYPE cake_t
   UNDER dessert_t
   (diameter NUMBER
  , inscription VARCHAR2 (200)
  , OVERRIDING MEMBER FUNCTION to_string
       RETURN VARCHAR2
   );
/

CREATE OR REPLACE TYPE BODY cake_t
IS
   OVERRIDING MEMBER FUNCTION to_string
      RETURN VARCHAR2
   IS
   BEGIN
      /* Invoke two supertype methods... */
      RETURN  'CAKE! With diameter: '
           || self.diameter
           || ' and inscription '
           || SELF.inscription
           || chr(10)
           || (SELF as dessert_t).to_string
           ;
   END;
END;
/
SET SERVEROUTPUT ON FORMAT WRAPPED

DECLARE
   TYPE foodstuffs_nt IS TABLE OF food_t;

   fridge_contents foodstuffs_nt
         := foodstuffs_nt (
               food_t ('Eggs benedict', 'PROTEIN', 'Farm')
             , dessert_t ('Strawberries and cream'
                        , 'FRUIT'
                        , 'Backyard'
                        , 'N'
                        , 2001
                         )
             , cake_t ('Chocolate Supreme'
                     , 'CARBOHYDATE'
                     , 'Kitchen'
                     , 'Y'
                     , 2001
                     , 8
                     , 'Happy Birthday, Veva'
                      )
            );
BEGIN
   FOR indx IN fridge_contents.FIRST .. fridge_contents.LAST
   LOOP
      DBMS_OUTPUT.put_line (RPAD ('=', 60, '='));
      DBMS_OUTPUT.put_line (fridge_contents (indx).to_string);
   END LOOP;
END;
/

/* Output displayed is:

============================================================
FOOD! Eggs benedict - PROTEIN - Farm
============================================================
DESSERT! With Chocolate? N created in FRUIT-2001
FOOD! Strawberries and cream - FRUIT - Backyard
============================================================
CAKE! With diameter: 8 and inscription Happy Birthday, Veva
DESSERT! With Chocolate? Y created in CARBOHYDATE-2001
FOOD! Chocolate Supreme - CARBOHYDATE - Kitchen

PL/SQL procedure successfully completed.

*/