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
	 TYPE STATE_TYPE IS (FETCH1, FETCH2, DECODE, BRANCH, CALL, CALL_R, R_OP, JMP, JMPI, STORE, BREAK, LOAD1, LOAD2, I_OP);
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
				 if(s_op = X"3A" and s_opx /= X"34" ) then state <= R_OP;    
				 elsif (s_op = x"04") then state <= I_OP;
				 elsif (s_op = x"17" ) then state <= LOAD1;
				 elsif (s_op = x"15" ) then state <= STORE;
				 elsif (s_op = x"3A" and s_opx = x"34" ) then state <= BREAK;
				 elsif (s_op = x"06" OR  s_op = x"0E" OR s_op = x"16" OR s_op = x"1E" OR s_op = x"26" OR s_op = x"2E" OR s_op = x"36") then state <= BRANCH;
				 elsif (s_op = x"00") then state <= CALL; 
				 elsif (s_op = x"3A" and s_opx = x"1D") then state <= CALL_R;
				 elsif (s_op = x"01")then state <= JMPI;
				 elsif (s_op = x"3A" and (s_opx = x"0D" or s_opx = x"05" )) then state <= JMP;
				 end if ; 	
            WHEN R_OP =>
            	state <= FETCH1;
            WHEN STORE =>
            	state <= FETCH1;
            WHEN BREAK =>
            	state <= BREAK;
            WHEN LOAD1 =>
            	state <= LOAD2;
            WHEN LOAD2 =>
                state <= FETCH1;
            WHEN I_OP =>
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
pc_en <= '1' when state = FETCH2 or state = CALL_R or state = JMP or state = JMPI else '0';
ir_en <= '1' when state = FETCH2 else '0';
rf_wren <= '1' when state = I_OP or state = R_OP or state=LOAD2 or state = CALL_R else '0'; 

------------- Read/Write -----------------------           
write <= '1' when state = STORE else '0' ;   
read <= '1' when state = FETCH1 or state = LOAD1  else '0';                                  
--
imm_signed <= '1' when state = I_OP or state = STORE OR state= LOAD1 else '0';
--                                                                              

branch_op <= '1' when state = BRANCH else '0';
pc_add_imm <= '1' when state = BRANCH else '0';
pc_sel_imm <= '1' when state = CALL or state = JMPI else '0'; 
pc_sel_a <= '1' when state = CALL_R or state = JMP else '0';

   

------------- MUXES ----------------------------
sel_mem <=  '1' when state=LOAD2 else '0' ; 
sel_b <= '1' when state = R_OP or state = BRANCH  else '0' ; 
sel_rC <= '1' when state = R_OP else '0'; 
sel_addr <= '1' when state = LOAD1 or state = STORE else '0' ; 
sel_ra <= '1' when state = CALL or state = CALL_R  else '0';
sel_pc <= '1' when state = CALL_R else '0';


------------- ALU OUT --------------------------                                             
alu_out : PROCESS(state) IS
	BEGIN                            
	op_alu<=(OTHERS=>'0');	
	IF (state = R_OP) THEN
		op_alu(2 downto 0) <= opx(5 downto 3);
	ELSIF (state = I_OP OR state = BRANCH OR state = CALL ) THEN
		op_alu(2 downto 0) <= op(5 downto 3);
	END IF;
	END PROCESS alu_out;

end synth;
