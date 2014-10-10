REM MS Windows command script to create DLL for extprocsh external procedure
REM Assumes that Cygwin GNU C compiler is on the current PATH and that
REM ORACLE_HOME is c:\oracle\ora92

ECHO OFF

SET ORACLE_HOME=C:\oracle\ora92

ECHO LIBRARY extprocsh.dll > extprocsh.def
ECHO EXPORTS >> extprocsh.def
ECHO extprocsh >> extprocsh.def

gcc -c -I%ORACLE_HOME%\oci\include extprocsh.c
gcc -shared -o extprocsh.dll extprocsh.def extprocsh.o ^
   %ORACLE_HOME%\oci\lib\msvc\oci.lib

ECHO You will need to copy extprocsh.dll to somewhere Oracle can see it
ECHO For example:
ECHO    copy extprocsh.dll c:\oracle\admin\local\lib
ECHO (Assuming c:\oracle\admin\local\lib has been put in listener.ora
ECHO  EXTPROC_DLLS variable in ENVS of SID_DESC)


REM ======================================================================
REM Supplement to the third edition of Oracle PL/SQL Programming by Steven
REM Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
REM Associates, Inc. To submit corrections or find more code samples visit
REM http://www.oreilly.com/catalog/oraclep3/
