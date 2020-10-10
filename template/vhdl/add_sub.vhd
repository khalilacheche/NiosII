library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
signal s_r,s_a,s_b ,s : std_logic_vector(32 downto 0) ;  
signal s_sub,s_z : std_logic_vector(31 downto 0); 
begin                                             
            

  s_sub <= (others => sub_mode); 
          s_a <= '0' & a; 
          s_b <= '0' & (b xor s_sub);  
          s <= (0 => sub_mode , others => '0');
    	s_r <= std_logic_vector(signed(s_a)+ signed(s_b) + signed(s));   
    	carry <= s_r(32); 
    	r <= s_r(31 downto 0 ) ;
    	
    process(a,b,sub_mode,s_r) 
    begin 
             s_z<=(others => '0');
    	if(s_r(31 downto 0)=s_z)then 
    	zero <='1'; 
    	else 
    	zero <='0'; 
    	 end if ; 
    	
    end process ; 



end synth;
