-- TEAM MEMBERS: PEARL NATALIA, SANSKRITI AKHOURY
-- GROUP 1 SESSION 205

-- This file defines a holding register (`holding_register`) that captures and holds synchronized button input values (`din`) until a clear signal 
-- (`register_clr`)is received, with the output (`dout`) reflecting the stored value, and it also includes functionality to reset the register 
-- (`reset` signal).
library ieee;
use ieee.std_logic_1164.all;


entity holding_register is port (

			clk			: in std_logic;
			reset			: in std_logic;
			register_clr		: in std_logic;
			din			: in std_logic;
			dout			: out std_logic
  );
 end holding_register; -- functionality is to hold synchronized button input values until cleared
 
 architecture circuit of holding_register is

	Signal sreg				: std_logic;


BEGIN
	process(clk) is
	begin
	if(rising_edge(clk)) then
		-- sreg value is held on until it receives a clear signal after din
		sreg<= (din OR sreg) AND NOT register_clr;
		if(reset='1') then
			sreg<= '0';
			end if;
		end if;
		end process;
		dout<=sreg;



end;
