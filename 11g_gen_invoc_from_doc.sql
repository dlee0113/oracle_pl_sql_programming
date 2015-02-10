/* Formatted on 2007/08/23 18:52 (Formatter Plus v4.8.8) */
CREATE TYPE person_typ AS OBJECT (
   idno    NUMBER,
   NAME    VARCHAR2 (30),
   phone   VARCHAR2 (20),
   MAP MEMBER FUNCTION get_idno
      RETURN NUMBER,
   MEMBER FUNCTION show
      RETURN VARCHAR2
)
NOT FINAL;
/

CREATE TYPE BODY person_typ
AS
   MAP MEMBER FUNCTION get_idno
      RETURN NUMBER
   IS
   BEGIN
      RETURN idno;
   END;
-- function that can be overriden by subtypes
   MEMBER FUNCTION show
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'Id: ' || TO_CHAR (idno) || ', Name: ' || NAME;
   END;
END;
/

CREATE TYPE student_typ UNDER person_typ (
   dept_id   NUMBER,
   major     VARCHAR2 (30),
   OVERRIDING MEMBER FUNCTION show
      RETURN VARCHAR2
)
NOT FINAL;
/

CREATE TYPE BODY student_typ
AS
   OVERRIDING MEMBER FUNCTION show
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (self AS person_typ).show || ' -- Major: ' || major ;
   END;
END;
/

DECLARE
   myvar   student_typ := student_typ (100, 'Sam', '6505556666', 100, 'Math');
   NAME    VARCHAR2 (100);
BEGIN
   NAME := (myvar AS person_typ).show; --Generalized invocation
END;
/