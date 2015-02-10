/*
  ||
  || Demonstration of mutating tables and triggers
  ||
  || The first section demonstrates a failure
  || in 7.3.x but not later versions.
  ||
  || The second section demonstrates a package and
  || trigger combination to avoid the problem in
  || 7.3.x (and later versions).
  ||
  || The third section details the last remaining vestige
  || of mutating tables, ON DELETE CASCADE foreign keys.
  ||
  || The fourth section shows how even the ON DELETE CASCADE
  || situation can be avoided with an AUTONOMOUS transaction
  || in Oracle 8.1
  ||
*/
DROP TABLE account_transaction;
DROP TABLE account;

DROP SEQUENCE account_transaction_seq;

CREATE TABLE account
(account_id    NUMBER       NOT NULL PRIMARY KEY,
 account_owner VARCHAR2(30) NOT NULL);

CREATE TABLE account_transaction
(transaction_id     NUMBER NOT NULL PRIMARY KEY,
 account_id         NUMBER NOT NULL,
 transaction_type   VARCHAR2(3) NOT NULL,
 transaction_amount NUMBER NOT NULL,
 comments           VARCHAR2(30),
	CONSTRAINT trx_to_acct
	FOREIGN KEY (account_id)
	REFERENCES account (account_id));

CREATE SEQUENCE account_transaction_seq;

/*
  ||
  || SECTION 1 : Using a trigger only
  ||   - will fail in Oracle 7.3.x
  ||   - will work in later versions
  ||
*/
CREATE TRIGGER give_away_free_money
AFTER INSERT ON account
FOR EACH ROW
BEGIN
  INSERT INTO account_transaction
	(transaction_id,
	 account_id,
	 transaction_type,
	 transaction_amount,
	 comments)
  VALUES(account_transaction_seq.nextval,
	   :NEW.account_id,
	   'DEP',
	   100,
	   'Free Money!');
END;
/

INSERT INTO account
VALUES(1,1);

SELECT *
  FROM account;

SELECT *
  FROM account_transaction;

DROP TRIGGER give_away_free_money;

/*
  ||
  || SECTION 2 : Using a package and triggers
  ||   - will work in all versions of Oracle
  ||
*/
CREATE OR REPLACE PACKAGE give_away_money AS

  PROCEDURE init_tables;
  PROCEDURE add_account_to_list ( p_account NUMBER );
  PROCEDURE give_it_away_now;

END give_away_money;
/

CREATE OR REPLACE PACKAGE BODY give_away_money AS

  -- structure to hold account numbers
  TYPE v_account_table_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  v_account_table v_account_table_type;

  /*-------------------------------------------------------*/
  PROCEDURE init_tables IS
  /*-------------------------------------------------------*/
    /*
      || Initialize the account list to empty
    */
  BEGIN
    v_account_table.DELETE;
  END init_tables;

  /*-------------------------------------------------------*/
  PROCEDURE add_account_to_list ( p_account NUMBER ) IS
  /*-------------------------------------------------------*/
  BEGIN
    v_account_table(NVL(v_account_table.LAST,0) + 1) := p_account;
  END add_account_to_list;

  /*-------------------------------------------------------*/
  PROCEDURE give_it_away_now IS
  /*-------------------------------------------------------*/
    /*
      || Create 100 dollar deposits for the accounts that have
      || been created
    */
    v_element PLS_INTEGER;
  BEGIN
    v_element := v_account_table.FIRST;
    LOOP
      EXIT WHEN v_element IS NULL;
      INSERT INTO account_transaction
      	(transaction_id,
	       account_id,
	       transaction_type,
	       transaction_amount,
	       comments)
      VALUES(account_transaction_seq.nextval,
	       v_account_table(v_element),
	       'DEP',
	       100,
	       'Free Money!');
      v_element := v_account_table.NEXT(v_element);
    END LOOP;
  END give_it_away_now;

END give_away_money;
/

CREATE OR REPLACE TRIGGER before_insert_statement
BEFORE INSERT ON account
BEGIN
  /*
    || Initialize PL/SQL tables to hold accounts that
    || will get 100 free dollars when we are done!
  */
  give_away_money.init_tables;
END;
/

CREATE OR REPLACE TRIGGER after_insert_row
AFTER INSERT ON account
FOR EACH ROW
BEGIN
  /*
    || Add the new account to the list of those in line for
    || 100 dollars.
  */
  give_away_money.add_account_to_list(:NEW.account_id);
END;
/

CREATE OR REPLACE TRIGGER after_insert_statement
AFTER INSERT ON account
BEGIN
  /*
    || At long last we can give away the money!
  */
  give_away_money.give_it_away_now;
END;
/

INSERT INTO account
VALUES(100,'Test');

SELECT *
  FROM account;

SELECT *
  FROM account_transaction;

/*
  ||
  || SECTION 3 : ON DELETE CASCADE situation
  ||  - will fail in all versions
  ||
*/
DROP TABLE detail_table;
DROP TABLE master_table;

CREATE TABLE master_table
(master_id NUMBER NOT NULL PRIMARY KEY);

CREATE TABLE detail_table
(detail_id NUMBER NOT NULL,
 master_id NUMBER NOT NULL,
   CONSTRAINT detail_to_emp
   FOREIGN KEY (master_id)
   REFERENCES master_table (master_id)
   ON DELETE CASCADE);

CREATE OR REPLACE TRIGGER after_delete_master
AFTER DELETE ON master_table
FOR EACH ROW
DECLARE
  CURSOR curs_count_detail IS
  SELECT COUNT(*)
    FROM detail_table;
  v_detail_count NUMBER;
BEGIN
  OPEN curs_count_detail;
  FETCH curs_count_detail INTO v_detail_count;
  CLOSE curs_count_detail;
END;
/

INSERT INTO master_table
VALUES(1);
INSERT INTO detail_table
VALUES(1,1);
COMMIT;

DELETE master_table;

/*
  ||
  || SECTION 4 : ON DELETE CASCADE with AUTONOMOUS_TRANSACTION
  ||             trigger
  ||  - will succeed in Oracle 8.1 or higher
  ||  - not available in earlier versions
  ||
*/
DROP TABLE detail_table;
DROP TABLE master_table;

CREATE TABLE master_table
(master_id NUMBER NOT NULL PRIMARY KEY);

CREATE TABLE detail_table
(detail_id NUMBER NOT NULL,
 master_id NUMBER NOT NULL,
   CONSTRAINT detail_to_emp
   FOREIGN KEY (master_id)
   REFERENCES master_table (master_id)
   ON DELETE CASCADE);

CREATE OR REPLACE TRIGGER after_delete_master
AFTER DELETE ON master_table
FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
  CURSOR curs_count_detail IS
  SELECT COUNT(*)
    FROM detail_table;
  v_detail_count NUMBER;
BEGIN
  OPEN curs_count_detail;
  FETCH curs_count_detail INTO v_detail_count;
  DBMS_OUTPUT.PUT_LINE('detail count = ' || v_detail_count);
  CLOSE curs_count_detail;
END;
/

INSERT INTO master_table
VALUES(1);
INSERT INTO detail_table
VALUES(1,1);
COMMIT:

SET SERVEROUTPUT ON
DELETE master_table;



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
