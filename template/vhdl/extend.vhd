library ieee;
use ieee.std_logic_1164.all;

entity extend is
    port(
        imm16  : in  std_logic_vector(15 downto 0);
        signed : in  std_logic;
        imm32  : out std_logic_vector(31 downto 0)
    );
end extend;

architecture synth of extend is
begin
imm32 (15 downto 0) <= imm16;
imm32 (31 downto 16) <= (others=>'0') when signed = '0' else (others =>imm16(15));

end synth;
