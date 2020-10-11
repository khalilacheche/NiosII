library ieee;
use ieee.std_logic_1164.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM; 


architecture synth of ROM is
component ROM_Block is
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;
SIGNAL s_data : std_logic_vector (31 downto 0);
SIGNAL s_read : std_logic;

begin         
 rb: ROM_Block
 PORT MAP( address =>address, clock => clk , q => s_data );
	read_pr : PROCESS (clk) IS
	BEGIN
	   IF (rising_edge(clk))  THEN
		s_read <= cs and read;
	  END IF;
	END PROCESS read_pr;
	
rddata<= s_data when s_read = '1' else (others => 'Z'); 	 

end synth;
