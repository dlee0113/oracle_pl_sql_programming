SELECT i.*
  FROM all_identifiers i
 WHERE     i.owner = USER
       AND i.TYPE = 'VARIABLE'
       AND i.usage = 'DECLARATION'
       AND i.object_type = 'PACKAGE'
/