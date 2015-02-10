SELECT i.*, s.text
  FROM all_identifiers i, all_source s
 WHERE     s.owner <> 'SYS'
       AND s.owner = i.owner
       AND s.name = i.object_name
       AND s.TYPE = i.object_type
       AND s.line = i.line
       AND i.TYPE = 'VARIABLE'
       AND usage = 'ASSIGNMENT'