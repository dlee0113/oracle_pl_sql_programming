SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE nocopy_test
IS
   TYPE number_varray IS VARRAY (10) OF NUMBER;

   PROCEDURE pass_by_value (
      nums   IN OUT   number_varray
   );

   PROCEDURE pass_by_ref (
      nums   IN OUT NOCOPY   number_varray
   );
END;
/

CREATE OR REPLACE PACKAGE BODY nocopy_test
IS
   PROCEDURE pass_by_value (
      nums   IN OUT   number_varray
   )
   IS
   BEGIN
      FOR indx IN nums.FIRST .. nums.LAST
      LOOP
         nums (indx) := nums (indx) * 2;

         IF indx > 2
         THEN
            RAISE VALUE_ERROR;
         END IF;
      END LOOP;
   END;

   PROCEDURE pass_by_ref (
      nums   IN OUT NOCOPY   number_varray
   )
   IS
   BEGIN
      FOR indx IN nums.FIRST .. nums.LAST
      LOOP
         nums (indx) := nums (indx) * 2;

         IF indx > 2
         THEN
            RAISE VALUE_ERROR;
         END IF;
      END LOOP;
   END;
END;
/

DECLARE
   nums1   nocopy_test.number_varray
            := nocopy_test.number_varray (1, 2, 3, 4, 5);
   nums2   nocopy_test.number_varray
            := nocopy_test.number_varray (1, 2, 3, 4, 5);

   PROCEDURE shownums (
      str    IN   VARCHAR2
    , nums   IN   nocopy_test.number_varray
   )
   IS
   BEGIN
      DBMS_OUTPUT.put_line (str);

      FOR indx IN nums.FIRST .. nums.LAST
      LOOP
         DBMS_OUTPUT.put (nums (indx) || '-');
      END LOOP;

      DBMS_OUTPUT.new_line;
   END;
BEGIN
   shownums ('Before By Value', nums1);

   BEGIN
      nocopy_test.pass_by_value (nums1);
   EXCEPTION
      WHEN OTHERS
      THEN
         shownums ('After By Value', nums1);
   END;

   shownums ('Before NOCOPY', nums2);

   BEGIN
      nocopy_test.pass_by_ref (nums2);
   EXCEPTION
      WHEN OTHERS
      THEN
         shownums ('After NOCOPY', nums2);
   END;
END;
/