library ieee;
use ieee.std_logic_1164.all;

entity IR is
    port(
        clk    : in  std_logic;
        enable : in  std_logic;
        D      : in  std_logic_vector(31 downto 0);
        Q      : out std_logic_vector(31 downto 0)
    );
end IR;

architecture synth of IR is
	signal s : std_logic_vector(31 downto 0);
begin
reg : PROCESS (clk) IS
BEGIN
   IF (rising_edge(clk))  THEN
    IF enable = '1' THEN
    	s <= D;
    END IF;
  END IF;
END PROCESS reg;
Q <= s;
	
end synth;
