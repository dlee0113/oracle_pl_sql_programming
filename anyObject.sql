/*
| IN THIS SCRIPT:
|    create_a_type -- returns a transient object type
|    create_an_instance -- returns an instance of the type
|    grok_anydata -- shows how one might interpret the instance
|    anon block -- demo of these pieces working together
*/


/* 
| Function create_a_type creates a simple transient type with a couple
| of attributes.  It returns a type descriptor object of type ANYTYPE.
| Note: Oracle9i Release 1 uses SYS.ANYTYPE and SYS.ANYDATA, but 
| Release 2 supports synonyms on object types, so we can drop the "SYS"
| prefix.
*/

CREATE OR REPLACE FUNCTION create_a_type
   RETURN ANYTYPE
AS
   myany ANYDATA;
   mytype ANYTYPE;
BEGIN
   /* Create (anonymous) transient type with two attributes: number, date */
   ANYTYPE.BeginCreate(typecode => DBMS_TYPES.TYPECODE_OBJECT, atype => mytype);
   mytype.AddAttr(typecode => DBMS_TYPES.TYPECODE_NUMBER, aname => 'just_a_number',
      prec => 38, scale => 0, len => NULL, csid => NULL, csfrm => NULL);
   mytype.AddAttr(typecode => DBMS_TYPES.TYPECODE_DATE, aname => 'just_a_date',
      prec => NULL, scale => NULL, len => NULL, csid => NULL, csfrm => NULL);
   mytype.EndCreate;
   RETURN mytype;
END;
/

SHOW ERRORS

/*
| Here is an example of how to invoke create_a_type and instantiate a
| corresponding ANYDATA.  This assumes that you happen to know the
| attributes of the transient type output by create_a_type.
*/
CREATE OR REPLACE FUNCTION create_an_instance (which_type IN ANYTYPE,
   att1 IN NUMBER DEFAULT 0, att2 IN DATE DEFAULT SYSDATE)
   RETURN ANYDATA
AS
   l_type ANYTYPE := which_type;
   l_any ANYDATA;
BEGIN
   ANYDATA.BeginCreate(dtype => l_type, adata => l_any);
   l_any.SetNumber(num => att1);
   l_any.SetDate(dat => att2);
   l_any.EndCreate;
   RETURN l_any;
END;
/

SHOW ERRORS

/*
| If you have an ANYDATA and its ANYTYPE, you could do something like this
| next procedure, grok_anydata, to attempt to interpret the data.
*/
CREATE OR REPLACE PROCEDURE grok_anydata (which_type IN ANYTYPE,
   which_data IN ANYDATA)
AS
   ltype ANYTYPE := which_type;
   lany ANYDATA := which_data;
   typeid PLS_INTEGER;
   attr_typeid PLS_INTEGER;
   lattr_elt_type ANYTYPE;
   lprec PLS_INTEGER;
   lscale PLS_INTEGER;
   llen PLS_INTEGER;
   lcsid PLS_INTEGER;
   lcsfrm PLS_INTEGER;
   lschema_name VARCHAR2(30);
   ltype_name VARCHAR2(30);
   lversion VARCHAR2(30);
   lcount PLS_INTEGER;
   laname VARCHAR2(30);
   result_code PLS_INTEGER;
   some_number NUMBER;
   some_string VARCHAR2(32767);
   some_date DATE;
BEGIN
   /* Discover the type code of a transient object */
   typeid := lany.GetType(typ => ltype);

   /* For an object type, lcount will give the number of attrs */
   typeid := ltype.GetInfo (lprec, lscale, llen, lcsid, lcsfrm, lschema_name,
                ltype_name, lversion, lcount);

   lany.PieceWise;
   FOR pos IN 1..lcount
   LOOP
      attr_typeid := ltype.GetAttrElemInfo(pos, lprec, lscale, llen, lcsid,
         lcsfrm, lattr_elt_type, laname);
      DBMS_OUTPUT.PUT_LINE('Attribute ' || pos || ': ' || laname
         || ' (type ' || attr_typeid || ')');

      /* This CASE statement is incomplete -- need to deal with a lot more
      || types, possibly collections and object types
      */
      CASE attr_typeid
         WHEN DBMS_TYPES.TYPECODE_NUMBER THEN
            result_code := lany.GetNumber(some_number);
            DBMS_OUTPUT.PUT_LINE(some_number);
         WHEN DBMS_TYPES.TYPECODE_VARCHAR2 THEN
            result_code := lany.GetVarchar2(some_string);
            DBMS_OUTPUT.PUT_LINE(some_string);
         WHEN DBMS_TYPES.TYPECODE_DATE THEN
            result_code := lany.GetDate(some_date);
            DBMS_OUTPUT.PUT_LINE(TO_CHAR(some_date, 'YYYY-MM-DD hh24:mi:ss'));
         ELSE
            NULL;
      END CASE;
   END LOOP;
END;
/
SHOW ERR

/*
| So, finally, here is what it might look like in action.  Well, it's really
| a contrived example, because obviously I know the structure of the type
| in advance. But you get the idea!
*/
DECLARE
   l_type ANYTYPE := create_a_type;
   l_any ANYDATA := create_an_instance(l_type, 3.14159, SYSDATE);
BEGIN
   grok_anydata(l_type, l_any);
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
