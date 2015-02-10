CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED "JFile" AS
import java.io.File;
public class JFile {
// Author: Steven Feuerstein

   // Notice that the actual values don''t matter one bit. 
   public static int tVal () { return 10009; };   
   public static int fVal () { return -18703; }; 
   
   public static String separator (String fileName) {
      File myFile = new File (fileName);
      return myFile.separator;
      }

   /* Also from Paul Sharples
   public static String separator () {
      return System.getProperty("file.separator");
   }
   */
   
   public static int canRead (String fileName) {
      File myFile = new File (fileName);
      boolean retval = myFile.canRead();
      if (retval) return tVal(); else return fVal();
      }

   public static int canWrite (String fileName) {
      File myFile = new File (fileName);
      boolean retval = myFile.canWrite();
      if (retval) return tVal(); else return fVal();
      }

   public static int exists (String fileName) {
      File myFile = new File (fileName);
      boolean retval = myFile.exists();
      if (retval) return tVal(); else return fVal();
      }

   public static int isDirectory (String fileName) {
      File myFile = new File (fileName);
      boolean retval = myFile.isDirectory();
      if (retval) return tVal(); else return fVal();
      }

   public static int isFile (String fileName) {
      File myFile = new File (fileName);
      boolean retval = myFile.isFile();
      if (retval) return tVal(); else return fVal();
      }

   public static long length (String fileName) {
      File myFile = new File (fileName);
      return myFile.length();
      }

   public static String parentDir (String fileName) {
      File myFile = new File (fileName);
      return myFile.getParent();
      }

   public static String pathName (String fileName) {
      File myFile = new File (fileName);
      return myFile.getPath();
      }

   public static long lastModified (String fileName) {
      File myFile = new File (fileName);
      return myFile.lastModified();
      }

   public static int delete (String fileName) {
      File myFile = new File (fileName);
      boolean retval = myFile.delete();
      if (retval) return tVal(); else return fVal();
      }

   public static int mkdir (String fileName) {
      File myFile = new File (fileName);
      boolean retval = myFile.mkdir();
      if (retval) return tVal(); else return fVal();
      }

   public static int rename (
         String oldFile, String newFile) {
      File myFile = new File (oldFile);
      File myFile2 = new File (newFile);
      boolean retval = myFile.renameTo(myFile2);
      if (retval) return tVal(); else return fVal();
      }
      
   /*
   public static oracle.sql.ARRAY dirContents (String dir) 
      throws SQLException, ClassNotFoundException {
      
      File myDir = new File (dir);
      String[] filesList = myDir.list();
      
      Class.forName("oracle.jdbc.driver.OracleDriver");
      Connection con = new OracleDriver().defaultConnection();
      
      ArrayDescriptor arrayDesc = 
         ArrayDescriptor.createDescriptor ("directory_t", con);
      oracle.sql.ARRAY filesArray = new oracle.sql.ARRAY (arrayDesc, con, filesList);
      
      return filesArray;
      }
   */

   // StringBuffer implementation from Tom Berthoff
   public static String dirContents (String dir, String delim) {
      File myDir = new File (dir);
      String[] filesList = myDir.list();
      StringBuffer contents = new StringBuffer();
      for (int i = 0; i < filesList.length; i++) {
          contents.append( delim );
          contents.append( filesList[i] );
      }      
         //contents = contents + delim + filesList[i]; // Utrecht 4/2002
      return contents.toString();
   }      
   public static void main (String[] args) {
      String contents = dirContents (args[0], args[1]);
      System.out.println (contents);
      /*
      try {
         oracle.sql.ARRAY filesArray = dirContents (args[0]);
         String[] files = (String[]) filesArray.getArray ();
         for (int i = 0; i <= files.length; i++) 
            System.out.println (files[i]);
         }
      catch ( SQLException e ) {
         System.out.println (e.getMessage());}
      catch ( ClassNotFoundException e ) {
         System.out.println ("ClassNotFoundException");}
      */
   }            
}
/
