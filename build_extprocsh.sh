#!/bin/sh

# Unix command script to create shared library file containing
# the extprocsh procedure.  Assumes presence of GNU C compiler.

gcc -c -I${ORACLE_HOME}/rdbms/demo -I${ORACLE_HOME}/rdbms/public extprocsh.c
gcc -shared -o extprocsh.so extprocsh.o


#======================================================================
# Supplement to the third edition of Oracle PL/SQL Programming by Steven
# Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
# Associates, Inc. To submit corrections or find more code samples visit
# http://www.oreilly.com/catalog/oraclep3/

