/*
   Build by Vadim Loevski of Quest Software.
*/   
CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED "UTLZip" AS
import java.util.zip.*;
import java.io.*;
public class UTLZip
{
 public static void compressFile(String infilename, String outfilename)
 {
  try
    {
     FileOutputStream fout = new FileOutputStream(outfilename);
     ZipOutputStream zout = new ZipOutputStream(fout);
     ZipEntry ze = new ZipEntry((new File(infilename)).getName());
     try 
       {
        FileInputStream fin = new FileInputStream(infilename);
        zout.putNextEntry(ze);
        copy(fin, zout);
        zout.closeEntry();
        fin.close();
       }
     catch (IOException ie)
     {
      System.out.println("IO Exception occurred: " + ie);
     }
     zout.close();
    }
  catch(Exception e)
    {
     System.out.println("Exception occurred: " + e);
    }
 }
  
 public static void copy(InputStream in, OutputStream out) 
      throws IOException
 { 
  byte[] buffer = new byte[4096];
  while (true) {
    int bytesRead = in.read(buffer);
    if (bytesRead == -1) break;
    out.write(buffer, 0, bytesRead);
  }
 }     
}

/
CREATE OR REPLACE PACKAGE UTLZip
IS
   PROCEDURE compressFile (p_in_file IN VARCHAR2, p_out_file IN VARCHAR2)
   AS
      LANGUAGE JAVA
         NAME 'UTLZip.compressFile(java.lang.String, 
                   java.lang.String)';
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
