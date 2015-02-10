CREATE OR REPLACE TRIGGER io_create
   INSTEAD OF CREATE
   ON DATABASE
   WHEN (ora_dict_obj_type = 'TABLE')
DECLARE
   v_sql     VARCHAR2 (32767);                              -- sql to be built
   v_sql_t   ora_name_list_t;                                  -- table of sql
BEGIN
   -- get the SQL statement being executed
   FOR counter IN 1 .. ora_sql_txt (v_sql_t)
   LOOP
      v_sql := v_sql || v_sql_t (counter);
   END LOOP;

   -- Determine the partition clause and add it.
   -- We will call the my_partition function
   v_sql :=
         SUBSTR (v_sql, 1, ora_partition_pos)
      || magic_partition_function
      || SUBSTR (v_sql, ora_partition_pos + 1);

   /* Prepend table name with login username.
   |  Replace CRLFs with spaces.
   |  Requires an explicit CREATE ANY TABLE privilege,
   |  unless you switch to AUTHID CURRENT_USER.
   */
   v_sql :=
      REPLACE (UPPER (REPLACE (v_sql, CHR (10), ' '))
             , 'CREATE TABLE '
             , 'CREATE TABLE ' || ora_login_user || '.'
              );

   -- now execute the SQL
   EXECUTE IMMEDIATE v_sql;
END;