-- TEAM MEMBERS: PEARL NATALIA, SANSKRITI AKHOURY
-- GROUP 1 SESSION 205

-- This file serves as the top-level module for a LogicalStep Lab 4 project, managing interactions with FPGA components including clock input,
-- reset, push-buttons, switches, LEDs, and a 7-segment display, integrating sub-components for traffic light control and display.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
         clkin_50	   	: in	std_logic; -- The 50 MHz FPGA Clockinput
	 rst_n			: in	std_logic; -- The RESET input (ACTIVE LOW)
	 pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	 sw   			: in 	std_logic_vector(7 downto 0); -- The switch inputs
    	 leds			: out std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	-- or to add internal signals for your simulations
	-------------------------------------------------------------
	
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
   seg7_char1  	: out	std_logic;		    -- seg7 digi selectors
   seg7_char2  	: out	std_logic		    -- seg7 digi selectors
	);

   -- outputs for the simulation 
   -- sm_clken, blink_sig, NS_red, NS_green, NS_amber, EW_red, EW_green, EW_amber : out std_logic 
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
   component segment7_mux port (
          		 clk             	: in  std_logic := '0';
			 DIN2 			: in  std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 			: in  std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
   );
   end component;

   component clock_generator port (
			sim_mode			: in boolean;
			reset				: in std_logic;
         		clkin      			: in  std_logic;
			sm_clken			: out	std_logic;
			blink		  		: out std_logic
  );
   end component;

    component pb_filters port (
			clkin				: in std_logic;
			rst_n				: in std_logic;
			rst_n_filtered			: out std_logic;
			pb_n				: in  std_logic_vector (3 downto 0);
			pb_n_filtered			: out	std_logic_vector(3 downto 0)							 
 );
   end component;

	component pb_inverters port (
			rst_n				: in  std_logic;
			rst				: out	std_logic;							 
			pb_n_filtered			: in  std_logic_vector (3 downto 0);
			pb				: out	std_logic_vector(3 downto 0)							 
  );
   end component;
	
	component synchronizer port(
			clk					: in std_logic;
			reset					: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
   end component; 
  component holding_register port (
			clk					: in std_logic;
			reset					: in std_logic;
			register_clr				: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
  end component;		
  
  component State_Machine port (
			clk_input, reset, enable, blink_sig, NS, EW																				: IN std_logic;
			state_number																													: OUT std_logic_vector(3 downto 0);
			NS_clear, NS_crossing, NS_amber, NS_green, NS_red, EW_clear, EW_crossing, EW_amber, EW_green, EW_red	   : OUT std_logic
  );
  end component;		
 
----------------------------------------------------------------------------------------------------
	CONSTANT sim_mode								: boolean := FALSE;  -- set to FALSE for LogicalStep board downloads	
													     -- set to TRUE for SIMULATIONS
	SIGNAL rst, rst_n_filtered, sync_rst						: std_logic; -- reset for registers
	SIGNAL sm_clken, blink_sig							: std_logic; 
	SIGNAL pb_n_filtered, pb							: std_logic_vector(3 downto 0); 
	SIGNAL NS_red, NS_green, NS_amber, EW_red, EW_green, EW_amber  			: std_logic;			-- signal outputs
	SIGNAL NS, EW									: std_logic := '0';		-- state machine holds EW/NS requests until processed
	SIGNAL sync_input_NS, sync_input_EW						: std_logic;			-- button input once its synchronized with clk 
	SIGNAL NS_clear, EW_clear 							: std_logic := '0';		-- after request is processed, send clear signals to clear the hold registers
	SIGNAL NS_7segment, EW_7segment							: std_logic_vector(6 downto 0); -- 7 bit value to be sent to the output of the 7 segment traffic lights display
	
BEGIN
----------------------------------------------------------------------------------------------------
INST0: pb_filters	 port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters	 port map (rst_n_filtered, rst, pb_n_filtered, pb);
INST2: synchronizer      port map (clkin_50,sync_rst, rst, sync_rst);	-- the synchronizer is also reset by synch_rst.
INST3: clock_generator 	 port map (sim_mode, sync_rst, clkin_50, sm_clken, blink_sig);

-- synchronizes button inputs 
INST4: synchronizer	 port map (clkin_50, sync_rst, pb(0), sync_input_NS);
INST5: synchronizer 	 port map (clkin_50, sync_rst, pb(1), sync_input_EW);

-- button inputs are proccessed and held as requests until cleared
INST6: holding_register port map (clkin_50, rst, NS_clear, sync_input_NS, NS);
INST7: holding_register port map (clkin_50, rst, EW_clear, sync_input_EW, EW);

--INST6: holding_register port map (clkin_50, sync_rst, '0', sync_input_NS, NS);
	
-- functionality is to send requests and enable clock to the state machine for processing, lights and signals are outputs to be displayed, clears the hold registers after processing
INST8: State_Machine port map (clkin_50, sync_rst, sm_clken, blink_sig, NS, EW, leds(7 downto 4), NS_clear, leds(0), NS_amber, NS_green, NS_red, EW_clear, leds(2), EW_amber, EW_green, EW_red);

--INST7: holding_register port map (clkin_50, sync_rst, '0', sync_input_EW, EW);

-- for the 7 segment display concatenate outputs into 7 bit values 
NS_7segment (6 downto 0) <= NS_amber & "00" & NS_green & "00" & NS_red;
EW_7segment (6 downto 0) <= EW_amber & "00" & EW_green & "00" & EW_red;
 
INST9: segment7_mux 	port map (clkin_50, NS_7segment, EW_7segment, seg7_data, seg7_char2, seg7_char1);

leds(1) <= NS;
leds(3) <= EW;


END SimpleCircuit;
