LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity IF_IR_Buffer is
  port (
    clk,RTI_Buff, RET_Buff, CALL_Buff, INT_in, reset, two_inst_in: in std_logic;
    IR_Buff: in std_logic_vector (15 downto 0);
    PPC: in std_logic_vector (31 downto 0);
    two_ints, CALL, RET, RTI, INT: out std_logic;
    PC_IF_ID: out std_logic_vector (31 downto 0);
    IR: out std_logic_vector (15 downto 0);
    dp_in: in std_logic;
    dp_out: out std_logic 
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
     component Special_latch is
      port (
        d: in std_logic;
        clk: in std_logic;
        clear: in std_logic;
    enable: in std_logic;
        q: out std_logic
    
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
    signal IR_out: std_logic_vector (15 downto 0);

begin

    
    --clear_int_latch<= (reset or INT_Buffer);
    INT_Latch: Special_latch port map(INT_in, clk, reset, '1', INT_Buffer);
    INT <= INT_Buffer;
    
    RET_Latch: Special_latch port map(RET_Buff, clk, reset,'1', RET);
    RTI_Latch: Special_latch port map(RTI_Buff, clk, reset, '1', RTI);
    CALL_Latch: Special_latch port map(CALL_Buff, clk, reset, '1', CALL);

    two_inst_Latch: WAR_latch port map(two_inst_in, clk, reset, '1', two_ints);

    IR_Reg: generic_WAR_reg GENERIC MAP(REG_WIDTH => 16) port map(IR_Buff, clk, reset, '1', IR_out);
    IR <= IR_out when INT_Buffer='0' else "0000000000000000";
    PC_Reg: generic_WAR_reg GENERIC MAP(REG_WIDTH => 32) port map(PPC, clk, reset, '1', PC_IF_ID);

    db_latch: WAR_latch port map(dp_in, clk, reset, '1', dp_out);
end IF_IR_Buffer_arch ; -- arch
