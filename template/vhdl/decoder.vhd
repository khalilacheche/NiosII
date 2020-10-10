library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic;
        cs_buttons : out std_logic
    );
end decoder;

architecture synth of decoder is
 
begin                
   process(address) is 
   begin 
        case  to_integer(unsigned(address)) is 
        	when 16#0# to 16#0FFC# =>
        			 cs_ROM <= '1'; 
        			 cs_RAM <= '0' ; 
        			 cs_leds <='0' ; 
        			 cs_buttons <= '0';
        	when 16#1000# to 16#1FFC# =>
        			 cs_ROM <= '0'; 
        			 cs_RAM <= '1' ; 
        			 cs_leds <='0' ;   
        			 cs_buttons <= '0';
        	when 16#2000# to 16#200C# => 
        			 cs_ROM <= '0'; 
        			 cs_RAM <= '0' ; 
        			 cs_leds <='1' ;
        			 cs_buttons <= '0';
        	when 16#2030# to 16#2034# =>
        			cs_ROM <= '0'; 
        			cs_RAM <= '0' ; 
        			cs_leds <='0' ;
        			cs_buttons <= '1';
        	when others => 
        			 cs_ROM <= '0'; 
        			 cs_RAM <= '0' ; 
        			 cs_leds <='0' ;
        			 cs_buttons <= '0';  
        end case ;	 
        	
   end process ; 
end synth;
