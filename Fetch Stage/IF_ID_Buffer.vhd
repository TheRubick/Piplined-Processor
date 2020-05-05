LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity IF_IR_Buffer is
  port (
    clk,RTI_Buff, RET_Buff, CALL_Buff, RET_in, RTI_in, CALL_in, INT_in, reset, two_inst_in: in std_logic;
    IR_Buff: in std_logic_vector (15 downto 0);
    PPC: in std_logic_vector (31 downto 0);
    two_ints, CALL, RET, RTI, INT: out std_logic;
    PC_IF_ID: out std_logic_vector (31 downto 0);
    IR: out std_logic_vector (15 downto 0)
  ) ;
end IF_IR_Buffer;

architecture IF_IR_Buffer_arch of IF_IR_Buffer is
    component generic_WAR_reg is
        GENERIC(
           REG_WIDTH : INTEGER := 16);
          port (
            d: in std_logic_vector (REG_WIDTH - 1 downto 0);
            clk: in std_logic;
            clear: in std_logic;
        enable: in std_logic;
            q: out std_logic_vector (REG_WIDTH - 1 downto 0)
        
          ) ;
     end component;

     component WAR_latch is
        port (
          d: in std_logic;
          clk: in std_logic;
          clear: in std_logic;
      enable: in std_logic;
          q: out std_logic
      
        ) ;
      end component;

    signal clear_int_latch,INT_Buffer: std_logic;

begin

    RET_Latch: WAR_latch port map(RET_Buff, clk, reset, RET_in, RET);
    clear_int_latch<= (reset or INT_Buffer);
    INT_Latch: WAR_latch port map(INT_in, clk, clear_int_latch, INT_in, INT_Buffer);
    INT <= INT_Buffer;
    RTI_Latch: WAR_latch port map(RTI_Buff, clk, reset, RTI_in, RTI);
    
    two_inst_Latch: WAR_latch port map(two_inst_in, clk, reset, '1', two_ints);
    
    CALL_Latch: WAR_latch port map(CALL_Buff, clk, reset, CALL_in, CALL);

    IR_Reg: generic_WAR_reg GENERIC MAP(REG_WIDTH => 16) port map(IR_Buff, clk, reset, '1', IR);
    
    PC_Reg: generic_WAR_reg GENERIC MAP(REG_WIDTH => 32) port map(PPC, clk, reset, '1', PC_IF_ID);
end IF_IR_Buffer_arch ; -- arch
