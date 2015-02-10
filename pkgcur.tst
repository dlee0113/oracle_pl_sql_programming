CREATE OR REPLACE PROCEDURE pkgcur_test1 (deptno_in IN INTEGER)
IS
   rec emp%ROWTYPE;
BEGIN
   /* Accessing the package cursor directly: OPEN and FETCH. */
   OPEN personnel.emps_for_dept (deptno_in);
   FETCH personnel.emps_for_dept INTO rec;
   p.l (rec.ename);
END;
/
CREATE OR REPLACE PROCEDURE pkgcur_test2
IS
   rec emp%ROWTYPE;
BEGIN
   /* Accessing the package cursor directly: JUST FETCH. */
   FETCH personnel.emps_for_dept INTO rec;
   p.l (rec.ename);
END;
/

/* Now try out the direct access method */
BEGIN
   pkgcur_test1 (10);
   pkgcur_test2;
   pkgcur_test2;

   CLOSE personnel.emps_for_dept;

   /* This will try to open twice, and raise an error. */
   pkgcur_test1 (20);
   pkgcur_test2;

   pkgcur_test1 (30);
   pkgcur_test2;

   /* And remember, it's STILL not closed. */
END;
/

/* Now try out the packaged procedures */
BEGIN
   personnel.open_emps_for_dept (10);
   pkgcur_test2;
   pkgcur_test2;

   personnel.close_emps_for_dept;

   /* Now my sequential opens will not cause a problem. */
   personnel.open_emps_for_dept (20);
   pkgcur_test2;

   personnel.open_emps_for_dept (30);
   pkgcur_test2;

   /* Don't forget to close... */
   personnel.close_emps_for_dept;
EXCEPTION
   WHEN OTHERS
   THEN
      /* Even or especially when an exception occurs... */
      personnel.close_emps_for_dept;
END;
/
