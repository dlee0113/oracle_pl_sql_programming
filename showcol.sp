CREATE OR REPLACE PROCEDURE showcol (
   tab IN VARCHAR2,
   col IN VARCHAR2,
   whr IN VARCHAR2 := NULL)
IS
   cv SYS_REFCURSOR; 
   val VARCHAR2(32767);  
BEGIN
   OPEN cv FOR 
      'SELECT ' || col || 
      '  FROM ' || tab ||
      ' WHERE ' || NVL (whr, '1 = 1');
      
   LOOP
      /* Fetch and exit if done; same as with explicit cursors. */
      FETCH cv INTO val;
      EXIT WHEN cv%NOTFOUND;
      
      /* If on first row, display header info. */
      IF cv%ROWCOUNT = 1
      THEN
         DBMS_OUTPUT.PUT_LINE (RPAD ('-', 60, '-'));
         DBMS_OUTPUT.PUT_LINE (
            'Contents of ' || UPPER (tab) || '.' || UPPER (col));
         DBMS_OUTPUT.PUT_LINE (RPAD ('-', 60, '-'));
      END IF;
      
      DBMS_OUTPUT.PUT_LINE (val);
   END LOOP;
   
   /* Don't forget to clean up! Very important... */
   CLOSE cv;
END;
/   
