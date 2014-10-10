/*-- validate_score.sql */

CREATE OR REPLACE TRIGGER validate_score
   AFTER INSERT OR UPDATE
   ON frame
   FOR EACH ROW
DECLARE
   c_yes   CONSTANT CHAR (1) := 'Y';
BEGIN
   raise_application_error (
      -20001
    , 'ERROR : '
      || CASE
            WHEN :new.strike = c_yes AND :new.score < 10
            THEN
               'Score For Strike Must Be >= 10'
            WHEN :new.spare = c_yes AND :new.score < 10
            THEN
               'Score For Spare Must Be >= 10'
            WHEN :new.strike = c_yes AND :new.spare = c_yes
            THEN
               'Cannot Enter Spare And Strike For Same Frame'
         END
   );
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
