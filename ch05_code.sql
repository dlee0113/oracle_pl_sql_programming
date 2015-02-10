/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 5

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

DECLARE
   account_id          INTEGER;
   balance_remaining   NUMBER;

   FUNCTION account_balance (id_in IN INTEGER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN 0;
   END;

   PROCEDURE apply_balance (id_in IN INTEGER, balance_in IN NUMBER)
   IS
   BEGIN
      NULL;
   END;
BEGIN
   LOOP
      balance_remaining := account_balance (account_id);

      IF balance_remaining < 1000
      THEN
         EXIT;
      ELSE
         apply_balance (account_id, balance_remaining);
      END IF;
   END LOOP;

   LOOP
      /* Calculate the balance */
      balance_remaining := account_balance (account_id);

      /* Embed the IF logic into the EXIT statement */
      EXIT WHEN balance_remaining < 1000;

      /* Apply balance if still executing the loop */
      apply_balance (account_id, balance_remaining);
   END LOOP;
END;
/

DECLARE
   pipename   CONSTANT VARCHAR2 (12) := 'signaler';
   result     INTEGER;
   pipebuf    VARCHAR2 (64);

   PROCEDURE data_gathering_procedure
   IS
   BEGIN
      NULL;
   END;
BEGIN
   /* create private pipe with a known name */
   result := sys.DBMS_PIPE.create_pipe (pipename);

   LOOP
      data_gathering_procedure;
      sys.DBMS_LOCK.sleep (10);

      /* see if there is a message on the pipe */
      IF sys.DBMS_PIPE.receive_message (pipename, 0) = 0
      THEN
         /* interpret the message and act accordingly */
         sys.DBMS_PIPE.unpack_message (pipebuf);
         EXIT WHEN pipebuf = 'stop';
      END IF;
   END LOOP;
END;
/

DECLARE
   pipename   VARCHAR2 (12) := 'signaler';
   result     INTEGER := DBMS_PIPE.create_pipe (pipename);
BEGIN
   DBMS_PIPE.pack_message ('stop');
END;
/

BEGIN
   FOR loop_counter IN REVERSE 1 .. 10
   LOOP
      NULL;
   END LOOP;
END;
/

DECLARE
   PROCEDURE calc_values (indx_in IN INTEGER)
   IS
   BEGIN
      NULL;
   END;
BEGIN
   FOR loop_index IN 1 .. 100
   LOOP
      IF MOD (loop_index, 2) = 0
      THEN
         /* We have an even number, so perform calculation */
         calc_values (loop_index);
      END IF;
   END LOOP;

   FOR even_number IN 1 .. 50
   LOOP
      calc_values (even_number * 2);
   END LOOP;
END;
/

DROP TABLE occupancy
/

CREATE TABLE occupancy
(
   pet_id          INTEGER
 , name            VARCHAR2 (200)
 , room_number     INTEGER
 , occupied_dt     DATE
 , checkout_date   DATE
)
/

CREATE OR REPLACE PROCEDURE update_bill (id_in   IN INTEGER
                                       , room_in IN INTEGER
                                        )
IS
BEGIN
   NULL;
END;
/

DECLARE
   CURSOR occupancy_cur
   IS
      SELECT pet_id, room_number
        FROM occupancy
       WHERE occupied_dt = TRUNC (SYSDATE);

   occupancy_rec   occupancy_cur%ROWTYPE;
BEGIN
   OPEN occupancy_cur;

   LOOP
      FETCH occupancy_cur
      INTO occupancy_rec;

      EXIT WHEN occupancy_cur%NOTFOUND;
      update_bill (occupancy_rec.pet_id, occupancy_rec.room_number);
   END LOOP;

   CLOSE occupancy_cur;
END;
/

DECLARE
   CURSOR occupancy_cur
   IS
      SELECT pet_id, room_number
        FROM occupancy
       WHERE occupied_dt = TRUNC (SYSDATE);
BEGIN
   FOR occupancy_rec IN occupancy_cur
   LOOP
      update_bill (occupancy_rec.pet_id, occupancy_rec.room_number);
   END LOOP;
END;
/

DECLARE
   year_number   INTEGER := 1;
BEGIN
  <<year_loop>>
   WHILE year_number <= 1995
   LOOP
     <<month_loop>>
      FOR month_number IN 1 .. 12
      LOOP
         NULL;
      END LOOP month_loop;

      year_number := year_number + 1;
   END LOOP year_loop;
END;
/

BEGIN
  <<year_loop>>
   FOR year_number IN 1800 .. 1995
   LOOP
     <<month_loop>>
      FOR month_number IN 1 .. 12
      LOOP
         IF year_loop.year_number = 1900
         THEN
            NULL;
         END IF;
      END LOOP month_loop;
   END LOOP year_loop;
END;
/

BEGIN
   FOR l_index IN 1 .. 10
   LOOP
      CONTINUE WHEN MOD (l_index, 2) = 0;
      DBMS_OUTPUT.put_line ('Loop index = ' || TO_CHAR (l_index));
   END LOOP;
END;
/

BEGIN
  <<outer>>
   FOR outer_index IN 1 .. 5
   LOOP
      DBMS_OUTPUT.put_line ('Outer index = ' || TO_CHAR (outer_index));

     <<inner>>
      FOR inner_index IN 1 .. 5
      LOOP
         DBMS_OUTPUT.put_line ('  Inner index = ' || TO_CHAR (inner_index));
         CONTINUE outer;
      END LOOP inner;
   END LOOP outer;
END;
/

CREATE OR REPLACE PACKAGE pets_global
IS
   max_pets   NUMBER := 100;
END;
/

DECLARE
   CURSOR occupancy_cur
   IS
      SELECT pet_id, room_number
        FROM occupancy
       WHERE occupied_dt = TRUNC (SYSDATE);

   pet_count   INTEGER := 0;
BEGIN
   FOR occupancy_rec IN occupancy_cur
   LOOP
      update_bill (occupancy_rec.pet_id, occupancy_rec.room_number);
      pet_count := pet_count + 1;
      EXIT WHEN pet_count >= pets_global.max_pets;
   END LOOP;
END;
/

CREATE TABLE occupancy_history
(
   pet_id          INTEGER
 , name            VARCHAR2 (100)
 , checkout_date   DATE
)
/

DECLARE
   CURSOR checked_out_cur
   IS
      SELECT pet_id, name, checkout_date
        FROM occupancy
       WHERE checkout_date IS NOT NULL;
BEGIN
   FOR checked_out_rec IN checked_out_cur
   LOOP
      INSERT INTO occupancy_history (pet_id, name, checkout_date
                                    )
          VALUES (
                     checked_out_rec.pet_id
                   , checked_out_rec.name
                   , checked_out_rec.checkout_date
                 );

      DELETE FROM occupancy
            WHERE pet_id = checked_out_rec.pet_id;
   END LOOP;

   BEGIN
      INSERT INTO occupancy_history (pet_id, name, checkout_date
                                    )
         SELECT pet_id, name, checkout_date
           FROM occupancy
          WHERE checkout_date IS NOT NULL;

      DELETE FROM occupancy
            WHERE checkout_date IS NOT NULL;
   END;

   BEGIN
      FOR checked_out_rec IN checked_out_cur
      LOOP
         BEGIN
            INSERT INTO occupancy_history (pet_id, name, checkout_date
                                          )
                VALUES (
                           checked_out_rec.pet_id
                         , checked_out_rec.name
                         , checked_out_rec.checkout_date
                       );

            DELETE FROM occupancy
                  WHERE pet_id = checked_out_rec.pet_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               log_checkout_error (checked_out_rec);
         END;
      END LOOP;
   END;
END;
/