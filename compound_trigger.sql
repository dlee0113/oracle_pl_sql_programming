CREATE TABLE incremented_values (n NUMBER)
/

CREATE OR REPLACE TRIGGER compounder FOR
   UPDATE OR INSERT OR DELETE
   ON incremented_values
   COMPOUND TRIGGER
   v_global_var   NUMBER := 1;
   BEFORE STATEMENT
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('Compound:BEFORE S:' || v_global_var);
      v_global_var := v_global_var + 1;
   END
   BEFORE STATEMENT;

   BEFORE EACH ROW
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('Compound:BEFORE R:' || v_global_var);
      v_global_var := v_global_var + 1;
   END
   BEFORE EACH ROW;

   AFTER EACH ROW
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('Compound:AFTER  R:' || v_global_var);
      v_global_var := v_global_var + 1;
   END
   AFTER EACH ROW;

   AFTER STATEMENT
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('Compound:AFTER  S:' || v_global_var);
      v_global_var := v_global_var + 1;
   END
   AFTER STATEMENT;

END;
/

CREATE OR REPLACE TRIGGER follows_compounder
   BEFORE INSERT
   ON incremented_values
   FOR EACH ROW
   FOLLOWS compounder
BEGIN
   DBMS_OUTPUT.put_line ('Following Trigger');
END;
/

CREATE OR REPLACE TRIGGER no_create
   AFTER CREATE
   ON SCHEMA
BEGIN
   raise_application_error (
      -20000
    , 'ERROR : Objects cannot be created in the production database.'
   );
END;
/

CREATE OR REPLACE TRIGGER no_create
   BEFORE DDL
   ON SCHEMA
BEGIN
   IF ora_sysevent = 'CREATE'
   THEN
      raise_application_error (
         -20000
       ,    'Cannot create the '
         || ora_dict_obj_type
         || ' named '
         || ora_dict_obj_name
         || ' as requested by '
         || ora_dict_obj_owner
      );
   ELSIF ora_sysevent = 'DROP'
   THEN
      -- Logic for DROP operations
      NULL;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER undroppable
   BEFORE DROP
   ON SCHEMA
BEGIN
   raise_application_error (-20000, 'You cannot drop me! I am invincible!');
END;
/

