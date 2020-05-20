LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity Interrupt is
  port (
    clk: in std_logic;
    interrupt_sg: in std_logic;
    reset_sg: in std_logic;
    JMP: in std_logic;
    RET: in std_logic;
    RTI: in std_logic;
    JMPZ: in std_logic;
    IR: in std_logic_vector (15 downto 0);
    RTI_MEM: in std_logic;
    RET_MEM: in std_logic;
    JMP_Ready: in std_logic;
    Prediction_Done: in std_logic;
    reset: out std_logic;
    reset1: out std_logic;
    INT: out std_logic;
    INT2: out std_logic;
    INT3: out std_logic;
    INTZF: out std_logic;
    IntZ_notF: out std_logic;
    Jmpz2: out std_logic;
    ISR_PC: out std_logic_vector (31 downto 0);
    one_stall_int: out std_logic
  ) ;
end Interrupt;

architecture Interrupt_arch of Interrupt is

    component mux2_1bit is
        port (
          in1,in2: in std_logic;
      sel: in std_logic;
          mux_out: out std_logic
          );
      end component ;

      component mux4_1bit is
        port (
          inp0: IN std_logic;
           inp1: IN std_logic;
       inp2: IN std_logic;
       inp3: IN std_logic;
          sel: in std_logic_vector (1 downto 0);
          mux_output: out std_logic
        ) ;
      end component ;

    component encoder42 is
        port (
            en_input: in std_logic_vector (3 downto 0);
            en_out: out std_logic_vector (1 downto 0)
        ) ;
        end component;
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
          component generic_RAW_reg is
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
            
    signal int_sg_AndToMux, muxTointLatch, intLatchTOAnd1, And1, int_latch_enable, int_out,or1: std_logic;
    signal Mux41Out, And2, Reg1_enable, Reg2_enable, Jmpz2_latch_enable, INT_Buffer: std_logic;
    signal INT2_Buffer, INT3_Buffer, reset1_Buffer, Jmpz2_Buffer, reset_Buffer: std_logic;
    signal reset1_latch_input,reset1_latch_en: std_logic;
    signal INTZF_Buffer, IntZ_notF_Buffer: std_logic;
    signal encoder_Input: std_logic_vector (3 downto 0);
    signal mux41_selectors: std_logic_vector (1 downto 0);
    signal Reg1_out, Reg2_out: std_logic_vector (15 downto 0);
    signal int_out_buffer: std_logic;
begin

    int_sg_AndToMux <= (interrupt_sg and (not reset_sg));
    int_Mux: mux2_1bit port map(int_sg_AndToMux,'0',INT_Buffer,muxTointLatch);
    int_latch_enable <= (INT_Buffer or interrupt_sg);
    int_latch: WAR_latch port map(muxTointLatch,clk,reset_Buffer,int_latch_enable, int_out_buffer);
    int_out <= int_out_buffer or interrupt_sg;
    or1 <= (JMP or RET or RTI);

    And1 <= (int_out and (not JMPZ) and (not Jmpz2_Buffer) and (not or1) );
    --encoder inpute order go like this 4-3-2-1 where 1:00
    encoder_Input <= '0' & RTI &  RET & JMP;
    encoder: encoder42 port map(encoder_Input, mux41_selectors);
    mux41x: mux4_1bit  port map (JMP_Ready,RET_MEM,RTI_MEM,'0',mux41_selectors,Mux41Out);
                                    
    
    And2 <= ( (not JMPZ) and (not Jmpz2_Buffer) and int_out and or1 and Mux41Out );

    INTZF_Buffer <= ( (not Jmpz2_Buffer) and JMPZ and int_out and (not JMP_Ready) );
    INTZF <= INTZF_Buffer;

    IntZ_notF_Buffer <= ( Prediction_Done and int_out and (not JMPZ) and Jmpz2_Buffer);
    IntZ_notF <= IntZ_notF_Buffer;

    INT_Buffer <= (And1 or And2 or INTZF_Buffer or IntZ_notF_Buffer);
    INT <= INT_Buffer;
    

    int2_latch: WAR_latch port map(INT_Buffer,clk,reset_Buffer,'1', INT2_Buffer);
    INT2 <= INT2_Buffer;
    int3_latch: WAR_latch port map(INT2_Buffer,clk,reset_Buffer,'1', INT3_Buffer);
    INT3 <= INT3_Buffer;
    one_stall_int <= ( (not Prediction_Done) and int_out and (not INT_Buffer) and Jmpz2_Buffer);

    Reg1_enable <= reset_sg or INT2_Buffer;
    Reg1: generic_WAR_reg GENERIC map (REG_WIDTH => 16) port map(IR,clk,'0',Reg1_enable, Reg1_out);

    Reg2_enable <= reset1_Buffer or INT3_Buffer;
    Reg2: generic_WAR_reg GENERIC map (REG_WIDTH => 16) port map(IR,clk,'0',Reg2_enable, Reg2_out);
    -- Reg2_out changed to IR
    ISR_PC <= (Reg1_out & IR);

    reset_Buffer <= reset_sg or reset1_Buffer;
    reset <=reset_Buffer;
    reset1_latch_input <= '0' when reset1_Buffer = '1' else reset_sg;
    reset1_latch_en <= '1' when reset1_Buffer = '1' else reset_sg;
    reset1_latch: WAR_latch port map(reset1_latch_input,clk,'0',reset1_latch_en, reset1_Buffer);
    -- temp at first reset1 is U and that makes problems in fetch
    reset1 <= '0' when reset_sg = '1' else reset1_Buffer;
    Jmpz2_latch_enable <= JMPZ and JMP_Ready;
    jmpz2_latch: WAR_latch port map(JMPZ,clk,Prediction_Done,Jmpz2_latch_enable, Jmpz2_Buffer);
    
    Jmpz2<=Jmpz2_Buffer;


end Interrupt_arch ; -- Interrupt_arch