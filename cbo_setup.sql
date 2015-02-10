
CREATE TABLE departments
AS
   SELECT *
   FROM   hr.departments;

ALTER TABLE departments ADD
   CONSTRAINT departments_pk
   PRIMARY KEY (department_id);

CREATE TABLE employees
AS
   SELECT ROWNUM + 100000 AS employee_id
   ,      first_name
   ,      last_name
   ,      department_id
   FROM   hr.employees
   ,     (SELECT ROWNUM AS r FROM dual CONNECT BY ROWNUM <= 10000)
   WHERE  ROWNUM <= 50000;

ALTER TABLE employees ADD
   CONSTRAINT employees_pk
   PRIMARY KEY (employee_id);

ALTER TABLE employees ADD
   CONSTRAINT employees_fk01
   FOREIGN KEY (department_id)
   REFERENCES departments (department_id);

exec DBMS_STATS.GATHER_TABLE_STATS(USER, 'DEPARTMENTS', estimate_percent=>100);
exec DBMS_STATS.GATHER_TABLE_STATS(USER, 'EMPLOYEES', estimate_percent=>100);

CREATE TYPE employee_ot AS OBJECT
( employee_id    NUMBER(6)
, first_name     VARCHAR2(20)
, last_name      VARCHAR2(25)
, department_id  NUMBER(4)
);
/

CREATE TYPE employee_ntt AS TABLE OF employee_ot;
/

CREATE FUNCTION pipe_employees(
                p_cardinality IN INTEGER DEFAULT 1
                ) RETURN employee_ntt PIPELINED AS
BEGIN
   FOR r IN (SELECT * FROM employees) LOOP
      PIPE ROW (employee_ot(r.employee_id,
                            r.first_name,
                            r.last_name,
                            r.department_id));
   END LOOP;
   RETURN;
END pipe_employees;
/

CREATE TYPE pipelined_stats_ot AS OBJECT (

   dummy NUMBER,

   STATIC FUNCTION ODCIGetInterfaces (
                   p_interfaces OUT SYS.ODCIObjectList
                   ) RETURN NUMBER,

   STATIC FUNCTION ODCIStatsTableFunction (
                   p_function    IN  SYS.ODCIFuncInfo,
                   p_stats       OUT SYS.ODCITabFuncStats,
                   p_args        IN  SYS.ODCIArgDescList,
                   p_cardinality IN INTEGER
                   ) RETURN NUMBER
);
/

CREATE TYPE BODY pipelined_stats_ot AS

   STATIC FUNCTION ODCIGetInterfaces (
                   p_interfaces OUT SYS.ODCIObjectList
                   ) RETURN NUMBER IS
   BEGIN
      p_interfaces := SYS.ODCIObjectList(
                         SYS.ODCIObject ('SYS', 'ODCISTATS2')
                         );
      RETURN ODCIConst.success;
   END ODCIGetInterfaces;

   STATIC FUNCTION ODCIStatsTableFunction (
                   p_function    IN  SYS.ODCIFuncInfo,
                   p_stats       OUT SYS.ODCITabFuncStats,
                   p_args        IN  SYS.ODCIArgDescList,
                   p_cardinality IN INTEGER
                   ) RETURN NUMBER IS
   BEGIN
      p_stats := SYS.ODCITabFuncStats(NULL);
      p_stats.num_rows := p_cardinality;
      RETURN ODCIConst.success;
   END ODCIStatsTableFunction;

END;
/

