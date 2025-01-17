library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
	signal address : std_logic_vector(15 downto 0);
begin                                              
progcount : PROCESS (clk, reset_n) IS
BEGIN
  IF (reset_n = '0') THEN
	address <= x"0000";
  ELSIF (rising_edge(clk))  THEN
	IF (en = '1')THEN
		IF (add_imm ='1') THEN                                     
			address <= std_logic_vector(unsigned(address) + unsigned(imm));
		ELSIF  (sel_imm = '1') THEN                                                          
			address <= std_logic_vector(shift_left(unsigned(imm), 2));
		ELSIF (sel_a = '1') THEN
			address <= a;  
		ELSE
			address <= std_logic_vector(unsigned(address) + 4);
		END IF;
	END IF;
  END IF;
END PROCESS progcount;
addr(15 downto 2) <= address(15 downto 2);
addr(1 downto 0) <= (OTHERS=>'0');
addr(31 downto 16) <= (OTHERS=>'0');
end synth;
