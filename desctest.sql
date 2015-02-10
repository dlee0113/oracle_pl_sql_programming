/* Formatted on 2002/09/20 11:35 (Formatter Plus v4.5.2) */
DROP TYPE numtab FORCE;
DROP TYPE datearray FORCE;
DROP TYPE hiredatetab FORCE;
DROP TYPE obj_t FORCE;

CREATE TYPE numtab IS TABLE OF NUMBER;
/
CREATE TYPE datearray IS VARRAY (10) OF DATE;
/
CREATE TYPE hiredatetab IS TABLE OF DATE;
/
CREATE TYPE obj_t AS OBJECT (
   starttime                     INTEGER,
   endtime                       INTEGER,
   repetitions                   INTEGER,
   NAME                          VARCHAR2 (2000),
   srcinfo                       numtab);

/
SHO err
CREATE OR REPLACE PACKAGE desctest
IS
   TYPE aa_rowtype IS TABLE OF employee%ROWTYPE
      INDEX BY varchar2(200);

   TYPE aa_type IS TABLE OF employee%ROWTYPE
      INDEX BY employee.last_name%TYPE;

   -- SEQUENCE 0 ARGUMENT_NAME NULL
   PROCEDURE prog1;

   PROCEDURE prog2 (arg1 IN VARCHAR2, arg2 IN DATE);

   PROCEDURE prog2 (
      arg1   IN   VARCHAR2,
      arg2   IN   INTEGER,
      arg3        all_objects%ROWTYPE
   );

   PROCEDURE prog3 (
      arg1   IN OUT   numtab,
      arg2   OUT      datearray,
      arg3            obj_t,
      arg4   IN       aa_rowtype,
      arg5   IN       aa_type
   );

   -- RETURN datatype: argument_name null, position 0
   FUNCTION func1
      RETURN INTEGER;

   FUNCTION func2 (arg1 IN INTEGER)
      RETURN BOOLEAN;

   FUNCTION func2 (arg1 IN DATE, arg2 IN NUMBER)
      RETURN all_objects%ROWTYPE;

   FUNCTION func3
      RETURN obj_t;

   FUNCTION func4
      RETURN hiredatetab;

   FUNCTION func5
      RETURN aa_type;
END;
/

COLUMN overload heading OVLD format a4
COLUMN object_name format a15
COLUMN argument_name format a15
COLUMN data_type format a25
COLUMN position heading POS format 999 
COLUMN sequence heading SEQ format 999
COLUMN data_level heading LVL format 999
BREAK ON object_name SKIP 1
SET PAGESIZE 66  
SELECT object_name, argument_name, overload, position, SEQUENCE, data_level,
       data_type
  FROM all_arguments
 WHERE owner = USER AND package_name = UPPER ('&&firstparm')
/

/* The output:
OBJECT_NAME     ARGUMENT_NAME   OVLD  POS  SEQ  LVL DATA_TYPE
--------------- --------------- ---- ---- ---- ---- -------------------------
PROG1                                   1    0    0

OBJECT_NAME     ARGUMENT_NAME   OVLD  POS  SEQ  LVL DATA_TYPE
--------------- --------------- ---- ---- ---- ---- -------------------------
PROG2           ARG1            1       1    1    0 VARCHAR2
                ARG2            1       2    2    0 DATE
                ARG1            2       1    1    0 VARCHAR2
                ARG2            2       2    2    0 NUMBER
                ARG3            2       3    3    0 PL/SQL RECORD
                OWNER           2       1    4    1 VARCHAR2
                OBJECT_NAME     2       2    5    1 VARCHAR2
                SUBOBJECT_NAME  2       3    6    1 VARCHAR2
                OBJECT_ID       2       4    7    1 NUMBER
                DATA_OBJECT_ID  2       5    8    1 NUMBER
                OBJECT_TYPE     2       6    9    1 VARCHAR2
                CREATED         2       7   10    1 DATE
                LAST_DDL_TIME   2       8   11    1 DATE
                TIMESTAMP       2       9   12    1 VARCHAR2
                STATUS          2      10   13    1 VARCHAR2
                TEMPORARY       2      11   14    1 VARCHAR2
                GENERATED       2      12   15    1 VARCHAR2
                SECONDARY       2      13   16    1 VARCHAR2

OBJECT_NAME     ARGUMENT_NAME   OVLD  POS  SEQ  LVL DATA_TYPE
--------------- --------------- ---- ---- ---- ---- -------------------------
PROG3           ARG1                    1    1    0 TABLE
                ARG2                    2    2    0 VARRAY
                ARG3                    3    3    0 OBJECT
                ARG4                    4    4    0 PL/SQL TABLE
                                        1    5    1 PL/SQL RECORD
                EMPLOYEE_ID             1    6    2 NUMBER
                LAST_NAME               2    7    2 VARCHAR2
                FIRST_NAME              3    8    2 VARCHAR2
                MIDDLE_INITIAL          4    9    2 VARCHAR2
                JOB_ID                  5   10    2 NUMBER
                MANAGER_ID              6   11    2 NUMBER
                HIRE_DATE               7   12    2 DATE
                SALARY                  8   13    2 NUMBER
                COMMISSION              9   14    2 NUMBER
                DEPARTMENT_ID          10   15    2 NUMBER
                EMPNO                  11   16    2 NUMBER
                ENAME                  12   17    2 VARCHAR2
                CREATED_BY             13   18    2 VARCHAR2
                CREATED_ON             14   19    2 DATE
                CHANGED_BY             15   20    2 VARCHAR2
                CHANGED_ON             16   21    2 DATE
                ARG5                    5   22    0 PL/SQL TABLE
                                        1   23    1 PL/SQL RECORD
                EMPLOYEE_ID             1   24    2 NUMBER
                LAST_NAME               2   25    2 VARCHAR2
                FIRST_NAME              3   26    2 VARCHAR2
                MIDDLE_INITIAL          4   27    2 VARCHAR2
                JOB_ID                  5   28    2 NUMBER
                MANAGER_ID              6   29    2 NUMBER
                HIRE_DATE               7   30    2 DATE
                SALARY                  8   31    2 NUMBER
                COMMISSION              9   32    2 NUMBER
                DEPARTMENT_ID          10   33    2 NUMBER
                EMPNO                  11   34    2 NUMBER
                ENAME                  12   35    2 VARCHAR2
                CREATED_BY             13   36    2 VARCHAR2
                CREATED_ON             14   37    2 DATE
                CHANGED_BY             15   38    2 VARCHAR2
                CHANGED_ON             16   39    2 DATE

OBJECT_NAME     ARGUMENT_NAME   OVLD  POS  SEQ  LVL DATA_TYPE
--------------- --------------- ---- ---- ---- ---- -------------------------
FUNC1                                   0    1    0 NUMBER

OBJECT_NAME     ARGUMENT_NAME   OVLD  POS  SEQ  LVL DATA_TYPE
--------------- --------------- ---- ---- ---- ---- -------------------------
FUNC2                           1       0    1    0 PL/SQL BOOLEAN
                ARG1            1       1    2    0 NUMBER
                                2       0    1    0 PL/SQL RECORD
                OWNER           2       1    2    1 VARCHAR2
                OBJECT_NAME     2       2    3    1 VARCHAR2
                SUBOBJECT_NAME  2       3    4    1 VARCHAR2
                OBJECT_ID       2       4    5    1 NUMBER
                DATA_OBJECT_ID  2       5    6    1 NUMBER
                OBJECT_TYPE     2       6    7    1 VARCHAR2
                CREATED         2       7    8    1 DATE
                LAST_DDL_TIME   2       8    9    1 DATE
                TIMESTAMP       2       9   10    1 VARCHAR2
                STATUS          2      10   11    1 VARCHAR2
                TEMPORARY       2      11   12    1 VARCHAR2
                GENERATED       2      12   13    1 VARCHAR2
                SECONDARY       2      13   14    1 VARCHAR2
                ARG1            2       1   15    0 DATE
                ARG2            2       2   16    0 NUMBER

OBJECT_NAME     ARGUMENT_NAME   OVLD  POS  SEQ  LVL DATA_TYPE
--------------- --------------- ---- ---- ---- ---- -------------------------
FUNC3                                   0    1    0 OBJECT

OBJECT_NAME     ARGUMENT_NAME   OVLD  POS  SEQ  LVL DATA_TYPE
--------------- --------------- ---- ---- ---- ---- -------------------------
FUNC4                                   0    1    0 TABLE

OBJECT_NAME     ARGUMENT_NAME   OVLD  POS  SEQ  LVL DATA_TYPE
--------------- --------------- ---- ---- ---- ---- -------------------------
FUNC5                                   0    1    0 PL/SQL TABLE
                                        1    2    1 PL/SQL RECORD
                EMPLOYEE_ID             1    3    2 NUMBER
                LAST_NAME               2    4    2 VARCHAR2
                FIRST_NAME              3    5    2 VARCHAR2
                MIDDLE_INITIAL          4    6    2 VARCHAR2
                JOB_ID                  5    7    2 NUMBER
                MANAGER_ID              6    8    2 NUMBER
                HIRE_DATE               7    9    2 DATE
                SALARY                  8   10    2 NUMBER
                COMMISSION              9   11    2 NUMBER
                DEPARTMENT_ID          10   12    2 NUMBER
                EMPNO                  11   13    2 NUMBER
                ENAME                  12   14    2 VARCHAR2
                CREATED_BY             13   15    2 VARCHAR2
                CREATED_ON             14   16    2 DATE
                CHANGED_BY             15   17    2 VARCHAR2
                CHANGED_ON             16   18    2 DATE
*/