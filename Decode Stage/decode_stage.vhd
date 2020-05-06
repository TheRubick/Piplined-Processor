LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity decode_stage is
  port(
    clk: in std_logic;
    reset: in std_logic;
    flush: in std_logic;
    IR: in std_logic_vector (15 downto 0);
    PC_IF_EX:in std_logic_vector (31 downto 0);
    RET: in std_logic;
    INT : in std_logic;
    CALL: in std_logic;
    RTI: in std_logic;
    TWO_INST: in std_logic;
    jump_reg_add: in std_logic_vector (2 downto 0);
    dst1_data: in std_logic_vector (31 downto 0);
    dst2_data: in std_logic_vector (31 downto 0);
    dst1_write_enable: in std_logic;
    dst2_write_enable: in std_logic;
    memory: in std_logic;

    call_out:out std_logic;
    RET_out:out std_logic;
    PC_IF_EX_out:out std_logic_vector (31 downto 0);
    INT_out:out std_logic;
    RTI_out:out std_logic;

    reg_write1:out std_logic;
    reg_write2:out std_logic;
    memory_read:out std_logic;
    memory_write:out std_logic;
    alu_src2:out std_logic;
    alu_enable:out std_logic;
    out_signal:out std_logic;
    jz:out std_logic;
    jmp:out std_logic;
    IR_out:out std_logic_vector (15 downto 0);
    EA:out std_logic_vector (31 downto 0);
    IMM:out std_logic_vector (31 downto 0);
    TEMP_OUT:out std_logic_vector(3 downto 0);
    jump_reg_data: out std_logic_vector (31 downto 0);
    out1_data: out std_logic_vector (31 downto 0);
    out2_data: out std_logic_vector (31 downto 0);
    dst1_add_out:out std_logic_vector(2 downto 0);
    dst2_add_out:out std_logic_vector(2 downto 0)

  );
end decode_stage;

architecture  decode_stage_arch of decode_stage is
    component decode_execute_buffer is
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
    end component;

    component reg_file is
      port(
        src1_add: in std_logic_vector (2 downto 0);
        src2_add: in std_logic_vector (2 downto 0);
        dst1_add: in std_logic_vector (2 downto 0);
        dst2_add: in std_logic_vector (2 downto 0);
        jump_reg_add: in std_logic_vector (2 downto 0);
        dst1_data: in std_logic_vector (31 downto 0);
        dst2_data: in std_logic_vector (31 downto 0);
        dst1_write_enable: in std_logic;
        dst2_write_enable: in std_logic;
        out1_data: out std_logic_vector (31 downto 0);
        out2_data: out std_logic_vector (31 downto 0);
        jump_reg_data: out std_logic_vector (31 downto 0);
        clk: in std_logic;
        reset: in std_logic
      );
    end component;

    component control_unit is
    port(
      clk: in std_logic;
      reset: in std_logic;
      flush: in std_logic;
      IR: in std_logic_vector (15 downto 0);
      call: in std_logic;
      RTI: in std_logic;
      interrupt: in std_logic;
      two_instruction: in std_logic;
      reg_write1: out std_logic;
      reg_write2: out std_logic;
      memory_read: out std_logic;
      memory_write: out std_logic;
      alu_src2: out std_logic;
      out_signal: out std_logic;
      alu_enable: out std_logic;
      jz: out std_logic;
      jmp: out std_logic;
      IR_out: out std_logic_vector (15 downto 0);
      EA: out std_logic_vector (31 downto 0);
      IMM: out std_logic_vector (31 downto 0)
    );
    end component;

    component mux2_generic is
    GENERIC(
       INPUT_WIDTH : INTEGER := 1);
      port (
        in1,in2: in std_logic_vector (INPUT_WIDTH - 1 downto 0);
        sel: in std_logic;
        mux_out: out std_logic_vector (INPUT_WIDTH - 1 downto 0)
        );
    end component;

    signal src2_add: std_logic_vector(2 downto 0);
    signal dst1_add: std_logic_vector(2 downto 0);
    signal dst2_add: std_logic_vector(2 downto 0);


    signal IR_8_6: std_logic_vector(2 downto 0);
    signal IR_2_0: std_logic_vector (2 downto 0);
    signal mux2_out: std_logic_vector (2 downto 0);

    BEGIN

    IR_8_6 <= IR(8 downto 6);
    IR_2_0 <= IR(2 downto 0);
    dst1_add <= IR_2_0;
    dst2_add <= mux2_out;
    src2_add <= IR(5 downto 3);
    dst1_add_out <= dst1_add;
    dst2_add_out<= dst2_add;

    call_out <=  CALL;
    RET_out <=  RET;
    PC_IF_EX_out <=  PC_IF_EX;
    INT_out <=  INT;
    RTI_out <=  RTI;





    mux2:mux2_generic GENERIC MAP (INPUT_WIDTH => 3) PORT MAP(IR_2_0, IR_8_6, memory, mux2_out);
    reg_file1:reg_file PORT MAP (mux2_out, src2_add, dst1_add, dst2_add, jump_reg_add, dst1_data, dst2_data, dst1_write_enable,
                                  dst2_write_enable, out1_data, out2_data, jump_reg_data, clk, reset);

    control_unit1:control_unit PORT MAP (clk, reset, flush, IR, CALL, RTI, INT, TWO_INST, reg_write1, reg_write2, memory_read, memory_write,
                                          alu_src2, out_signal, alu_enable, jz, jmp, IR_out, EA, IMM);


end decode_stage_arch;
