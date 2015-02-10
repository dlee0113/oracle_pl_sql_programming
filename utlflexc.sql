--
-- This code helps you....
--
--   - Remember to close those files when you are done or when an error
--     finishes you prematurely.
--
--   - Identify which error caused the problem. Prior to Oracle9iR2, there
--     are no error numbers for those named exceptions, so if you don't
--     trap them by name, their individuality is lost.
--
DECLARE
   l_file_id   UTL_FILE.file_type;

   PROCEDURE cleanup (file_in IN OUT UTL_FILE.file_type, err_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      UTL_FILE.fclose (file_in);

      IF err_in IS NOT NULL
      THEN
         DBMS_OUTPUT.put_line ('UTL_FILE error encountered:');
         DBMS_OUTPUT.put_line (err_in);
      END IF;
   END cleanup;
BEGIN
   -- Body of program here

   -- Then clean up before exiting...
   cleanup (l_file_id);
EXCEPTION
   WHEN UTL_FILE.invalid_path
   THEN
      cleanup (l_file_id, 'invalid_path');
      RAISE;
   WHEN UTL_FILE.invalid_mode
   THEN
      cleanup (l_file_id, 'invalid_mode');
      RAISE;
   WHEN UTL_FILE.invalid_filehandle
   THEN
      cleanup (l_file_id, 'invalid_filehandle');
      RAISE;
   WHEN UTL_FILE.invalid_operation
   THEN
      cleanup (l_file_id, 'invalid_operation');
      RAISE;
   WHEN UTL_FILE.read_error
   THEN
      cleanup (l_file_id, 'read_error');
      RAISE;
   WHEN UTL_FILE.write_error
   THEN
      cleanup (l_file_id, 'write_error');
      RAISE;
   WHEN UTL_FILE.internal_error
   THEN
      cleanup (l_file_id, 'internal_error');
      RAISE;
   WHEN UTL_FILE.invalid_maxlinesize
   THEN
      cleanup (l_file_id, 'invalid_maxlinesize');
      RAISE;
   WHEN UTL_FILE.invalid_filename
   THEN
      cleanup (l_file_id, 'invalid_filename');
      RAISE;
   WHEN UTL_FILE.access_denied
   THEN
      cleanup (l_file_id, 'access_denied');
      RAISE;
   WHEN UTL_FILE.invalid_offset
   THEN
      cleanup (l_file_id, 'invalid_offset');
      RAISE;
   WHEN UTL_FILE.delete_failed
   THEN
      cleanup (l_file_id, 'delete_failed');
      RAISE;
   WHEN UTL_FILE.rename_failed
   THEN
      cleanup (l_file_id, 'rename_failed');
      RAISE;
   WHEN OTHERS
   THEN
      cleanup (l_file_id, SQLERRM);
      RAISE;
END;