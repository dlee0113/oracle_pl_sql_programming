PROCEDURE highlight_record (block_in IN VARCHAR2)
IS
	/* Name of current item in block */
	curr_item	 VARCHAR2 (80);

	/* The internal handle for an item */
	item_id ITEM;
BEGIN
	/* If not already in this block, go to it */
	IF :SYSTEM.CURSOR_BLOCK != block_in 
	THEN 
		GO_BLOCK (block_in); 
	END IF;

	/* Initialize the current item for the WHILE loop */ 
	curr_item := GET_BLOCK_PROPERTY (block_in, FIRST_ITEM);

	/* Define a label for the loop */
	<<through_block>>
	WHILE curr_item IS NOT NULL
	LOOP
		/* Get the ID for this item. For better performance */
		item_id := FIND_ITEM (block_in||'.'||curr_item);

		/* If this item is displayed, then highlight it */
		IF GET_ITEM_PROPERTY (item_id, DISPLAYED) = 'TRUE'
		THEN
			SET_ITEM_PROPERTY 
				(item_id, VISUAL_ATTRIBUTE, 'va_highlight');
		END IF;

		/* Go the next item in the block */
		curr_item := GET_ITEM_PROPERTY (item_id, NEXTITEM);

	END LOOP through_block; -- Loop label

END highlight_record;


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
