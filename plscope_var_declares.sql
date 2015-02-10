SELECT *
  FROM user_identifiers i
 WHERE     i.TYPE = 'VARIABLE'
       AND i.usage = 'DECLARATION'
/

/* Find all variables declared as fixed length */

SELECT i.object_name, i.name
  FROM user_identifiers i, user_identifiers it
 WHERE     i.TYPE = 'VARIABLE'
       AND it.name = 'CHAR'
       AND i.usage_id = it.usage_context_id
       AND i.object_name = it.object_name
       AND i.object_type = it.object_type
/