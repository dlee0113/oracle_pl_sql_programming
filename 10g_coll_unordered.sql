DECLARE
   TYPE nested_tab_t IS TABLE OF INTEGER;

   tab_1   nested_tab_t := nested_tab_t (1, 2, 3, 4, 5, 6, 7);
   tab_2   nested_tab_t := nested_tab_t (7, 6, 5, 4, 3, 2, 1);

   PROCEDURE tabs_equal (i_tab_1 IN nested_tab_t, i_tab_2 IN nested_tab_t)
   IS
      v_equal   BOOLEAN := i_tab_1 = i_tab_2;
   BEGIN
      IF v_equal IS NULL
      THEN
         DBMS_OUTPUT.put_line ('null');
      ELSIF v_equal
      THEN
         DBMS_OUTPUT.put_line ('equal');
      ELSE
         DBMS_OUTPUT.put_line ('not equal');
      END IF;
   END tabs_equal;
BEGIN
   tabs_equal (tab_1, tab_2);
   tab_1.EXTEND (1);
   tabs_equal (tab_1, tab_2);
   tab_2.EXTEND (1);
   tabs_equal (tab_1, tab_2);
END;

