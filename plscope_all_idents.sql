  SELECT i.*
       , s.line
       , s.text
    FROM    all_identifiers i
         JOIN
            user_source s
         ON (    s.name = i.object_name
             AND s.TYPE = i.object_type
             AND s.line = i.line)
   WHERE object_name = 'PLSCOPE_DEMO' AND owner = USER
ORDER BY CASE object_type
            WHEN 'PACKAGE' THEN 1
            WHEN 'PACKAGE BODY' THEN 2
            ELSE 3
         END
       , CASE
            WHEN TYPE = 'PACKAGE' THEN 1
            WHEN TYPE LIKE '%TYPE' THEN 2
            WHEN TYPE IN ('PROCEDURE', 'FUNCTION') THEN 3
            WHEN TYPE LIKE 'FORMAL%' THEN 4
         END
       , line