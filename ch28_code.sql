/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 28

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

/*
gcc -m64 extprocsh.c -fPIC -G -o extprocsh.so

c:\MinGW\bin\gcc extprocsh.c -shared -o extprocsh.dll
*/
CREATE OR REPLACE LIBRARY extprocshell_lib
       AS '/u01/app/oracle/local/lib/extprocsh.so'
/

CREATE OR REPLACE LIBRARY extprocshell_lib
       AS 'c:\oracle\local\lib\extprocsh.dll'
/


CREATE OR REPLACE FUNCTION shell (cmd IN VARCHAR2)
   RETURN PLS_INTEGER
AS
   LANGUAGE C
   LIBRARY extprocshell_lib
   NAME "extprocshell"
   PARAMETERS (cmd string, RETURN int);
/

DECLARE
   result   PLS_INTEGER;
BEGIN
   result := shell ('cmd');
END;
/

/*

    ### regular listener (to connect to the database)
     
    LISTENER =
       (ADDRESS = (PROTOCOL = TCP)(HOST = hostname)(PORT = 1521))

    SID_LIST_LISTENER =
       (SID_DESC =
          (GLOBAL_DBNAME = global_name)
          (ORACLE_HOME = oracle_home_directory)
          (SID_NAME = SID)
       )

    #### external procedure listener
     
    EXTPROC_LISTENER =
       (ADDRESS = (PROTOCOL = IPC)(KEY = extprocKey))

    SID_LIST_EXTPROC_LISTENER =
       (SID_DESC =
          (SID_NAME = extprocSID)
          (ORACLE_HOME = oracle_home_directory)
          (ENVS="EXTPROC_DLLS=shared_object_file_list,other_envt_vars")
          (PROGRAM = extproc)
       )

*/

/*
    (ENVS="EXTPROC_DLLS=ONLY:/u01/app/oracle/local/lib/extprocsh.so:/u01/app/oracle/
local/lib/RawdataToPrinter.so")


    (ENVS="EXTPROC_DLLS=ONLY:c:\oracle\admin\local\lib\extprocsh.dll:c:\oracle\admin\
    local\lib\RawDataToPrinter.dll")
    
    (ENVS="EXTPROC_DLLS=shared_object_file_list,LD_LIBRARY_PATH=/usr/local/lib")

*/

/*

    EXTPROC_CONNECTION_DATA =
       (DESCRIPTION =
          (ADDRESS = (PROTOCOL = IPC)(KEY = extprocKey))
          (CONNECT_DATA = (SID = extprocSID) (PRESENTATION = RO))
       )

    EXTPROC_CONNECTION_DATA =
       (DESCRIPTION_LIST =
          (LOAD_BALANCE = TRUE)
          (DESCRIPTION =
             (ADDRESS = (PROTOCOL = IPC)(KEY = PNPKEY))
             (CONNECT_DATA = (SID = PLSExtProc_001)(PRESENTATION = RO))
          )
          (DESCRIPTION =
             (ADDRESS = (PROTOCOL = ipc)(key = PNPKEY))
             (CONNECT_DATA = (SID = PLSExtProc_002)(PRESENTATION = RO))
          )
       )

*/

CREATE LIBRARY extprocshell_lib AS '${ORACLE_HOME}/lib/extprocsh.so'
/

CREATE LIBRARY extprocshell_lib AS '%{ORACLE_HOME}%\bin\extprocsh.dll'
/

CREATE OR REPLACE FUNCTION shell (cmd IN VARCHAR2)
   RETURN PLS_INTEGER
AS
   LANGUAGE C
   LIBRARY extprocshell_lib
   NAME "extprocsh"
   PARAMETERS (cmd string, cmd INDICATOR, RETURN INDICATOR, RETURN int);
/

CREATE OR REPLACE FUNCTION shell (cmd IN VARCHAR2)
   RETURN PLS_INTEGER
AS
   LANGUAGE C
   LIBRARY extprocshell_lib
   NAME "extprocsh"
   PARAMETERS (cmd string, cmd INDICATOR, RETURN INDICATOR);
/

/*

1    #include <ociextp.h>
2     
3    int extprocsh(char *cmd, short cmdInd, short *retInd)
4    {
5       if (cmdInd == OCI_IND_NOTNULL)
6       {
7          *retInd = (short)OCI_IND_NOTNULL;
8          return system(cmd);
9       } else
10       {
11          *retInd = (short)OCI_IND_NULL;
12          return 0;
13       }
14    }

    gcc -m64 extprocsh.c -fPIC -G -I$ORACLE_HOME/rdbms/public -o extprocsh.so

    c:\MinGW\bin\gcc -Ic:\oracle\product\10.2.0\db_1\oci\include extprocsh.c
    -shared -o extprocsh.dll

*/

CREATE OR REPLACE PROCEDURE shell2 (name_of_agent IN VARCHAR2, cmd VARCHAR2)
AS
   LANGUAGE C
   LIBRARY extprocshell_lib
   NAME "extprocsh2"
   AGENT IN (name_of_agent)
   WITH CONTEXT
   PARAMETERS (CONTEXT, name_of_agent string, cmd string, cmd INDICATOR);
/

/*

    void extprocsh2(OCIExtProcContext *ctx, char *agent, char *cmd, short cmdInd)
    {
       extprocsh(ctx, cmd, cmdInd);
    }

*/