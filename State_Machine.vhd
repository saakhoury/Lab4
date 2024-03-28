-- TEAM MEMBERS: PEARL NATALIA, SANSKRITI AKHOURY
-- GROUP 1 SESSION 205
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity State_Machine IS Port
(
 	clk_input, reset, enable, blink_sig, NS, EW																			: IN std_logic;
	state_number																												: OUT std_logic_vector(3 downto 0);
 	NS_clear, NS_crossing, NS_amber, NS_green, NS_red, EW_clear, EW_crossing, EW_amber, EW_green, EW_red	: OUT std_logic
 ); 
	-- NS represents the request button to cross North South 
	-- EW represents the request button to cross East West 
	
END ENTITY;
 

Architecture SM of State_Machine is

TYPE STATE_NAMES IS (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15); -- all STATE_NAME values
SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES
SIGNAL state_counter			:  unsigned(3 downto 0) := "0000";

BEGIN
 

 -------------------------------------------------------------------------------
 --State Machine:
 -------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS EXAMPLE
 
Register_Section: PROCESS (clk_input)  -- this process updates with a clock
BEGIN
	IF(rising_edge(clk_input)) THEN
		IF (reset = '1') THEN
			current_state <= s0;
		ELSIF (reset = '0' and enable = '1') THEN
			current_state <= next_State;
		END IF;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS EXAMPLE

Transition_Section: PROCESS (current_state) 

BEGIN
  CASE current_state IS
        WHEN s0=>	
			IF(EW = '1' and NS = '0') THEN
				next_state <= s6;
			ELSE
				next_state <=s1;
			END IF;
			-- functionality serves to skip to states 6 from 0, when the EW is pressed. 
			-- this means that NS goes to amber and the crossing request is made

         WHEN s1=>		
			IF(EW = '1' and NS = '0') THEN
					next_state <= s6;
			ELSE
					next_state<=s2;
			END IF;
			-- functionality serves to skip to states 6 from 0, when the EW is pressed. 
			-- this means that NS goes to amber and the crossing request is made
			
         WHEN s2 =>
					next_state<=s3;

         WHEN s3 =>
					next_state<=s4;
					
         WHEN s4 =>
					next_state<=s5;

         WHEN s5 =>
					next_state<=s6;

         WHEN s6 =>
					next_state<=s7;

         WHEN s7 =>
					next_state<=s8;

	-- continue cycling through s2 -> s7 
	 WHEN s8 =>
			IF (EW = '0' and NS = '1') THEN
				next_state <= s14;
			ELSE
				next_state <= s9;
			END IF;
			-- functionality serves to skip to states 14 from 8, when the NS is pressed. 
			-- this means that EW goes to amber and the crossing request is made
			-- otherwise continue cycling
	WHEN s9 =>
			IF(EW = '0' and NS = '1') THEN
				next_state <= s14;
			ELSE
				next_state <= s10;
			END IF;
			-- functionality serves to skip to states 14 from 8, when the NS is pressed. 
			-- this means that EW goes to amber and the crossing request is made
			-- otherwise continue cycling
				
	WHEN s10 => 
					next_state <= s11;
	WHEN s11 =>
					next_state <= s12;
	WHEN s12 =>
					next_state <= s13;
	WHEN s13 =>
					next_state <= s14;
	WHEN s14 =>
					next_state <= s15;
	WHEN s15 =>
					next_state <= s0;
	-- continue cycling through s10 -> s15 
	END CASE;
	END PROCESS;
 

-- DECODER SECTION PROCESS EXAMPLE (MOORE FORM SHOWN)

Decoder_Section: PROCESS (current_state, blink_sig) 

BEGIN
     -- 1 represents on, 0 represents off 
     -- functionality is to set crossing signal outputs and lights at each state
     -- only green blinks 
     CASE current_state IS
         WHEN s0 | s1 =>
	     			-- NS blinking green
				NS_green <= blink_sig;
				NS_amber <= '0';
				NS_red <= '0';
				NS_clear <= '0';
				NS_crossing <= '0';
				-- EW red 
				EW_green <= '0';
				EW_amber <= '0';
				EW_red <= '1';
				EW_clear <= '0';
				EW_crossing <= '0';
	       
			WHEN s2 | s3 | s4 | s5 =>
				-- NS solid green
				NS_green <= '1';
				NS_amber <= '0';
				NS_red <= '0';
				NS_clear <= '0';
				NS_crossing <= '1';
				-- EW red
				EW_green <= '0';
				EW_amber <= '0';
				EW_red <= '1';
				EW_clear <= '0';
				EW_crossing <= '0';
			
			WHEN s6 =>
				-- NS amber
				-- Clear the NS cross request
				NS_green <= '0';
				NS_amber <= '1';
				NS_red <= '0';
				NS_clear <= '1';
				NS_crossing <= '0';
				-- EW red
				EW_green <= '0';
				EW_amber <= '0';
				EW_red <= '1';
				EW_clear <= '0';
				EW_crossing <= '0';
				
			WHEN s7 =>
				-- NS amber
				NS_green <= '0';
				NS_amber <= '1';
				NS_red <= '0';
				NS_clear <= '0';
				NS_crossing <= '0';
				-- EW red
				EW_green <= '0';
				EW_amber <= '0';
				EW_red <= '1';
				EW_clear <= '0';
				EW_crossing <= '0';
			
			WHEN s8 | s9 =>
				-- NS red
				NS_green <= '0';
				NS_amber <= '0';
				NS_red <= '1';
				NS_clear <= '0';
				NS_crossing <= '0';
				-- EW blinking green
				EW_green <= blink_sig;
				EW_amber <= '0';
				EW_red <= '0';
				EW_clear <= '0';
				EW_crossing <= '0';
				
			WHEN s10 | s11 | s12 | s13 =>
				-- NS red
				NS_green <= '0';
				NS_amber <= '0';
				NS_red <= '1';
				NS_clear <= '0';
				NS_crossing <= '0';
				-- EW solid green 
				EW_green <= '1';
				EW_amber <= '0';
				EW_red <= '0';
				EW_clear <= '0';
				EW_crossing <= '1';
				
			WHEN s14 =>
				-- EW amber
				-- Clear EW cross request
				NS_green <= '0';
				NS_amber <= '0';
				NS_red <= '1';
				NS_clear <= '0';
				NS_crossing <= '0';
				-- NS red
				EW_green <= '0';
				EW_amber <= '1';
				EW_red <= '0';
				EW_clear <= '1';
				EW_crossing <= '0';
				
			WHEN s15 =>
				-- EW amber 
				NS_green <= '0';
				NS_amber <= '0';
				NS_red <= '1';
				NS_clear <= '0';
				NS_crossing <= '0';
				-- NS red
				EW_green <= '0';
				EW_amber <= '1';
				EW_red <= '0';
				EW_clear <= '0';
				EW_crossing <= '0';
			END CASE;

			-- sets the current state numbers
			CASE current_state IS
				WHEN s0 =>
					state_number <= "0000";
				WHEN s1 =>
					state_number <= "0001";
				WHEN s2 =>
					state_number <= "0010";
				WHEN s3 =>
					state_number <= "0011";
				WHEN s4 =>
					state_number <= "0100";
				WHEN s5 =>
					state_number <= "0101";
				WHEN s6 =>
					state_number <= "0110";
				WHEN s7 =>
					state_number <= "0111";
				WHEN s8 =>
					state_number <= "1000";
				WHEN s9 =>
					state_number <= "1001";
				WHEN s10 =>
					state_number <= "1010";
				WHEN s11 =>
					state_number <= "1011";
				WHEN s12 =>
					state_number <= "1100";
				WHEN s13 =>
					state_number <= "1101";
				WHEN s14 =>
					state_number <= "1110";
				WHEN s15 =>
					state_number <= "1111";
				END CASE;
 END PROCESS;

 END ARCHITECTURE SM;
