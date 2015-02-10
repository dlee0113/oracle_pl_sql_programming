CREATE OR REPLACE PROCEDURE show_java_source (
   NAME     IN   VARCHAR2,
   SCHEMA   IN   VARCHAR2 := NULL
)
/*
||  Overview: Shows Java source (prototype)
||
||  Author: Vadim Loevski
*/
IS 
   b                      CLOB;
   v                      VARCHAR2 (2000);
   i                      INTEGER;
   object_not_available   EXCEPTION;
   PRAGMA EXCEPTION_INIT (object_not_available, -29532);

   PROCEDURE pl (
      str         IN   VARCHAR2,
      len         IN   INTEGER := 80,
      expand_in   IN   BOOLEAN := TRUE
   )
   IS 
      v_len   PLS_INTEGER     := LEAST (len, 255);
      v_str   VARCHAR2 (2000);
   BEGIN
      IF LENGTH (str) > v_len
      THEN
         v_str := SUBSTR (str, 1, v_len);
         DBMS_OUTPUT.put_line (v_str);
         pl (SUBSTR (str, len + 1), v_len, expand_in);
      ELSE
         v_str := str;
         DBMS_OUTPUT.put_line (v_str);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF expand_in
         THEN
            DBMS_OUTPUT.ENABLE (1000000);
            DBMS_OUTPUT.put_line (v_str);
         ELSE
            RAISE;
         END IF;
   END;
BEGIN
   /* Move the Java source code to a CLOB. */
   DBMS_LOB.createtemporary (b, FALSE );
   dbms_java.export_source (NAME, NVL (SCHEMA, USER), b);
   /* Read the CLOB to a VARCHAR2 variable and display it. */
   i := 1000;
   DBMS_LOB.READ (b, i, 1, v);
   pl (v);
EXCEPTION
   WHEN object_not_available
   THEN
      IF (SQLERRM) LIKE '%no such%object'
      THEN
         DBMS_OUTPUT.put_line ('Java object cannot be found.');
      END IF;
END;
/

CREATE OR REPLACE JAVA  source named "Hello"
as
   public class hello {
      public static string hello() {
         return "hello oracle world";   
         }
      }
 ;
/

BEGIN
   show_java_source ('Hello');
END;
/

BEGIN
   show_java_source ('Hello-NOT');
END;
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
