PROCEDURE tr_pre_query (block_in IN VARCHAR2)
/*
|| Single procedure to automatically perform foreign key
|| 	query-by-example capabilities. 
*/
IS
	field_name CHAR(80);
	entity_name VARCHAR2 (30); 
	full_field_name	VARCHAR2 (80);	 
BEGIN
	/*
	|| Loop through the fields in base table block. If a FK name field
	|| (format: FK_<entity>_NM) has a value in it, then generate the "#"
	|| sub-select string and place it in the corresponding ID field.
	*/
	field_name := GET_BLOCK_PROPERTY (block_in, FIRST_FIELD);
	/*
	The SQL*Forms version:
	field_name := BLOCK_CHARACTERISTIC (block_in, FIRST_FIELD);
	*/
	WHILE field_name IS NOT NULL
	LOOP
		field_value := NAME_IN (field_name);
		IF field_name LIKE 'FK%NM' AND field_value IS NOT NULL
		THEN
			/*
			|| We have a foreign key description entered. Extract the entity
			|| name, construct the full field name (field_name is just the 
			|| field name, without the block prefix, which is needed later),
			|| and then set the ID field to the constructed sub-select. 
			*/
			entity_name := SUBSTR (field_name, 4, LENGTH (field_name) - 6);
			full_field_name := block_in || '.' || field_name;
			/*
			|| Now is the time to fully-leverage the naming conventions I set
			|| up for tables, primary keys and the like. Suppose that the 
			|| entity_name is "caller" and the search string is "ACME". 
			||	Then the following subselect is constructed:
			||		'# IN (SELECT ' || 'caller' || '_ID FROM ' ||
			||		'caller' || ' WHERE ' || 'caller' ||
			||		'_NAME LIKE ''' || 'ACME' || '%'')'
			|| or:
			||		'# IN (SELECT caller_ID FROM caller 
			||		WHERE caller_NAME LIKE 'ACME%')
			*/
			COPY ('# IN (SELECT ' || entity_name || '_ID FROM ' || 
					entity_name || ' WHERE ' || 
					entity_name || '_NAME LIKE ''' || field_value || '%'')',
					block_in || '.FK_' || entity_name || '_ID');
		END IF;
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
