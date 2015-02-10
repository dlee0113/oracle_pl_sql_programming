CREATE OR REPLACE PROCEDURE business_as_usual (
   advertising_budget_in   IN       NUMBER
 , contributions_inout     IN OUT   NUMBER
 , merge_and_purge_on_in   IN       DATE DEFAULT SYSDATE
 , obscene_ceo_bonus_out   OUT      NUMBER
 , cut_corners_in          IN       VARCHAR2 DEFAULT 'WHENEVER POSSIBLE'
)
IS
BEGIN
   DBMS_OUTPUT.put_line (    'Merge and purge on '
                          || TO_CHAR ( merge_and_purge_on_in )
                        );
   DBMS_OUTPUT.put_line ( 'Cut corners ' || cut_corners_in );
   DBMS_OUTPUT.put_line ( 'The American Way?' || CHR ( 10 ));
   obscene_ceo_bonus_out := 100000000;

   IF cut_corners_in IS NOT NULL
   THEN
      -- Better build in some protection!
      contributions_inout := contributions_inout * 2;
   END IF;
END;
/

DECLARE
   l_ceo_payoff NUMBER;
   l_lobbying_dollars NUMBER := 100000;
BEGIN
   /* All positional notation */
   business_as_usual ( 50000000
                     , l_lobbying_dollars
                     , SYSDATE + 20
                     , l_ceo_payoff
                     , 'PAY OFF OSHA'
                     );
   /* All positional notation, minimum number of values */
   business_as_usual ( 50000000, l_lobbying_dollars, SYSDATE + 20, l_ceo_payoff );
   /* All named notation, original order. */
   business_as_usual ( advertising_budget_in      => 50000000
                     , contributions_inout        => l_lobbying_dollars
                     , merge_and_purge_on_in      => SYSDATE - 100
                     , obscene_ceo_bonus_out      => l_ceo_payoff
                     , cut_corners_in             => 'DISBAND OSHA'
                     );
   /* Skip all IN parameters with default values. */
   business_as_usual ( advertising_budget_in      => 50000000
                     , contributions_inout        => l_lobbying_dollars
                     , obscene_ceo_bonus_out      => l_ceo_payoff
                     );
   /* Change order with named notation, partial list. */
   business_as_usual ( obscene_ceo_bonus_out      => l_ceo_payoff
                     , merge_and_purge_on_in      => SYSDATE + 20
                     , advertising_budget_in      => 50000000
                     , contributions_inout        => l_lobbying_dollars
                     );
   /* Blend positional and named notation. You can start
      with positional, but once you switch to named
      notation, you can't go back to positional. */
   business_as_usual ( 50000000
                     , l_lobbying_dollars
                     , merge_and_purge_on_in      => SYSDATE + 200
                     , obscene_ceo_bonus_out      => l_ceo_payoff
                     );
END;
/
