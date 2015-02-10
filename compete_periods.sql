  SELECT *
    FROM qdb_compete_periods
   WHERE comp_player_id =
            (SELECT comp_player_id
               FROM qdb_comp_players
              WHERE user_id = 22717 AND competition_id = 1)
ORDER BY create@d_on DESC
/

UPDATE qdb_compete_periods cp
   SET CP.ENDS_ON = NULL
 WHERE cp.compete_period_id = 40378
/

DELETE FROM qdb_compete_periods cp
      WHERE     cp.compete_period_id > 40378
            AND comp_player_id =
                   (SELECT comp_player_id
                      FROM qdb_comp_players
                     WHERE     user_id = 22717
                           AND competition_id = 1)
/