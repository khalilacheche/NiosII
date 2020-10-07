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
	 TYPE STATE_TYPE IS (FETCH1, FETCH2, DECODE, R_OP, STORE, BREAK, LOAD1, LOAD2, I_OP);
	 SIGNAL state: STATE_TYPE;
begin
FSM : PROCESS(clk,reset_n) IS
BEGIN
	IF (reset_n = '0') THEN
		 state <= FETCH1;
	ELSIF (rising_edge(clk))THEN
	     CASE state IS
         	WHEN FETCH1 =>
            	state <= FETCH2;
         	WHEN FETCH2 =>
            	state <= DECODE;
         	WHEN DECODE =>
				            	
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
      	 END CASE;
	END IF;
		
END PROCESS FSM;

pc_en <= '1' when state = FETCH2 else '0';
ir_en <= '1' when state = FETCH2 else '0';
rf_wren <= '1' when state = I_OP else '0';
                                             
--
imm_signed <= '1' when state = I_OP else '0';
--

read <= '1' when state = FETCH1 else '0';





end synth;
