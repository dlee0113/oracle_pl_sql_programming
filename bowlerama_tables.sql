/*-- bowlerama_tables.sql */

CREATE TABLE frame
(
   bowler_id      NUMBER
 , game_id        NUMBER
 , frame_number   NUMBER
 , strike         VARCHAR2 (1) DEFAULT 'N'
 , spare          VARCHAR2 (1) DEFAULT 'N'
 , score          NUMBER
 , CONSTRAINT frame_pk PRIMARY KEY (bowler_id, game_id, frame_number)
);

CREATE TABLE frame_audit
(
   bowler_id      NUMBER
 , game_id        NUMBER
 , frame_number   NUMBER
 , old_strike     VARCHAR2 (1)
 , new_strike     VARCHAR2 (1)
 , old_spare      VARCHAR2 (1)
 , new_spare      VARCHAR2 (1)
 , old_score      NUMBER
 , new_score      NUMBER
 , change_date    DATE
 , operation      VARCHAR2 (6)
);




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
