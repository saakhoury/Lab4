LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
    clkin_50	   : in	std_logic;							-- The 50 MHz FPGA Clockinput
	 rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	 pb_n				: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	 sw   			: in 	std_logic_vector(7 downto 0); -- The switch inputs
    leds				: out std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	-- or to add internal signals for your simulations
	-------------------------------------------------------------
	
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
   component segment7_mux port (
          clk        	: in  std_logic := '0';
			 DIN2 			: in  std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 			: in  std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT				: out	std_logic_vector(6 downto 0);
			 DIG2				: out	std_logic;
			 DIG1				: out	std_logic
   );
   end component;

   component clock_generator port (
			sim_mode			: in boolean;
			reset				: in std_logic;
         clkin      		: in  std_logic;
			sm_clken			: out	std_logic;
			blink		  		: out std_logic
  );
   end component;

    component pb_filters port (
			clkin				: in std_logic;
			rst_n				: in std_logic;
			rst_n_filtered	: out std_logic;
			pb_n				: in  std_logic_vector (3 downto 0);
			pb_n_filtered	: out	std_logic_vector(3 downto 0)							 
 );
   end component;

	component pb_inverters port (
			rst_n				: in  std_logic;
			rst				: out	std_logic;							 
			pb_n_filtered	: in  std_logic_vector (3 downto 0);
			pb					: out	std_logic_vector(3 downto 0)							 
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
			register_clr		: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
  end component;		
  
  component State_Machine port (
			clk_input, reset, enable, blink, NS, EW																				: IN std_logic;
			state_number																													: OUT std_logic_vector(3 downto 0);
			NS_clear, NS_cross, NS_amber, NS_green, NS_red, EW_clear, EW_cross, EW_amber, EW_green, EW_red	   : OUT std_logic
  );
  end component;		
 
----------------------------------------------------------------------------------------------------
	CONSTANT	sim_mode																: boolean := FALSE;  -- set to FALSE for LogicalStep board downloads																						-- set to TRUE for SIMULATIONS
	SIGNAL rst, rst_n_filtered, synch_rst									: std_logic;
	SIGNAL sm_clken, blink_sig													: std_logic; 
	SIGNAL pb_n_filtered, pb													: std_logic_vector(3 downto 0); 
	SIGNAL NS_red, NS_green, NS_amber, EW_red, EW_green, EW_amber  : std_logic;
	SIGNAL NS, EW																	: std_logic := '0';
	SIGNAL sync_input_NS, sync_input_EW										: std_logic;
	SIGNAL NS_clear, EW_clear 													: std_logic := '0';
	SIGNAL NS_7segment, EW_7segment											: std_logic_vector(6 downto 0);
	
BEGIN
----------------------------------------------------------------------------------------------------
INST0: pb_filters			port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters		port map (rst_n_filtered, rst, pb_n_filtered, pb);
INST2: synchronizer     port map (clkin_50,synch_rst, rst, synch_rst);	-- the synchronizer is also reset by synch_rst.
INST3: clock_generator 	port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);

INST4: synchronizer		port map (clkin_50, sync_rst, pb(0), sync_input_NS);
INST5: synchronizer 		port map (clkin_50, sync_rst, pb(1), sync_input_EW);

-- INST4: holding_register		port map (clkin_50, rst, NS_clear, sync_input_NS, NS);
-- INST5: holding_register 	port map (clkin_50, rst, EW_clear, sync_input_EW, EW);

INST6: holding_register port map (clkin_50, sync_rest, '0', sync_input_NS, NS);

--INST6: State_Machine port map (clkin_50, sm_clken, pb(3), blink_sig, NS, EW, NS_clear, leds(0), NS_green, NS_amber, NS_red);

INST7: holding_register port map (clkin_50, sync_rest, '0', sync_input Ew, EW);

--INST7: segment7_mux 	port map (clkin_50, NS_7segment, EW_7segment, seg7_data, seg7_char2, seg7_char1);

-- NS_7segment (6 downto 0) >= NS_red & "00" & NS_amber & "00" & NS_green;
-- EW_7segment (6 downto 0) >= EW_red & "00" & EW_amber & "00" & EW_green;

leds(1) <= NS;
leds(3) <= EW;


END SimpleCircuit;
