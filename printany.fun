CREATE OR REPLACE FUNCTION printany (adata IN ANYDATA)
   RETURN VARCHAR2
AS
   aType ANYTYPE;
   retval VARCHAR2(32767);
   result_code PLS_INTEGER;
BEGIN
   CASE adata.GetType(aType)
   WHEN DBMS_TYPES.TYPECODE_NUMBER THEN
      RETURN 'NUMBER: ' || TO_CHAR(adata.AccessNumber);
   WHEN DBMS_TYPES.TYPECODE_VARCHAR2 THEN
      RETURN 'VARCHAR2: ' || adata.AccessVarchar2;
   WHEN DBMS_TYPES.TYPECODE_CHAR THEN
      RETURN 'CHAR: ' || RTRIM(adata.AccessChar);
   WHEN DBMS_TYPES.TYPECODE_DATE THEN
      RETURN 'DATE: ' || TO_CHAR(adata.AccessDate, 'YYYY-MM-DD hh24:mi:ss');
   WHEN DBMS_TYPES.TYPECODE_OBJECT THEN
      EXECUTE IMMEDIATE 'DECLARE ' ||
                        '   myobj ' || adata.GetTypeName || '; ' ||
                        '   myad sys.ANYDATA := :ad; ' ||
                        'BEGIN ' ||
                        '   :res := myad.GetObject(myobj); ' ||
                        '   :ret := myobj.print(); ' ||
                        'END;'
                        USING IN adata, OUT result_code, OUT retval;
      retval := adata.GetTypeName || ': ' || retval;
   WHEN DBMS_TYPES.TYPECODE_REF THEN
      EXECUTE IMMEDIATE 'DECLARE ' ||
                        '   myref ' || adata.GetTypeName || '; ' ||
                        '   myobj ' || SUBSTR(adata.GetTypeName,
                                       INSTR(adata.GetTypeName, ' ')) || '; ' ||
                        '   myad sys.ANYDATA := :ad; ' ||
                        'BEGIN ' ||
                        '   :res := myad.GetREF(myref); ' ||
                        '   UTL_REF.SELECT_OBJECT(myref, myobj);' ||
                        '   :ret := myobj.print(); ' ||
                        'END;'
                        USING IN adata, OUT result_code, OUT retval;
      retval := adata.GetTypeName || ': ' || retval;
   ELSE
      retval := '<data of type ' || adata.GetTypeName ||'>';
   END CASE;

   RETURN retval;

EXCEPTION
   WHEN OTHERS
   THEN
      IF INSTR(SQLERRM, 'component ''PRINT'' must be declared') > 0
      THEN
         RETURN adata.GetTypeName || ': <no print() function>';
      ELSE
         RETURN 'Error: ' || SQLERRM;
      END IF;
END;
/

SHOW ERR


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
