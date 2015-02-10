PROCEDURE tr_post_query (block_in IN VARCHAR2)
/*
|| Summary: 
||		Looks up the description of a foreign key and places that
||		description in the FK_<entity>_NM field. This procedure makes
||		no references to any specific fields. It can be called in any
||		Post-Query trigger in the entire application without changes.
||
|| Parameters:
||		block_in 		The block for which Post-Query is being executed.
||
||	Program Dependencies:
||		valid_object		
*/
IS
	/* Name of a field */
	field_name VARCHAR2(80);

	/* Name of entity, e.g., CALL, CALL_TYPE, etc. */
	entity_name	VARCHAR2 (30);

	/* Full name of field (block.field) */
	full_field_name	VARCHAR2 (80);	

	/* Description foreign key looked up by procedure */
	fk_description	VARCHAR2 (100);
BEGIN
	/*
	|| Loop through each field in the block; if I find a foreign key 
	|| field (the name is like 'FK%ID'), then look up the description
	|| with a call to the post_query_fetch procedure (not included in 
	|| the book; it is very much specific to the data structures).
	*/
	field_name := GET_BLOCK_PROPERTY (block_in, FIRST_FIELD);
	/*
	The SQL*Forms version:
	field_name := BLOCK_CHARACTERISTIC (block_in, FIRST_FIELD);
	*/
	WHILE field_name IS NOT NULL
	LOOP
		/* If a foreign key field... */
		IF field_name LIKE 'FK%ID'
		THEN
			/*
			|| Extract the name of the foreign key entity, construct 
			|| the full field name (field_name is just the 
			|| field name, without the block prefix, which is needed 
			|| later), and look up the description for the key with a call 
			|| to post_query_fetch (implementation is very much application
			|| specific and is not included here). 
			||
			|| Explanation of SUBSTR: I need to extract entity name. 
			|| Convention is FK_<entity>_ID, so I start at position 4 and 
			|| want the full length of the string MINUS six characters 
			|| (3 for "FK_" and 3 for "_ID").
			*/
			entity_name := SUBSTR (field_name, 4, LENGTH (field_name) - 6);
			full_field_name := block_in || '.' || field_name;
			fk_description :=
				post_query_fetch 
					(entity_name, NAME_IN (full_field_name));
			IF fk_description IS NULL
			THEN
				/* Referential integrity failure */
				MESSAGE (' Failure to find ' || entity_name || 
							'for ID = ' || NAME_IN (full_field_name));
				RAISE FORM_TRIGGER_FAILURE;
			ELSE
				/* 
				|| COPY puts the description into the name field, which is
				|| constructed by relying on the naming convention of 
				|| FK_<entity>_NM. Example: if FK field is FK_CALLER_ID, 
				|| then description field is FK_CALLER_NM.
				*/
				COPY (fk_description, 
						block_in || '.FK_' || entity_name || '_NM');
			END IF;
		END IF;
		/* Move on to next field... */
		field_name := GET_ITEM_PROPERTY (full_field_name, NEXTFIELD);
		/*
		SQL*Forms version:
		field_name := FIELD_CHARACTERISTIC (full_field_name, NEXTFIELD);
		*/
	END LOOP;
END;


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
