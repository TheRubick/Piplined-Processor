Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity jdmain is
  port (
    clk,reset_sg,interrupt_sg:in std_logic;
    in_port: in std_logic_vector (31 downto 0);
    out_port: out std_logic_vector (31 downto 0)

  ) ;
end jdmain;


architecture jdmain_arch of jdmain is

    component Fetch is
        port (
          clk,reset_sg,interrupt_sg:in std_logic;
          stall,RET_Ex_MEM, RTI_Ex_MEM,CALL_Ex_Mem,Predict,flush, Prediction_Done: in std_logic;
          Jmp_PC, Mem_data, PC_ID_EX: in std_logic_vector (31 downto 0);
          RTI_Buff, RET_Buff, CALL_Buff,RET_module_out, RTI_module_out, CALL_module_out, INT_module_out, reset_module_out: out std_logic;
          IR_Buff: out std_logic_vector (15 downto 0);
          PPC: out std_logic_vector (31 downto 0);
          jump_reg_add: out std_logic_vector (2 downto 0)
        ) ;
      end component;

      component IF_IR_Buffer is
        port (
          clk,RTI_Buff, RET_Buff, CALL_Buff, RET_in, RTI_in, CALL_in, INT_in, reset, two_inst_in: in std_logic;
          IR_Buff: in std_logic_vector (15 downto 0);
          PPC: in std_logic_vector (31 downto 0);
          two_ints, CALL, RET, RTI, INT: out std_logic;
          PC_IF_ID: out std_logic_vector (31 downto 0);
          IR: out std_logic_vector (15 downto 0)
        ) ;
      end component;



      component decode_stage is
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
          two_instruction_input: out std_logic;
          STALL: out std_logic;
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
      end component;
      
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
          TEMP_OUT: in std_logic_vector (4 downto 0);
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
          STALL: in std_logic;
        
          IR_out: out std_logic_vector (15 downto 0);
          RET_out: out std_logic;
          CALL_out: out std_logic;
          PC_IF_EX_out:out std_logic_vector (31 downto 0);
          INT_out : out std_logic;
          RTI_out: out std_logic;
          TEMP_OUT_out: out std_logic_vector (4 downto 0);
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
          JMP_out: out std_logic;
          STALL_out: out std_logic
        );
        end component; 
      

    -- fetch missing signals
    signal stall_inFetch,RET_Ex_MEM_inFetch, RTI_Ex_MEM_inFetch: std_logic;
    signal CALL_Ex_Mem_inFetch,Predict_inFetch,flush_inFetch, Prediction_Done_inFetch: std_logic;
    signal Jmp_PC_inFetch, Mem_data_inFetch, PC_ID_EX_inFetch: std_logic_vector (31 downto 0);
    signal RTI_Buff_fromFetch, RET_Buff_fromFetch, CALL_Buff_fromFetch,RET_module_out_fromFetch: std_logic;
    signal RTI_module_out_fromFetch, CALL_module_out_fromFetch, INT_module_out_fromFetch: std_logic;
    signal reset_module_out_fromFetch: std_logic;
    signal IR_Buff_fromFetch: std_logic_vector (15 downto 0);
    signal PPC_fromFetch: std_logic_vector (31 downto 0);
    signal jump_reg_add_fromFetch: std_logic_vector (2 downto 0);

    -- if buffer outputs
    signal two_ints, CALL, RET, RTI, INT: std_logic;
    signal PC_IF_ID: std_logic_vector (31 downto 0);
    signal IR_IF_ID: std_logic_vector (15 downto 0);


    -- missing input signals to decode 
    signal dst1_data,dst2_data:  std_logic_vector (31 downto 0);
    signal dst1_write_enable,dst2_write_enable:  std_logic;
    
    --decode out signals
    signal call_Dout: std_logic;
    signal RET_Dout: std_logic;
    signal PC_IF_EX_Dout: std_logic_vector (31 downto 0);
    signal INT_Dout: std_logic;
    signal RTI_Dout: std_logic;

    signal reg_write1_Dout: std_logic;
    signal reg_write2_Dout: std_logic;
    signal memory_read_Dout: std_logic;
    signal memory_write_Dout: std_logic;
    signal alu_src2_Dout: std_logic;
    signal alu_enable_Dout: std_logic;
    signal out_signal_Dout: std_logic;
    signal jz_Dout: std_logic;
    signal jmp_Dout: std_logic;
    signal two_instruction_input_Dout:  std_logic;
    signal STALL_Dout:  std_logic;
    signal IR_out_Dout: std_logic_vector (15 downto 0);
    signal EA_Dout: std_logic_vector (31 downto 0);
    signal IMM_Dout: std_logic_vector (31 downto 0);
    signal TEMP_OUT_Dout: std_logic_vector(3 downto 0);
    signal jump_reg_data_Dout:  std_logic_vector (31 downto 0);
    signal out1_data_Dout:  std_logic_vector (31 downto 0);
    signal out2_data_Dout:  std_logic_vector (31 downto 0);
    signal dst1_add_out_Dout: std_logic_vector(2 downto 0);
    signal dst2_add_out_Dout: std_logic_vector(2 downto 0);

    -- ID_EX_Buffer signasl
    signal TEMP_OUT_SG: std_logic_vector (4 downto 0);
    --ID_EX_Buffer output signasl
    signal IR_out_ID_EX: std_logic_vector (15 downto 0);
    signal RET_out_ID_EX:  std_logic;
    signal CALL_out_ID_EX: std_logic;
    signal PC_IF_EX_out_ID_EX: std_logic_vector (31 downto 0);
    signal INT_out_ID_EX :  std_logic;
    signal RTI_out_ID_EX:  std_logic;
    signal TEMP_OUT_out_ID_EX:  std_logic_vector (4 downto 0);
    signal REG1_WR_out_ID_EX:  std_logic;
    signal REG2_WR_out_ID_EX: std_logic;
    signal DST1_ADD_out_ID_EX:  std_logic_vector (2 downto 0);
    signal DST2_ADD_out_ID_EX:  std_logic_vector (2 downto 0);
    signal OUT1_out_ID_EX:  std_logic_vector (31 downto 0);
    signal OUT2_out_ID_EX:  std_logic_vector (31 downto 0);
    signal EA_out_ID_EX:  std_logic_vector (31 downto 0);
    signal IMM_out_ID_EX:  std_logic_vector (31 downto 0);
    signal OUT_SIGNAL_out_ID_EX:  std_logic;
    signal MEMEORY_READ_out_ID_EX:  std_logic;
    signal MEMORY_WRITE_out_ID_EX:  std_logic;
    signal ALU_SRC2_out_ID_EX:  std_logic;
    signal ALU_ENABLE_out_ID_EX:  std_logic;
    signal JZ_out_ID_EX:  std_logic;
    signal JMP_out_ID_EX:  std_logic;
    signal STALL_out_ID_EX:  std_logic;

begin

    --FETCH
    fetchStage: Fetch port map(clk,reset_sg,interrupt_sg,STALL_Dout,RET_Ex_MEM_inFetch, RTI_Ex_MEM_inFetch,
    CALL_Ex_Mem_inFetch,Predict_inFetch,flush_inFetch, Prediction_Done_inFetch,
    Jmp_PC_inFetch,Mem_data_inFetch,PC_IF_EX_out_ID_EX,
    RTI_Buff_fromFetch, RET_Buff_fromFetch, 
    CALL_Buff_fromFetch,RET_module_out_fromFetch,RTI_module_out_fromFetch, CALL_module_out_fromFetch, 
    INT_module_out_fromFetch,reset_module_out_fromFetch,IR_Buff_fromFetch,PPC_fromFetch,jump_reg_add_fromFetch);

    --FETCH buffer
    if_id_buffer: IF_IR_Buffer port map(clk,RTI_Buff_fromFetch, RET_Buff_fromFetch, CALL_Buff_fromFetch,
        RET_module_out_fromFetch,RTI_module_out_fromFetch, CALL_module_out_fromFetch, INT_module_out_fromFetch,
        reset_module_out_fromFetch,two_instruction_input_Dout
        ,IR_Buff_fromFetch,PPC_fromFetch,
        two_ints, CALL, RET, RTI, INT,PC_IF_ID,IR_IF_ID);
    
    --DECODE

    Decode: decode_stage port map(clk,reset_module_out_fromFetch,flush_inFetch,IR_IF_ID,PC_IF_ID,RET,INT,CALL,RTI,two_ints,
        jump_reg_add_fromFetch,dst1_data,dst2_data,dst1_write_enable,dst2_write_enable,call_Dout,RET_Dout,PC_IF_EX_Dout,
        INT_Dout,RTI_Dout,reg_write1_Dout,reg_write2_Dout,memory_read_Dout,memory_write_Dout,alu_src2_Dout,alu_enable_Dout,out_signal_Dout,
        jz_Dout,jmp_Dout,two_instruction_input_Dout,STALL_Dout,IR_out_Dout,EA_Dout,IMM_Dout,
        TEMP_OUT_Dout,jump_reg_data_Dout,out1_data_Dout,
        out2_data_Dout,dst1_add_out_Dout,dst2_add_out_Dout
    );

    TEMP_OUT_SG <= IR_out_Dout(13 downto 9);
    ID_EX_buffer: decode_execute_buffer port map(clk,reset_module_out_fromFetch,IR_out_Dout,RET_Dout,call_Dout,PC_IF_ID,
                INT,RTI_Dout,TEMP_OUT_SG,reg_write1_Dout,reg_write2_Dout,dst1_add_out_Dout,dst2_add_out_Dout,
                out1_data_Dout,out2_data_Dout,EA_Dout,IMM_Dout,out_signal_Dout,memory_read_Dout,memory_write_Dout,
                alu_src2_Dout,alu_enable_Dout,jz_Dout,jmp_Dout,STALL_Dout,IR_out_ID_EX,
                RET_out_ID_EX,
                 CALL_out_ID_EX,
                 PC_IF_EX_out_ID_EX,
                 INT_out_ID_EX,
                 RTI_out_ID_EX,
                 TEMP_OUT_out_ID_EX,
                 REG1_WR_out_ID_EX,
                 REG2_WR_out_ID_EX,
                 DST1_ADD_out_ID_EX,
                 DST2_ADD_out_ID_EX,
                 OUT1_out_ID_EX,
                 OUT2_out_ID_EX,
                 EA_out_ID_EX,
                 IMM_out_ID_EX,
                 OUT_SIGNAL_out_ID_EX  ,
                 MEMEORY_READ_out_ID_EX ,
                 MEMORY_WRITE_out_ID_EX,
                 ALU_SRC2_out_ID_EX,
                 ALU_ENABLE_out_ID_EX,
                 JZ_out_ID_EX,
                 JMP_out_ID_EX,STALL_out_ID_EX
            );

end jdmain_arch ; -- arch