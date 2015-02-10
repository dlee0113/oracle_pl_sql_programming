SELECT *
  FROM    all_identifiers i
       JOIN
          user_source s
       ON (    s.name = i.object_name
           AND s.TYPE = i.object_type
           AND s.line = i.line)
 WHERE     i.owner = USER
       AND i.TYPE = 'VARIABLE'
       AND i.usage = 'DECLARATION'
       AND i.object_type = 'PACKAGE'