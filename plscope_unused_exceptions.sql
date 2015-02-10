WITH subprograms_with_exception
        AS (SELECT DISTINCT owner
                          , object_name
                          , object_type
                          , name
              FROM all_identifiers has_exc
             WHERE     has_exc.owner = USER
                   AND has_exc.usage = 'DECLARATION'
                   AND has_exc.TYPE = 'EXCEPTION'),
        subprograms_with_raise_handle
        AS (SELECT DISTINCT owner
                          , object_name
                          , object_type
                          , name
              FROM all_identifiers with_rh
             WHERE     with_rh.owner = USER
                   AND with_rh.usage = 'REFERENCE'
                   AND with_rh.TYPE = 'EXCEPTION')
   SELECT * FROM subprograms_with_exception
   MINUS
   SELECT * FROM subprograms_with_raise_handle
/