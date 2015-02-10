SELECT object_name, object_type, status
  FROM user_objects
 WHERE status = 'INVALID'
 /