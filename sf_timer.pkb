CREATE OR REPLACE PACKAGE BODY sf_timer
IS
	/*----------------------------------------------------------------
	|| 					  PL/Vision Professional
	||----------------------------------------------------------------
	||  Author: Steven Feuerstein
	||
	|| This is a part of the PL/Vision Professional Code library.
	|| Copyright (C) 1996-1999 RevealNet, Inc.
	|| All rights reserved.
	||
	|| For more information, call RevealNet at 1-800-REVEAL4
	|| or check out our Web page: www.revealnet.com
	||
	******************************************************************/

	/* Package variable which stores the last timing made */
	last_timing 	 number := NULL;
	/* Package variable which stores context of last timing */
	last_context	 varchar2 (32767) := NULL;
	/* Private Variable for "factor" */
	v_factor 		 number := NULL;
	/* Private Variable for On/Off Toggle */
	v_onoff			 boolean := TRUE;
	/* Private Variable for "repeats" */
	v_repeats		 number := 100;
	/* Calibrated base timing. */
	v_base_timing	 number := NULL;

	/* Body of Set for "factor" */
	PROCEDURE set_factor (factor_in IN number)
	IS
	BEGIN
		v_factor := factor_in;
	END set_factor;

	/* Body of Get for "factor" */
	FUNCTION factor
		RETURN number
	IS
		retval	number := v_factor;
	BEGIN
		RETURN retval;
	END factor;

	PROCEDURE start_timer (context_in IN varchar2 := NULL)
	/* Save current time and context to package variables. */
	IS
	BEGIN
		last_timing := DBMS_UTILITY.get_cpu_time;
		-- On 9i, use this: last_timing := DBMS_UTILITY.get_time;
		last_context := context_in;
	END;

	FUNCTION elapsed_time
		RETURN number
	IS
		/* Grab the current time before doing anything else. */
		/* WFS 9/4/08 - Used get_cpu_time above and get_time here */
		l_end_time	 pls_integer := DBMS_UTILITY.get_cpu_time;
	BEGIN
		IF v_onoff
		THEN
			RETURN (MOD (l_end_time - last_timing + POWER (2, 32)
						  , POWER (2, 32)
							));
		END IF;
	END;

	FUNCTION elapsed_message (prefix_in 			IN varchar2:= NULL
									, adjust_in 			IN number:= 0
									, reset_in				IN boolean:= TRUE
									, reset_context_in	IN varchar2:= NULL
									 )
		RETURN varchar2
	/*
			|| Construct message for display of elapsed time. Programmer can
	|| include a prefix to the message and also ask that the last
	|| timing variable be reset/updated. This saves a separate call
	|| to elapsed.
	*/
	IS
		current_timing   number;
		retval			  varchar2 (32767) := NULL;

		FUNCTION adj_time (time_in 		 IN binary_integer
							  , factor_in		 IN integer
							  , precision_in	 IN integer
								)
			RETURN varchar2
		IS
		BEGIN
			RETURN (TO_CHAR(ROUND ( (time_in - adjust_in) / (100 * factor_in)
										, precision_in
										 )));
		END;

		FUNCTION formatted_time (time_in 	  IN binary_integer
									  , context_in   IN varchar2:= NULL
										)
			RETURN varchar2
		IS
			retval	varchar2 (32767) := NULL;
		BEGIN
			IF context_in IS NOT NULL
			THEN
				retval := ' since ' || last_context;
			END IF;

			retval :=
					prefix_in
				|| ' - Elapsed CPU '
				|| retval
				|| ': '
				|| adj_time (time_in, 1, 3)
				|| ' seconds.';

			IF v_factor IS NOT NULL
			THEN
				retval :=
						retval
					|| ' Factored: '
					|| adj_time (time_in, v_factor, 5)
					|| ' seconds.';
			END IF;

			RETURN retval;
		END;
	BEGIN
		IF v_onoff
		THEN
			IF last_timing IS NULL
			THEN
				/* If there is no last_timing, cannot show anything. */
				retval := NULL;
			ELSE
				/* Construct message with context of last call to elapsed */
				retval := formatted_time (elapsed_time (), last_context);
				last_context := NULL;
			END IF;

			IF reset_in
			THEN
				start_timer (reset_context_in);
			END IF;
		END IF;

		RETURN retval;
	END;

	PROCEDURE show_elapsed_time (prefix_in   IN varchar2:= NULL
										, adjust_in   IN number:= 0
										, reset_in	  IN boolean:= TRUE
										 )
	/* Little more than a call to the elapsed_message function! */
	IS
	BEGIN
		IF v_onoff
		THEN
			DBMS_OUTPUT.put_line (
				elapsed_message (prefix_in, adjust_in, reset_in)
			);
		END IF;
	END;
END sf_timer;
/