/*
IN parameters should end with _in.
OUT parameters should end with _out.
IN OUT parameters should end with _io.
*/

SELECT prog.name subprogram, parm.name parameter
  FROM all_identifiers parm, all_identifiers prog
 WHERE     parm.owner = USER
       AND parm.object_name = 'PLSCOPE_DEMO'
       AND parm.object_type = 'PACKAGE'
       AND prog.owner = parm.owner
       AND prog.object_name = parm.object_name
       AND prog.object_type = parm.object_type
       AND parm.usage_context_id = prog.usage_id
       AND parm.TYPE IN ('FORMAL IN', 'FORMAL IN OUT', 'FORMAL OUT')
       AND parm.usage = 'DECLARATION'
       AND ( (parm.TYPE = 'FORMAL IN'
              AND LOWER (parm.name) NOT LIKE '%\_in' ESCAPE '\')
            OR (parm.TYPE = 'FORMAL OUT'
                AND LOWER (parm.name) NOT LIKE '%\_out' ESCAPE '\')
            OR (parm.TYPE = 'FORMAL IN OUT'
                AND LOWER (parm.name) NOT LIKE '%\_io' ESCAPE '\'))
ORDER BY prog.name, parm.name
/
