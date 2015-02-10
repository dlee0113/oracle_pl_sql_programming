CREATE OR REPLACE PACKAGE nocopy_test
IS
   TYPE numbers_t
   IS
      TABLE OF NUMBER;

   PROCEDURE pass_by_value (numbers_inout IN OUT numbers_t);

   PROCEDURE pass_by_ref (numbers_inout IN OUT NOCOPY numbers_t);
END;
/

CREATE OR REPLACE PACKAGE BODY nocopy_test
IS
   PROCEDURE pass_by_value (numbers_inout IN OUT numbers_t)
   IS
   BEGIN
      FOR indx IN 1 .. numbers_inout.COUNT
      LOOP
         numbers_inout (indx) := numbers_inout (indx) * 2;
      END LOOP;
   END;

   PROCEDURE pass_by_ref (numbers_inout IN OUT NOCOPY numbers_t)
   IS
   BEGIN
      FOR indx IN 1 .. numbers_inout.COUNT
      LOOP
         numbers_inout (indx) := numbers_inout (indx) * 2;
      END LOOP;
   END;
END;
/

DECLARE
   l_numbers   nocopy_test.numbers_t := nocopy_test.numbers_t();

   PROCEDURE loadtab
   IS
   BEGIN
      FOR indx IN 1 .. 100000
      LOOP
         l_numbers (indx) := indx;
      END LOOP;
   END;
BEGIN
   l_numbers.extend (100000);
   --
   loadtab;
   sf_timer.start_timer;

   FOR indx IN 1 .. 1000
   LOOP
      nocopy_test.pass_by_value (l_numbers);
   END LOOP;

   sf_timer.show_elapsed_time ('By value  (without NOCOPY)');
   --
   loadtab;
   sf_timer.start_timer;

   FOR indx IN 1 .. 1000
   LOOP
      nocopy_test.pass_by_ref (l_numbers);
   END LOOP;

   sf_timer.show_elapsed_time ('By reference (with NOCOPY)');
END;
/

/*
Oracle 10g Release 2:
    By value  (without NOCOPY) - Elapsed CPU : 20.49 seconds.
    By reference (with NOCOPY) - Elapsed CPU : 12.32 seconds.
    
Oracle 11g Release 1:
    By value  (without NOCOPY) - Elapsed CPU : 13.12 seconds.
    By reference (with NOCOPY) - Elapsed CPU : 12.82 seconds.
*/