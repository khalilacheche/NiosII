library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is  
	 TYPE STATE_TYPE IS (FETCH1, FETCH2, DECODE,I_EXECUTE ,R_EXECUTE,  BRANCH, CALL, CALL_R, R_OP, JMP, JMPI, STORE, BREAK, LOAD1, LOAD2, I_OP);
	 SIGNAL state: STATE_TYPE; 
	 signal s_op , s_opx : std_logic_vector(7 downto 0 ) ; 
begin                            

FSM : PROCESS(clk,reset_n,op ,opx) IS
BEGIN              
 	s_op <= "00" & op ; 
	s_opx <= "00" & opx;  
	IF (reset_n = '0') THEN
		 state <= FETCH1;
	ELSIF (rising_edge(clk))THEN
	     CASE state IS
         	WHEN FETCH1 =>
            	state <= FETCH2;
         	WHEN FETCH2 =>
            	state <= DECODE;   
            	
         	WHEN DECODE =>
         		 if(s_op=x"3A" and (s_opx =x"12" or s_opx =x"1A" or s_opx =x"3A" or s_opx =x"02")) then state <= R_EXECUTE ;    
         		 elsif (s_op = x"3A" and (s_opx = x"0D" or s_opx = x"05" )) then state <= JMP;  
         		 elsif (s_op = x"3A" and s_opx = x"1D") then state <= CALL_R;
				 elsif(s_op = X"3A" ) then state <= R_OP;   
				 elsif(s_op = x"0C" or s_op = x"14" or s_op = x"1C" or s_op=x"28" or s_op=x"30") then state <= I_EXECUTE ;  
		
				 elsif (s_op = x"17" ) then state <= LOAD1;
				 elsif (s_op = x"15" ) then state <= STORE;
				 elsif (s_op = x"3A" and s_opx = x"34" ) then state <= BREAK;
				 elsif (s_op = x"06" OR  s_op = x"0E" OR s_op = x"16" OR s_op = x"1E" OR s_op = x"26" OR s_op = x"2E" OR s_op = x"36") then state <= BRANCH;
				 elsif (s_op = x"00") then state <= CALL; 
				 
				 elsif (s_op = x"01")then state <= JMPI; 
				 else state <= I_OP;
			
				 end if ; 	
            WHEN R_OP | R_EXECUTE =>
            	state <= FETCH1;
            WHEN STORE =>
            	state <= FETCH1;
            WHEN BREAK =>
            	state <= BREAK;
            WHEN LOAD1 =>
            	state <= LOAD2;
            WHEN LOAD2 =>
                state <= FETCH1;
            WHEN I_OP | I_EXECUTE =>
            	state <= FETCH1;
            WHEN JMP =>
            	state <= FETCH1;
			WHEN JMPI =>
            	state <= FETCH1;
            WHEN BRANCH =>
            	state <= FETCH1;
            WHEN CALL =>
            	state <= FETCH1;
            WHEN CALL_R =>
            	state <= FETCH1;  
            
      	 END CASE;
	END IF;
		
END PROCESS FSM;

------------- ENABLES --------------------------
pc_en <= '1' when state = FETCH2 or state = CALL_R or state= CALL or state=JMP  or state = JMPI else '0';
ir_en <= '1' when state = FETCH2 else '0';
rf_wren <= '1' when state = I_OP or state = R_OP or state=LOAD2 or state=R_EXECUTE OR state= I_EXECUTE  or state= CALL or  state = CALL_R else '0'; 

------------- Read/Write -----------------------           
write <= '1' when state = STORE else '0' ;   
read <= '1' when state = FETCH1 or state = LOAD1  else '0';                                  
--
imm_signed <= '1' when state = I_OP or state = STORE OR state= LOAD1 else '0';
--                                                                              

branch_op <= '1' when state = BRANCH else '0';
pc_add_imm <= '1' when state = BRANCH else '0';
pc_sel_imm <= '1' when state = CALL or state = JMPI else '0'; 
pc_sel_a <= '1' when state = CALL_R or state =JMP  else '0';

   

------------- MUXES ----------------------------
sel_mem <=  '1' when state=LOAD2 else '0' ; 
sel_b <= '1' when state = R_OP or state = BRANCH  else '0' ; 
sel_rC <= '1' when state = R_OP or state= R_EXECUTE else '0'; 
sel_addr <= '1' when state = LOAD1 or state = STORE else '0' ; 
sel_ra <= '1' when state = CALL or state = CALL_R  else '0';
sel_pc <= '1' when state = CALL_R or state = CALL  else '0';


------------- ALU OUT --------------------------                                             
alu_out : PROCESS(s_opx,s_op) IS
	BEGIN                            
	  
		


		case s_op is  
			when x"3A" => 
						case s_opx is 
		   						when x"18" => op_alu <= "011011";
								when x"20" => op_alu <= "011100" ; 
								when x"28" => op_alu <= "011101"; 
								when x"30" => op_alu <= "011110" ; 
								when x"03" => op_alu <= "110000" ;    
								when x"0B" => op_alu <= "110001";           
								when x"31" => op_alu <= "000000";     
								when x"39" => op_alu <= "001000";
							    when x"08" => op_alu <= "011001";           
								when x"10" => op_alu <= "011010";     
								when x"06" => op_alu <= "100000"; 
								when x"0E" => op_alu <= "100001";  
								when x"16" => op_alu <= "100010";          
								when x"1E" => op_alu <= "100011";     
								when x"13" => op_alu <= "110010";	
								when x"1B" => op_alu <= "110011";           
								when x"3B" => op_alu <= "110111";    
								when x"12" => op_alu <= "110010"; 
        						when x"1A" => op_alu <= "110011"; 
        						when x"3A" => op_alu <= "110111";
        						when x"02" => op_alu <= "110000" ; 
								when others => 	op_alu(2 downto 0) <= opx(5 downto 3);   
	   					end case ; 
			when x"0c" => op_alu <= "100001" ; 
			when x"14" => op_alu <= "100010" ;  
			when x"1C" => op_alu <= "100011" ; 
			when x"28" => op_alu <= "011101" ; 
		    when x"30" => op_alu <= "011110";         
		    when x"08" => op_alu <="011001";
		    when x"10" => op_alu <="011010";
		    when x"18" => op_alu <= "011011"; 
		    when x"20" => op_alu <= "011100" ; 
		    when x"06" => op_alu <= "011100"; 
       		when x"0E" => op_alu <= "011001"; 
       		when x"16" => op_alu <= "011010"; 
       		when x"1E" => op_alu <= "011011"; 
       		when x"26" => op_alu <= "011100";  
       		when x"2E" => op_alu <= "011101"; 
       		when x"36" => op_alu <= "011110"; 
		    when others => 	op_alu(2 downto 0) <= op(5 downto 3); 
		 END CASE ; 
   
       
       
    
	END PROCESS alu_out;

end synth;
