CREATE or REPLACE JAVA SOURCE NAMED "DeleteFile" AS

import java.io.*;
import java.sql.*;
import oracle.jdbc.driver.*;
import oracle.sql.*;
import java.util.Date;
import java.text.*;
import java.text.DateFormat.*;

/*
 ** Delete files in specified directories that were last modified before 
 ** a specified date
 */
public class DeleteFile {
    
    public static int delete(oracle.sql.ARRAY tbl) throws SQLException {
        try {
            
            
            // Retrieve the contents of the table/varray as a result set
            ResultSet rs = tbl.getResultSet();
            
            // Iterate through the rows returned by the result set
            // NOTE: The JDBC 2.0 standard specifies that the ResultSet
            //       contains rows consisting of two columns.
            //
            //       Column 1 stores the element index for the row.
            //       Column 2 stores the actual element value.
            //
            for (int ndx = 0; ndx < tbl.length(); ndx++) {
                rs.next();
                
                // Retrieve the array index
                int aryndx = (int)rs.getInt(1);
                
                // Retrieve the array element (an object returned as type STRUCT)
                STRUCT obj = (STRUCT)rs.getObject(2);
                
                // Retrieve the attributes for the object
                // as an array of Java Objects
                Object[] attrs = obj.getAttributes();
                
                // Retrieve the individual attributes
                // casting the object to the correct type
                String    fileDir  = (String)attrs[0];
                Timestamp saveDate = (java.sql.Timestamp)attrs[1];

                // Check that the directory exists
                if (new File (fileDir).isDirectory()) {
                    // Retrive a list of the files in the specified directory
                    String[] filesList = new File (fileDir).list();
                    // Loop through the files checking which ones are older then the date specified
                    for (int i = 0; i < filesList.length; i++) {
                        String fullPathName = fileDir + "\\"+filesList[i];
                        if (lastModified(fullPathName) < saveDate.getTime()) {
                            delete(fullPathName);
                        }
                    }
                } 
            }
            // Close the result set
            rs.close();
            return 0;

        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
  }
  
   public static long lastModified (String fileName) {
      return new File (fileName).lastModified();
      }

   public static int delete (String fileName) {
      return bln2int (new File (fileName).delete());
      }
   public static int bln2int (boolean valIn) {
     if (valIn) return 1; else return 0;
   }
}

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
