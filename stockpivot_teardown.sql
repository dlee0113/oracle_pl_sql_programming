
exec UTL_FILE.FREMOVE('DIR','stocktable.dat');
DROP TABLE tickertable;
DROP TABLE stocktable;
DROP PACKAGE stockpivot_pkg;
DROP TYPE stockpivot_ntt;
DROP TYPE stockpivot_ot;
DROP DIRECTORY dir;

