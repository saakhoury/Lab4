-- TEAM MEMBERS: PEARL NATALIA, SANSKRITI AKHOURY
-- GROUP 1 SESSION 205

-- This file serves as a synchronizer module designed to synchronize asynchronous button inputs with a clock signal using D flip-flops
library ieee;
use ieee.std_logic_1164.all;


entity synchronizer is port (

			clk			: in std_logic;
			reset			: in std_logic;
			din			: in std_logic;
			dout			: out std_logic
  );
 end synchronizer; -- functionality is to take asynchronous button inputs and synchronize them with clock 
 
 
architecture circuit of synchronizer is

	Signal sreg				: std_logic_vector(1 downto 0);

BEGIN
		process(clk) is
		begin
		
		if(rising_edge(clk)) then
		-- the output of the D-flipflop is represented by sreg
		-- the output ('Q') acts as the input of the next D-flipflop
			sreg(1) <= sreg(0);
			sreg(0) <= din;
			-- set both outputs to 0 when reset 
			if (reset = '1') then
				sreg(0) <= '0';
				sreg(1) <= '0';
			end if;
		end if;
	end process;
	dout <= sreg(1);
end;
