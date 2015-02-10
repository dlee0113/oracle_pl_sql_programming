CREATE TABLE falls (
   fall_id NUMBER,
   fall SYS.XMLType
);

INSERT INTO falls VALUES (1, SYS.XMLType.CreateXML(
   '<?xml version="1.0"?>
    <fall>
       <name>Munising Falls</name>
       <county>Alger</county>
       <state>MI</state>
       <url>
          http://michiganwaterfalls.com/munising_falls/munising_falls.html
       </url>
    </fall>'));

INSERT INTO falls VALUES (2, SYS.XMLType.CreateXML(
   '<?xml version="1.0"?>
    <fall>
       <name>Au Train Falls</name>
       <county>Alger</county>
       <state>MI</state>
       <url>
          http://michiganwaterfalls.com/autrain_falls/autrain_falls.html
       </url>
    </fall>'));

INSERT INTO falls VALUES (3, SYS.XMLType.CreateXML(
   '<?xml version="1.0"?>
    <fall>
       <name>Laughing Whitefish Falls</name>
       <county>Alger</county>
       <state>MI</state>
    </fall>'));

CREATE INDEX falls_by_name
   ON falls f (
      SUBSTR(
         SYS.XMLType.getStringVal(
            SYS.XMLType.extract(f.fall,'/fall/name/text()')
         ),1,80
      )
   );




/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
