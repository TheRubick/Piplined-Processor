LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity decode_execute_buffer is
port (
  CLK: in std_logic;
  RESET: in std_logic;
  IR: in std_logic_vector (15 downto 0);
  RET: in std_logic;
  CALL: in std_logic;
  PC_IF_EX:in std_logic_vector (31 downto 0);
  INT : in std_logic;
  RTI: in std_logic;
  TEMP_OUT: in std_logic_vector (3 downto 0);
  REG1_WR: in std_logic;
  REG2_WR: in std_logic;
  DST1_ADD: in std_logic_vector (2 downto 0);
  DST2_ADD: in std_logic_vector (2 downto 0);
  OUT1: in std_logic_vector (31 downto 0);
  OUT2: in std_logic_vector (31 downto 0);
  EA: in std_logic_vector (31 downto 0);
  IMM: in std_logic_vector (31 downto 0);
  OUT_SIGNAL: in std_logic;
  MEMEORY_READ: in std_logic;
  MEMORY_WRITE: in std_logic;
  ALU_SRC2: in std_logic;
  ALU_ENABLE: in std_logic;
  JZ: in std_logic;
  JMP: in std_logic;

  IR_out: out std_logic_vector (15 downto 0);
  RET_out: out std_logic;
  CALL_out: out std_logic;
  PC_IF_EX_out:out std_logic_vector (31 downto 0);
  INT_out : out std_logic;
  RTI_out: out std_logic;
  TEMP_OUT_out: out std_logic_vector (3 downto 0);
  REG1_WR_out: out std_logic;
  REG2_WR_out: out std_logic;
  DST1_ADD_out: out std_logic_vector (2 downto 0);
  DST2_ADD_out: out std_logic_vector (2 downto 0);
  OUT1_out: out std_logic_vector (31 downto 0);
  OUT2_out: out std_logic_vector (31 downto 0);
  EA_out: out std_logic_vector (31 downto 0);
  IMM_out: out std_logic_vector (31 downto 0);
  OUT_SIGNAL_out: out std_logic;
  MEMEORY_READ_out: out std_logic;
  MEMORY_WRITE_out: out std_logic;
  ALU_SRC2_out: out std_logic;
  ALU_ENABLE_out: out std_logic;
  JZ_out: out std_logic;
  JMP_out: out std_logic
);
end decode_execute_buffer;

architecture  decode_execute_buffer_arch of decode_execute_buffer is
    component WAR_latch is
      port (
        d: in std_logic;
        clk: in std_logic;
        clear: in std_logic;
    enable: in std_logic;
        q: out std_logic

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

    BEGIN

    IR_BUFFER:generic_WAR_reg GENERIC MAP (REG_WIDTH => 16) PORT MAP (IR, CLK, RESET, '1', IR_out);
    RET_BUFFER:WAR_latch PORT MAP (RET, CLK, RESET, '1', RET_out);
    CALL_BUFFER:WAR_latch PORT MAP (CALL, CLK, RESET, '1', CALL_out);
    PC_IF_EX_BUFFER:generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) PORT MAP (PC_IF_EX, CLK, RESET, '1', PC_IF_EX_out);
    INT_BUFFER:WAR_latch PORT MAP (INT, CLK, RESET, '1', INT_out);
    RTI_BUFFER:WAR_latch PORT MAP (RTI, CLK, RESET, '1', RTI_out);
    TEMP_OUT_BUFFER:generic_WAR_reg GENERIC MAP (REG_WIDTH => 4) PORT MAP (TEMP_OUT, CLK, RESET, '1', TEMP_OUT_out);
    REG1_WR_BUFFER:WAR_latch PORT MAP (REG1_WR, CLK, RESET, '1', REG1_WR_out);
    REG2_WR_BUFFER:WAR_latch PORT MAP (REG2_WR, CLK, RESET, '1', REG2_WR_out);
    DST1_ADD_BUFFER:generic_WAR_reg GENERIC MAP (REG_WIDTH => 3) PORT MAP (DST1_ADD, CLK, RESET, '1', DST1_ADD_out);
    DST2_ADD_BUFFER:generic_WAR_reg GENERIC MAP (REG_WIDTH => 3) PORT MAP (DST2_ADD, CLK, RESET, '1', DST2_ADD_out);
    OUT1_BUFFER:generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) PORT MAP (OUT1, CLK, RESET, '1', OUT1_out);
    OUT2_BUFFER:generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) PORT MAP (OUT2, CLK, RESET, '1', OUT2_out);
    EA_BUFFER:generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) PORT MAP (EA, CLK, RESET, '1', EA_out);
    IMM_BUFFER:generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) PORT MAP (IMM, CLK, RESET, '1', IMM_out);
    OUT_SIGNAL_BUFFER:WAR_latch PORT MAP (OUT_SIGNAL, CLK, RESET, '1', OUT_SIGNAL_out);
    MEMEORY_READ_BUFFER:WAR_latch PORT MAP (MEMEORY_READ, CLK, RESET, '1', MEMEORY_READ_out);
    MEMORY_WRITE_BUFFER:WAR_latch PORT MAP (MEMORY_WRITE, CLK, RESET, '1', MEMORY_WRITE_out);
    ALU_SRC2_BUFFER:WAR_latch PORT MAP (ALU_SRC2, CLK, RESET, '1', ALU_SRC2_out);
    ALU_ENABLE_BUFFER:WAR_latch PORT MAP (ALU_ENABLE, CLK, RESET, '1', ALU_ENABLE_out);
    JZ_BUFFER:WAR_latch PORT MAP (JZ, CLK, RESET, '1', JZ_out);
    JMP_BUFFER:WAR_latch PORT MAP (JMP, CLK, RESET, '1', JMP_out);

end decode_execute_buffer_arch;
