/*
Create views and the helper package for PL/Scope

Steven Feuerstein

*/

CREATE OR REPLACE VIEW plscope_pub_subprograms_v
AS
   SELECT *
     FROM all_identifiers ui
    WHERE     (ui.TYPE = 'FUNCTION' OR ui.TYPE = 'PROCEDURE')
          AND ui.owner <> 'SYS'
          AND ui.usage = 'DECLARATION'
          AND ui.object_type = 'PACKAGE'
/

CREATE OR REPLACE VIEW plscope_priv_subprograms_v
AS
   SELECT *
     FROM all_identifiers ui
    WHERE     (ui.TYPE = 'FUNCTION' OR ui.TYPE = 'PROCEDURE')
          AND owner <> 'SYS'
          AND usage = 'DEFINITION'
          AND ui.object_type = 'PACKAGE BODY'
          AND ui.signature NOT IN
                 (SELECT signature FROM plscope_pub_subprograms_v)
/

CREATE OR REPLACE VIEW plscope_pkg_declare_ends_v
AS
     SELECT owner, object_name, MIN (line) end_declares_line
       FROM (SELECT i.owner
                  , i.name
                  , i.TYPE
                  , i.usage
                  , s.line
                  , i.object_type
                  , i.object_name
                  , s.text source
               FROM all_identifiers i, all_source s
              WHERE     i.owner = s.owner
                    AND s.name = i.object_name
                    AND s.TYPE = i.object_type
                    AND s.line = i.line
                    AND i.object_type = 'PACKAGE BODY'
                    AND i.TYPE IN ('PROCEDURE', 'FUNCTION'))
   GROUP BY owner, object_name
/