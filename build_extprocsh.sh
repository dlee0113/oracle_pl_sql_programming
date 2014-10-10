#!/bin/sh

# Unix command script to create shared library file containing
# the extprocsh procedure.  Assumes presence of GNU C compiler.

gcc -c -I${ORACLE_HOME}/rdbms/demo -I${ORACLE_HOME}/rdbms/public extprocsh.c
gcc -shared -o extprocsh.so extprocsh.o




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
