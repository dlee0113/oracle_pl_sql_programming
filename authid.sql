/*
|| Demonstration of AUTHID/Invoker functionality.
|| Author: Steven Feuerstein
||   Date: 2/99
*/
SPOOL authid.log

/* Set up the various accounts. */

SET ECHO ON FEEDBACK ON
CONNECT SYSTEM/MANAGER
GRANT CONNECT, RESOURCE TO hq IDENTIFIED BY hq;
GRANT CREATE PUBLIC SYNONYM TO hq;
GRANT DROP PUBLIC SYNONYM TO hq;
GRANT CONNECT, RESOURCE TO chicago IDENTIFIED BY chicago;
GRANT CONNECT, RESOURCE TO newyork IDENTIFIED BY newyork;
SET ECHO OFF FEEDBACK OFF
ALTER USER hq DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
ALTER USER chicago DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
ALTER USER newyork DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
DROP TABLE chicago.stolen_life;
DROP TABLE newyork.stolen_life;
DROP TABLE hq.stolen_life;
DROP PUBLIC SYNONYM stolen_life;
DROP PUBLIC SYNONYM stolen_life;
SET ECHO ON FEEDBACK ON

/* Build the stolen lives table for Chicago. */
CONNECT chicago/chicago
@pl.sp

DROP TABLE stolen_life;

CREATE TABLE stolen_life (
   dod DATE,
   ethnicity VARCHAR2(100),
   victim VARCHAR2(100),
   age NUMBER,
   description VARCHAR2(2000),
   moreinfoat VARCHAR(200) DEFAULT 
      'http://www.unstoppable.com/22/english/stolenlivesPROJECT'
   );

INSERT INTO stolen_life (dod, ethnicity, victim, age, description) VALUES (
   '13-JAN-97', 'African-American', 'Bernard Solomon', 19,
   'After years of police harassment, Solomon was told by police that they would kill him. A few days later he was arrested. He was found hung in his cell at the 2259 S. Damen police station. Although police claim he hung himself with his shirt, when his body was examined by family members, he was found still wearing his shirt on one arm.');

INSERT INTO stolen_life (dod, ethnicity, victim, age, description) VALUES (
   '23-OCT-96', 'Puerto Rican', 'Angel Castro, Jr.', 15,
   'After being beaten, abused with racial epithets and told by police that he would be killed if he did not move, Angel Castro’s family moved. Angel returned to the neighborhood for a friend’s birthday party. After leaving the party, a police car rammed him as he rode his bike. As Angel tried to get on his knees, the police shot and killed him');

INSERT INTO stolen_life (dod, ethnicity, victim, age, description) VALUES (
   '09-APR-96', 'African-American', 'Eric Smith', 22,
   'Smith''s mom pulled her car off to the side of the expressway in order to better communicate with her son, a deaf mute. His grandmother was also in the car. Upset, Eric ran off into traffic and was grazed by a passing car. Two cops from Forest View, a Chicago suburb, pulled up. They trained a gun to Eric''s head and brought him to the side of the road. Eric''s attempts to sign were not understood. The cops beat Eric with metal batons and then shot him six times-including with hollow point bullets. The final bullet was delivered while Eric lay on his back. Following the shooting, Eric''s mother and grandmother were handcuffed and taken to the police station.');

/* Build the stolen lives table for New York */
CONNECT newyork/newyork
@pl.sp

DROP TABLE stolen_life;

CREATE TABLE stolen_life (
   dod DATE,
   ethnicity VARCHAR2(100),
   victim VARCHAR2(100),
   age NUMBER,
   description VARCHAR2(2000)
   );

INSERT INTO stolen_life (dod, ethnicity, victim, age, description) VALUES (
   '04-FEB-99', 'West African', 'Amadou Diallo', 22,
   'Shot 19 times by four police officers outside his Bronx apartment. Diallo was a devout Muslim working 12 hour days selling CDs and tapes to earn money to finish his bachelor''s degree. He was unarmed.');

INSERT INTO stolen_life (dod, ethnicity, victim, age, description) VALUES (
   '04-AUG-98', 'Puerto Rican', 'Freddie Rivera', 17,
   'Shot in the chest with dum-dum bullets and killed by an unidentified cop. The cop did not identify himself or yell Freeze!, Police!, Put your hands in the air!, or any such thing. His family described him as a bright kid, always looking forward to the future, who was about to start college in September.');

INSERT INTO stolen_life (dod, ethnicity, victim, age, description) VALUES (
   '24-APR-97', 'Latina', 'Sherly Colon', 33,
   'Sherly was pushed off the roof of the Clinton Houses, a housing project in East Harlem, by the police. She landed in a playground outside the building; witnesses said the police threw a sheet over her body and then removed handcuffs from behind her back; the cops claim they were removing her bracelets. Police claim she committed suicide by jumping, but neighbors and her mother do not believe this. There were several protest marches from the Clinton Houses to the 23rd Precinct in the week after Sherly was killed. She left behind two children, ages 5 and 14. Sherly was a community leader, well-known, well-liked, and respcted in the community.');

INSERT INTO stolen_life (dod, ethnicity, victim, age, description) VALUES (
   '31-JUL-98', 'NOT KNOWN', 'Christopher T. Johnson', 29,
   'Suffolk County Police Officers Robert A. McGee, Jr., and Samuel Barretto spotted Chistopher, who was wanted on charges of driving without a license (a misdemeanor), on Provost Avenue. The cops stepped out of their car and tried to arrest him at 9:43pm; Chris fled into the woods, and the officers chased after him, according to the police. He was sprayed with pepper Mace while being arrested, handcuffed, and brought out of the woods. He died as he was being transported to Brookhaven Memorial Hospital for treatment for the pepper Mace. Chris was an automobile mechanic, a married man with three children ranging in age from 15 months to 13 years. His family said he had no history of repiratory or other medical problems. His lawyer said, Mr. Johnson was not a rapist or a murderer, or anything of that nature. His only crime was using his car to get back and forth to work and getting food for his family. The police are investigating. The family said they would probably seek an independent autopsy.');

CONNECT hq/hq
@pl.sp

/* Create a "dummy" stolen lives table so that the analysis
   program will compile */

DROP TABLE stolen_life;

CREATE TABLE stolen_life (
   dod DATE,
   ethnicity VARCHAR2(100),
   victim VARCHAR2(100),
   age NUMBER,
   description VARCHAR2(2000)
   );

INSERT INTO stolen_life (dod, ethnicity, victim, age, description) VALUES (
   SYSDATE, 'N/A', 'HQ Table', 0,
   'All information is stored in city tables.');
   
/* Create a display program, run as DEFINER. */
CREATE OR REPLACE PROCEDURE show_victim (
   stolen_life IN stolen_life%ROWTYPE
   )
  AUTHID DEFINER
AS
BEGIN
   pl (stolen_life.victim);
   pl ('');
   pl (stolen_life.description);
   pl ('');
END;
/
SHOW ERRORS

/* Create a central analysis program, run as INVOKER. */
CREATE OR REPLACE PROCEDURE show_descriptions
  AUTHID CURRENT_USER
AS
BEGIN
  FOR lifestolen IN (SELECT * FROM stolen_life)
  LOOP
     show_victim (lifestolen);
  END LOOP;
END;
/
SHOW ERRORS

/* Grant execute to public and create public synonym */
GRANT EXECUTE ON show_descriptions TO PUBLIC;
DROP PUBLIC SYNONYM show_descriptions;
CREATE PUBLIC SYNONYM show_descriptions FOR show_descriptions;

CONNECT newyork/newyork
@ssoo
exec show_descriptions

CONNECT chicago/chicago
@ssoo
exec show_descriptions

/* Now let's put access to the stolen_life table INSIDE
   the DEFINER procedure. */
   
CONNECT hq/hq

/* Recreate a central analysis program, run as DEFINER. */
CREATE OR REPLACE PROCEDURE show_descriptions
  AUTHID DEFINER -- The default
AS
BEGIN
  FOR lifestolen IN (SELECT * FROM stolen_life)
  LOOP
     show_victim (lifestolen);
  END LOOP;
END;
/
SHOW ERRORS

/* Grant execute to public. */
GRANT EXECUTE ON show_descriptions TO PUBLIC;

CONNECT newyork/newyork
@ssoo
exec show_descriptions

CONNECT chicago/chicago
@ssoo
exec show_descriptions

SPOOL OFF

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
