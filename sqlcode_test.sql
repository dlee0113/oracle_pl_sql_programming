DROP TABLE sqlcode_test_table;
CREATE TABLE sqlcode_test_table (id1 NUMBER, id2 NUMBER, id3 NUMBER, id4 NUMBER);

DECLARE
   a   NUMBER;

   PROCEDURE local_insert
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('inside local proc before insert ' || SQLCODE);

      INSERT INTO sqlcode_test_table
           VALUES (1, 1, 1, 1);

      DBMS_OUTPUT.put_line ('inside local proc after insert ' || SQLCODE);
   END local_insert;

   PROCEDURE raise_20000
   IS
   BEGIN
      DBMS_OUTPUT.put_line
                      (   'inside local proc before RAISE_APPLICATION_ERROR '
                       || SQLCODE
                      );
      raise_application_error (-20000, 'Bang');
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line
                       (   'inside local proc after RAISE_APPLICATION_ERROR '
                        || SQLCODE
                       );
   END raise_20000;
BEGIN
   DBMS_OUTPUT.put_line ('before anonymous block ' || SQLCODE);

   BEGIN
      RAISE NO_DATA_FOUND;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('after exception (inside handler) ' || SQLCODE);
         local_insert;
         DBMS_OUTPUT.put_line ('inside handler, after local insert '
                               || SQLCODE
                              );

         DELETE FROM sqlcode_test_table;

         DBMS_OUTPUT.put_line ('inside handler, after in-section delete ' || SQLCODE);

         raise_20000;
         DBMS_OUTPUT.put_line ('inside handler, after local proc raising -20000 ' || SQLCODE);
         a := 7;
         DBMS_OUTPUT.put_line ('inside handler, after assignment ' || SQLCODE);
   END;

   DBMS_OUTPUT.put_line ('after anonymous block ' || SQLCODE);
END;
/

DROP TABLE sqlcode_test_table;
