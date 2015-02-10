import java.sql.*;

public class book
{
   public static void main(String[] args) throws SQLException
   {
      // initialize the driver and try to make a connection

      DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver ( ));
      Connection conn =
         DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:o92",
                                     "scott", "tiger");

      // prepareCall uses ANSI92 "call" syntax
      CallableStatement cstmt = conn.prepareCall("{? = call booktitle(?)}");

      // get those bind variables and parameters set up
      cstmt.registerOutParameter(1, Types.VARCHAR);
      cstmt.setString(2, "0-596-00180-0");

      // now we can do it, get it, close it, and print it
      cstmt.executeUpdate( );
      String bookTitle = cstmt.getString(1);
      conn.close( );
      System.out.println(bookTitle);
   }
}


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
