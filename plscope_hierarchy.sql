WITH plscope_hierarchy
        AS (SELECT line
                 , col
                 , name
                 , TYPE
                 , usage
                 , usage_id
                 , usage_context_id
              FROM all_identifiers
             WHERE     owner = USER
                   AND object_name = 'PLSCOPE_DEMO'
                   AND object_type = 'PACKAGE BODY')
SELECT    LPAD (' ', 3 * (LEVEL - 1))
       || TYPE
       || ' '
       || name
       || ' ('
       || usage
       || ')'
          identifier_hierarchy
  FROM plscope_hierarchy
START WITH usage_context_id = 0
CONNECT BY PRIOR usage_id = usage_context_id
ORDER SIBLINGS BY line, col