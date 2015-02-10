DECLARE
   TYPE clientele IS TABLE OF VARCHAR2 (64);

   client_list_1 clientele := clientele ('Customer 1', 'Customer 2');
   client_list_2 clientele := clientele ('Customer 1', 'Customer 3');
BEGIN
$IF DBMS_DB_VERSION.VER_LE_10_1
$THEN
   -- Perform "brute force" comparison
   IF clienteles_equal (client_list_1, client_list_2)
   THEN
      merge_client_info (client_list_1, client_list_2);
   END IF;
$ELSE
   -- Compare using equals operator
   IF client_list_1 = client_list_2
   THEN
      merge_client_info (client_list_1, client_list_2);
   END IF;
$END
END;
/

