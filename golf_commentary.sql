/*-- golf_commentary.sql */
DROP TABLE golf_scores;

CREATE TABLE golf_scores
(
   timestamp    DATE NOT NULL
 , score        NUMBER NOT NULL
 , commentary   VARCHAR2 (30)
);

CREATE OR REPLACE TRIGGER golf_commentary
   BEFORE INSERT
   ON golf_scores
   FOR EACH ROW
DECLARE
   c_par_score   CONSTANT PLS_INTEGER := 72;
BEGIN
   :new.commentary :=
      CASE
         WHEN :new.score < c_par_score THEN 'Under'
         WHEN :new.score = c_par_score THEN NULL
         ELSE 'Over' || ' Par'
      END;
END;
/

DROP TRIGGER golf_commentary;

CREATE OR REPLACE TRIGGER golf_commentary_under_par
   BEFORE INSERT
   ON golf_scores
   FOR EACH ROW
   WHEN (new.score < 72)
BEGIN
   :new.commentary := 'Under Par';
END;
/

CREATE OR REPLACE TRIGGER golf_commentary_par
   BEFORE INSERT
   ON golf_scores
   FOR EACH ROW
   WHEN (new.score = 72)
BEGIN
   :new.commentary := 'Par';
END;
/

CREATE OR REPLACE TRIGGER golf_commentary_over_par
   BEFORE INSERT
   ON golf_scores
   FOR EACH ROW
   WHEN (new.score > 72)
BEGIN
   :new.commentary := 'Over Par';
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/