/*
   Build by Vadim Loevski of Quest Software.
*/   
CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED " UTLcmd" AS
import java.lang.Runtime;
public class UTLcmd
{
  public static void execute (String command)
  {
   try
      {
       Runtime rt = java.lang.Runtime.getRuntime();
       rt.exec(command);
      }
   catch(Exception e)
   {
    System.out.println(e.getMessage());
    return;
   }
  }
}
/
CREATE OR REPLACE PACKAGE UTLcmd IS
  PROCEDURE execute (cmd IN VARCHAR2) AS LANGUAGE JAVA NAME
           'UTLcmd.execute(java.lang.String)';
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
