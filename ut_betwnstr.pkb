CREATE OR REPLACE PACKAGE BODY ut_betwnstr
IS
   PROCEDURE ut_setup
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE ut_teardown
   IS
   BEGIN
      NULL;
   END;

   -- For each program to test...
   PROCEDURE ut_betwnstr
   IS
      check_this     VARCHAR2 (32767);
      against_this   VARCHAR2 (32767);
   BEGIN
      /* "Normal usage" test case. Start and end values
          are inside the string. */

      /* Call the program being tested (betwnstr) with a set of
         input values that match this test case. Get back the
         actual result. */

      check_this :=
         betwnstr (string_in => 'abcdefgh', start_in => 3, end_in => 5);

      /* Define the "control" or expected value for this test case. */
      against_this := 'cde';

      /* Now use the assertion package to see if they are equal,
         and record the results. */

      utassert.eq ('Normal Usage', check_this, against_this);

      /* Or why not just write it myself:

      IF check_this <> against_this
      THEN
         dbms_output.put_line ( 'Normal case fails!' );
      ELSE
         dbms_output.put_line ( 'Normal case SUCCEEDS!' );
      END IF;

      */

      -- End of test for "normal"

      -- Define "control" operation for "zero start"
      against_this := 'ab';
      -- Execute test code for "zero start"
      check_this :=
         betwnstr (string_in => 'abcdefgh', start_in => 0, end_in => 2);
      -- Assert success for "zero start"

      -- Compare the two values.
      utassert.eq ('zero start', check_this, against_this);
      -- End of test for "zero start"

      -- Define "control" operation for "null start"
      against_this := NULL;
      -- Execute test code for "null start"
      check_this :=
         betwnstr (string_in => 'abcdefgh', start_in => NULL, end_in => 2);
      -- Assert success for "null start"

      -- Check for NULL return value.
      utassert.isnull ('null start', check_this);
      -- End of test for "null start"

      -- Define "control" operation for "big start small end"
      against_this := NULL;
      -- Execute test code for "big start small end"
      check_this :=
         betwnstr (string_in => 'abcdefgh', start_in => 10, end_in => 5);
      -- Assert success for "big start small end"

      -- Check for NULL return value.
      utassert.isnull ('big start small end', check_this);
      -- End of test for "big start small end"

      -- Define "control" operation for "null end"
      against_this := NULL;
      -- Execute test code for "null end"
      check_this :=
         betwnstr (string_in => 'abcdefgh', start_in => 3, end_in => NULL);
      -- Assert success for "null end"

      -- Check for NULL return value.
      utassert.isnull ('null end', check_this);
      -- End of test for "null end"

      -- Define "control" operation for "neg start and end too big"
      against_this := 'abcdefgh';
      -- Execute test code for "neg start and end too big"
      check_this :=
         betwnstr (string_in => 'abcdefgh', start_in => -1, end_in => -15);
      -- Assert success for "neg start and end too big"

      -- Compare the two values.
      utassert.eq ('neg start and end too big', check_this, against_this);
      -- End of test for "neg start and end too big"

      -- Define "control" operation for "neg start and end"
      against_this := 'efg';
      -- Execute test code for "neg start and end"
      check_this :=
         betwnstr (string_in => 'abcdefgh', start_in => -2, end_in => -4);
      -- Assert success for "neg start and end"

      -- Compare the two values.
      utassert.eq ('neg start and end', check_this, against_this);
   -- End of test for "neg start and end"
   END ut_betwnstr;
END ut_betwnstr;
/