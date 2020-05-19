Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity main is
  port (
    clk,reset_sg,interrupt_sg:in std_logic;
    in_port: in std_logic_vector (31 downto 0);
    out_port: out std_logic_vector (31 downto 0)

  ) ;
end main;


architecture main_arch of main is

  component Fetch is
    port (
      clk,reset_sg,interrupt_sg:in std_logic;
      stall,RET_Ex_MEM, RTI_Ex_MEM,CALL_Ex_Mem,Predict,flush, Prediction_Done: in std_logic;
      Jmp_PC, Mem_data, PC_ID_EX: in std_logic_vector (31 downto 0);
      RTI_Buff, RET_Buff, CALL_Buff,RET_module_out, RTI_module_out, CALL_module_out, INT_module_out, reset_module_out: out std_logic;
      IR_Buff: out std_logic_vector (15 downto 0);
      PPC: out std_logic_vector (31 downto 0);
      jump_reg_add: out std_logic_vector (2 downto 0);
      Jmp_Int_PC: out std_logic_vector (31 downto 0);
      DHR1, DHR2, DHR3: in std_logic_vector (11 downto 0);
      one_two_out, exe_mem_out, dp_out: out std_logic
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
          dst1_add: in std_logic_vector (2 downto 0);
          dst2_add: in std_logic_vector (2 downto 0);
          dst1_data: in std_logic_vector (31 downto 0);
          dst2_data: in std_logic_vector (31 downto 0);
          dst1_write_enable: in std_logic;
          dst2_write_enable: in std_logic;
          dst_exec1: in std_logic_vector (31 downto 0);
          dst_exec2: in std_logic_vector (31 downto 0);
          exec_mem: in std_logic;
          one_or_two: in std_logic;
          DP: in std_logic;
      
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
          in_signal:out std_logic;
          jz:out std_logic;
          jmp:out std_logic;
          two_instruction_input: out std_logic;
          STALL: out std_logic;
          IR_out:out std_logic_vector (15 downto 0);
          EA:out std_logic_vector (31 downto 0);
          IMM:out std_logic_vector (31 downto 0);
          decreament_sp: out std_logic;
          increament_sp: out std_logic;
          TEMP_OUT:out std_logic_vector(4 downto 0);
          jump_reg_data: out std_logic_vector (31 downto 0);
          out1_data: out std_logic_vector (31 downto 0);
          out2_data: out std_logic_vector (31 downto 0);
          dst1_add_out:out std_logic_vector(2 downto 0);
          dst2_add_out:out std_logic_vector(2 downto 0);
      
          DHR1_decode_out: out std_logic_vector (11 downto 0);
          DHR2_decode_out: out std_logic_vector (11 downto 0);
          DHR3_decode_out: out std_logic_vector (11 downto 0);
          R1_out:out std_logic;
          R2_out:out std_logic;
          C1_out:out std_logic;
          C2_out:out std_logic;
          DP1_out:out std_logic;
          DP2_out:out std_logic;
          LOADCASE_out:out std_logic;
          JMP_PC: out std_logic_vector (31 downto 0);
          Stall_in: in std_logic
      
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
          decreament_sp: in std_logic;
          increament_sp: in std_logic;
          OUT_SIGNAL: in std_logic;
          IN_SIGNAL: in std_logic;
          MEMEORY_READ: in std_logic;
          MEMORY_WRITE: in std_logic;
          ALU_SRC2: in std_logic;
          ALU_ENABLE: in std_logic;
          JZ: in std_logic;
          JMP: in std_logic;
          STALL: in std_logic;
          R1:in std_logic;
          R2:in std_logic;
          C1:in std_logic;
          C2:in std_logic;
          DP1:in std_logic;
          DP2:in std_logic;
          LOADCASE:in std_logic;

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
          decreament_sp_out: out std_logic;
          increament_sp_out: out std_logic;
          OUT_SIGNAL_out: out std_logic;
          IN_SIGNAL_out: out std_logic;
          MEMEORY_READ_out: out std_logic;
          MEMORY_WRITE_out: out std_logic;
          ALU_SRC2_out: out std_logic;
          ALU_ENABLE_out: out std_logic;
          JZ_out: out std_logic;
          JMP_out: out std_logic;
          STALL_out: out std_logic;
          R1_out:out std_logic;
          R2_out:out std_logic;
          C1_out:out std_logic;
          C2_out:out std_logic;
          DP1_out:out std_logic;
          DP2_out:out std_logic;
          LOADCASE_out:out std_logic
        );
        end component;

        component EX_STAGE IS
        PORT(
		--INPUTA ,INPUTB :  IN std_logic_vector(3 downto 0);
		CLK ,RST       :  IN std_logic;
		IR : IN std_logic_vector(15 downto 0);

		INT, JMPZ :  IN std_logic;
		LOADCASE, DP1, C1, R1, DP2, C2, R2, Stall  :  IN std_logic;

		OUT1, OUT2, Dst1_EX, Dst1_MEM, Dst2_EX, Dst2_MEM, PC_ID, JMP_INT_PC  :  IN std_logic_vector(31 downto 0);
		ALU_Enable     :  IN std_logic;
		IMM, EA  :  IN std_logic_vector(31 downto 0);
		--flags : OUT std_logic_vector(3 downto 0);
		Predication, Predication_Done, Flush_out :  OUT std_logic; -- BranchPredicator outputs
		DP1_EX, DP2_EX : OUT std_logic;
		PC_EX, ADD_DST1_EX, DATA_DST2_EX : OUT std_logic_vector(31 downto 0);
		flag_from_mem : in std_logic_vector(3 downto 0);
		flag_to_mem : out std_logic_vector(3 downto 0)
		);
        END component;



        component EX_MEM_Buffer is
        port (
        CLK, RST, Stall: in std_logic;
        --IR_Buff: in std_logic_vector (15 downto 0);
        PC_IN, ADD_DST1_IN, DATA_DST2_IN : IN std_logic_vector(31 downto 0);
        PC_OUT, ADD_DST1_OUT, DATA_DST2_OUT : OUT std_logic_vector(31 downto 0);
        reg1_wr_IN, reg2_wr_IN, MEM_WR, MEM_RD  : IN  std_logic;
        reg1_wr_OUT, reg2_wr_OUT, MEM_WR_OUT, MEM_RD_OUT  : OUT  std_logic;
        CALL_IN, RET_IN, RTI_IN, OUT_IN, IN_IN, INT_IN ,INC_IN, DEC_IN, DP1_IN, DP2_IN :  IN std_logic;
        CALL_OUT, RET_OUT, RTI_OUT, OUT_OUT, IN_OUT, INT_OUT ,INC_OUT, DEC_OUT, DP1_OUT, DP2_OUT :  OUT std_logic;
        dst1_add_IN, dst2_add_IN : IN std_logic_vector(2 downto 0);
        dst1_add_OUT, dst2_add_OUT : OUT std_logic_vector(2 downto 0);
        ALU_Enable_EX_IN : IN std_logic;
        ALU_Enable_EX_OUT : OUT std_logic
        ) ;
        end component;

--Memory Stage Component
    component Memory_stage_entity IS
	PORT(
		clk,reset,
		reg1_wr_ex,reg2_wr_ex : IN std_logic;
		dst1_add_ex,dst2_add_ex : IN std_logic_vector(2 downto 0);
		mem_rd_ex,mem_wr_ex,out_ex,in_ex,
		call_ex,inc_ex,dec_ex,ret_ex,rti_ex,int_ex,
		ALU,dp1,dp2: IN  std_logic;
		address_dst1_ex,data_dst2_ex,dst1_mem,dst2_mem,pc_ex_mem,input_port  : IN  std_logic_vector(31 DOWNTO 0);
		reg1_wr_ex_output,reg2_wr_ex_output : OUT std_logic;
		dst1_add_ex_output,dst2_add_ex_output : OUT std_logic_vector(2 downto 0);
		dst1_mem_output,dst2_mem_output,out_port_output,mem_data_to_fetch : OUT std_logic_vector(31 DOWNTO 0);
		flag_from_execute : in std_logic_vector(3 downto 0);
		flag_to_execute : out std_logic_vector(3 downto 0)
		);
    END Component;

--WriteBack Stage Component
    component Mem_WB_entity IS
	PORT(
		reg1_wr_mem,reg2_wr_mem,clk,reset : IN  std_logic;
		dst1_add_mem,dst2_add_mem : IN std_logic_vector(2 downto 0);
		dst1_mem_input,dst2_mem_input : IN  std_logic_vector(31 DOWNTO 0);
		reg1_wr_mem_output,reg2_wr_mem_output : OUT std_logic;
		dst1_add_mem_output,dst2_add_mem_output : OUT std_logic_vector(2 downto 0);
		dst1_mem_output,dst2_mem_output : OUT std_logic_vector(31 DOWNTO 0)
		);
    END component;



    -- fetch missing signals
    signal mem_data_to_fetch: std_logic_vector (31 downto 0);
    signal RTI_Buff_fromFetch, RET_Buff_fromFetch, CALL_Buff_fromFetch,RET_module_out_fromFetch: std_logic;
    signal RTI_module_out_fromFetch, CALL_module_out_fromFetch, INT_module_out_fromFetch: std_logic;
    signal reset_module_out_fromFetch: std_logic;
    signal IR_Buff_fromFetch: std_logic_vector (15 downto 0);
    signal PPC_fromFetch: std_logic_vector (31 downto 0);
    signal jump_reg_add_fromFetch: std_logic_vector (2 downto 0);
    signal Jmp_Int_PC_fromFetch: std_logic_vector (31 downto 0);
    --
    --signal DHR1_decode, DHR2_decode, DHR3_decode: std_logic_vector (11 downto 0);
    signal one_two_out_fetch, exe_mem_out_fetch, dp_out_fetch: std_logic;

    -- if buffer outputs
    signal two_ints, CALL, RET, RTI, INT: std_logic;
    signal PC_IF_ID: std_logic_vector (31 downto 0);
    signal IR_IF_ID: std_logic_vector (15 downto 0);


    -- missing input signals to decode

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
    signal in_signal_Dout: std_logic;
    signal jz_Dout: std_logic;
    signal jmp_Dout: std_logic;
    signal two_instruction_input_Dout:  std_logic;
    signal STALL_Dout:  std_logic;
    signal IR_out_Dout: std_logic_vector (15 downto 0);
    signal EA_Dout: std_logic_vector (31 downto 0);
    signal IMM_Dout: std_logic_vector (31 downto 0);
    signal decreament_sp_Dout: std_logic;
    signal increament_sp_Dout: std_logic;
    signal TEMP_OUT_Dout: std_logic_vector(4 downto 0);
    signal jump_reg_data_Dout:  std_logic_vector (31 downto 0);
    signal out1_data_Dout:  std_logic_vector (31 downto 0);
    signal out2_data_Dout:  std_logic_vector (31 downto 0);
    signal dst1_add_out_Dout: std_logic_vector(2 downto 0);
    signal dst2_add_out_Dout: std_logic_vector(2 downto 0);
    signal DHR1_Dout, DHR2_Dout, DHR3_Dout: std_logic_vector (11 downto 0);
    signal R1_Dout, R2_Dout, C1_Dout, C2_Dout,DP1_Dout, DP2_Dout, LOADCASE_Dout: std_logic;
    signal JMP_PC_Dout: std_logic_vector (31 downto 0);

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
    signal decreament_sp_ID_EX: std_logic;
    signal increament_sp_ID_EX: std_logic;
    signal OUT_SIGNAL_out_ID_EX:  std_logic;
    signal IN_SIGNAL_out_ID_EX:  std_logic;
    signal MEMEORY_READ_out_ID_EX:  std_logic;
    signal MEMORY_WRITE_out_ID_EX:  std_logic;
    signal ALU_SRC2_out_ID_EX:  std_logic;
    signal ALU_ENABLE_out_ID_EX:  std_logic;
    signal JZ_out_ID_EX:  std_logic;
    signal JMP_out_ID_EX:  std_logic;
    signal STALL_out_ID_EX:  std_logic;
    signal R1_out_ID_EX, R2_out_ID_EX, C1_out_ID_EX: std_logic;
    signal C2_out_ID_EX, DP1_out_ID_EX, DP2_out_ID_EX, LOADCASE_out_ID_EX: std_logic;

    -- signals outed from Execute stage to Execute - Memory buffer
    signal Predication, Predication_Done, Flush_out :  std_logic; -- BranchPredicator outputs
    signal DP1_EX, DP2_EX : std_logic;
    signal PC_EX, ADD_DST1_EX, DATA_DST2_EX : std_logic_vector(31 downto 0);
    ------------------------------------------------------------------------
    -- signals outed from Execute buffer to Memory Stage
    signal PC_OUT, ADD_DST1_OUT, DATA_DST2_OUT :  std_logic_vector(31 downto 0);
    signal reg1_wr_EX_OUT, reg2_wr_EX_OUT, MEM_WR_OUT, MEM_RD_OUT,ALU_Enable_EX_OUT  : std_logic;
    signal CALL_EX_OUT, RET_EX_OUT, RTI_EX_OUT, OUT_OUT, IN_OUT, INT_EX_OUT ,INC_OUT, DEC_OUT, DP1_OUT, DP2_OUT : std_logic;
    signal dst1_add_EX_OUT, dst2_add_EX_OUT : std_logic_vector(2 downto 0);
    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    -- signals outed from Memory Stage to Memory/WriteBack Stage , output port is not related to the writeback stage
    signal reg1_mem_out,reg2_mem_out: std_logic;
    signal dst1_add_mem_out,dst2_add_mem_out: std_logic_vector(2 downto 0);
    signal dst1_mem_out,dst2_mem_out,out_port_out : std_logic_vector(31 DOWNTO 0);

    -- signals outed from WriteBack Stage to fetch
    signal reg1_wb_out,reg2_wb_out: std_logic;
    signal dst1_add_wb_out,dst2_add_wb_out: std_logic_vector(2 downto 0);
    signal dst1_wb_out,dst2_wb_out : std_logic_vector(31 DOWNTO 0);
    ------------------------------------------------------------------------
    SIGNAL Notfound : std_logic_vector(31 downto 0):= (others => '0');
	------------------------------------------------------------------------
	SIGNAL flag_in ,flag_out : std_logic_vector(3 downto 0);

begin

    --FETCH
    --Jmp_PC_inFetch <="00000000000000000000000000000000";
    fetchStage: Fetch port map(clk,reset_sg,interrupt_sg,STALL_Dout,RET_EX_OUT, RTI_EX_OUT,
    CALL_EX_OUT,Predication,Flush_out, Predication_Done,
    JMP_PC_Dout,mem_data_to_fetch,PC_IF_EX_out_ID_EX,
    RTI_Buff_fromFetch, RET_Buff_fromFetch,
    CALL_Buff_fromFetch,RET_module_out_fromFetch,RTI_module_out_fromFetch, CALL_module_out_fromFetch,
    INT_module_out_fromFetch,reset_module_out_fromFetch,IR_Buff_fromFetch,PPC_fromFetch,
    jump_reg_add_fromFetch,Jmp_Int_PC_fromFetch,
    DHR1_Dout, DHR2_Dout, DHR3_Dout,
    one_two_out_fetch, exe_mem_out_fetch, dp_out_fetch);

    --FETCH buffer
    if_id_buffer: IF_IR_Buffer port map(clk,RTI_Buff_fromFetch, RET_Buff_fromFetch, CALL_Buff_fromFetch,
        RET_module_out_fromFetch,RTI_module_out_fromFetch, CALL_module_out_fromFetch, INT_module_out_fromFetch,
        reset_module_out_fromFetch,two_instruction_input_Dout
        ,IR_Buff_fromFetch,PPC_fromFetch,
        two_ints, CALL, RET, RTI, INT,PC_IF_ID,IR_IF_ID);

    --DECODE

    Decode: decode_stage port map(clk,reset_module_out_fromFetch,Flush_out,IR_IF_ID,PC_IF_ID,RET,INT,CALL,RTI,two_ints,
        jump_reg_add_fromFetch,dst1_add_wb_out,dst2_add_wb_out,dst1_wb_out,dst2_wb_out,reg1_wb_out,reg2_wb_out,
        ADD_DST1_EX, DATA_DST2_EX, exe_mem_out_fetch, one_two_out_fetch, dp_out_fetch,call_Dout,RET_Dout,PC_IF_EX_Dout,
        INT_Dout,RTI_Dout,reg_write1_Dout,reg_write2_Dout,memory_read_Dout,memory_write_Dout,alu_src2_Dout,alu_enable_Dout,out_signal_Dout,
        in_signal_Dout, jz_Dout,jmp_Dout,two_instruction_input_Dout,STALL_Dout,IR_out_Dout,EA_Dout,IMM_Dout,decreament_sp_Dout, increament_sp_Dout,
        TEMP_OUT_Dout,jump_reg_data_Dout,out1_data_Dout,
        out2_data_Dout,dst1_add_out_Dout,dst2_add_out_Dout, DHR1_Dout, DHR2_Dout, DHR3_Dout, R1_Dout, R2_Dout, C1_Dout, C2_Dout,
        DP1_Dout, DP2_Dout, LOADCASE_Dout, JMP_PC_Dout,R1_out_ID_EX
    );

    TEMP_OUT_SG <= IR_out_Dout(13 downto 9);
    ID_EX_buffer: decode_execute_buffer port map(clk,reset_module_out_fromFetch,IR_out_Dout,RET_Dout,call_Dout,PC_IF_ID,
                INT,RTI_Dout,TEMP_OUT_SG,reg_write1_Dout,reg_write2_Dout,dst1_add_out_Dout,dst2_add_out_Dout,
                out1_data_Dout,out2_data_Dout,EA_Dout,IMM_Dout, decreament_sp_Dout, increament_sp_Dout,out_signal_Dout, in_signal_Dout,memory_read_Dout,memory_write_Dout,
                alu_src2_Dout,alu_enable_Dout,jz_Dout,jmp_Dout,STALL_Dout
                , R1_Dout, R2_Dout, C1_Dout, C2_Dout,DP1_Dout, DP2_Dout, LOADCASE_Dout,
                IR_out_ID_EX,
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
                 decreament_sp_ID_EX,
                 increament_sp_ID_EX,
                 OUT_SIGNAL_out_ID_EX  ,
                 IN_SIGNAL_out_ID_EX,
                 MEMEORY_READ_out_ID_EX ,
                 MEMORY_WRITE_out_ID_EX,
                 ALU_SRC2_out_ID_EX,
                 ALU_ENABLE_out_ID_EX,
                 JZ_out_ID_EX,
                 JMP_out_ID_EX,
                 STALL_out_ID_EX,
                 R1_out_ID_EX, R2_out_ID_EX, C1_out_ID_EX,
                 C2_out_ID_EX, DP1_out_ID_EX, DP2_out_ID_EX, LOADCASE_out_ID_EX
            );

  -- connect Execute Stage

  execute_component : EX_STAGE port map(clk, reset_module_out_fromFetch, IR_out_ID_EX, INT_out_ID_EX,
  JZ_out_ID_EX, LOADCASE_out_ID_EX, DP1_out_ID_EX, C1_out_ID_EX,R1_out_ID_EX,  DP2_out_ID_EX, C2_out_ID_EX, R2_out_ID_EX, STALL_out_ID_EX, OUT1_out_ID_EX,
  OUT2_out_ID_EX, ADD_DST1_OUT, dst1_wb_out, DATA_DST2_OUT, dst2_wb_out, PC_IF_EX_out_ID_EX,
  Jmp_Int_PC_fromFetch, ALU_ENABLE_out_ID_EX, IMM_out_ID_EX, EA_out_ID_EX, Predication,
  Predication_Done,  Flush_out, DP1_EX,  DP2_EX, PC_EX, ADD_DST1_EX,  DATA_DST2_EX,flag_in,flag_out);

  -- Execute Memory Buffer
  EX_MEM_Buffer_component : EX_MEM_Buffer port map (clk, reset_module_out_fromFetch, STALL_out_ID_EX,
                            PC_EX, ADD_DST1_EX, DATA_DST2_EX,
                            PC_OUT, ADD_DST1_OUT, DATA_DST2_OUT,
                            REG1_WR_out_ID_EX, REG2_WR_out_ID_EX,MEMORY_WRITE_out_ID_EX,MEMEORY_READ_out_ID_EX ,
                            reg1_wr_EX_OUT, reg2_wr_EX_OUT, MEM_WR_OUT, MEM_RD_OUT,
                            CALL_out_ID_EX, RET_out_ID_EX, RTI_out_ID_EX, OUT_SIGNAL_out_ID_EX,IN_SIGNAL_out_ID_EX,INT_out_ID_EX,increament_sp_ID_EX,decreament_sp_ID_EX,DP1_EX, DP2_EX,
                            CALL_EX_OUT, RET_EX_OUT, RTI_EX_OUT, OUT_OUT, IN_OUT, INT_EX_OUT ,INC_OUT, DEC_OUT, DP1_OUT, DP2_OUT,
                            DST1_ADD_out_ID_EX,DST2_ADD_out_ID_EX,
                            dst1_add_EX_OUT,dst2_add_EX_OUT,
                            ALU_ENABLE_out_ID_EX,
                            ALU_Enable_EX_OUT );

  -- notes  - all dp loadcase is missing and inc , dec , in signals and Dst1_EX, Dst1_MEM, Dst2_EX, Dst2_MEM,  JMP_INT_PC are also missing

  --Memory Stage , NOT ALU signal , dst1_mem,dst2_mem are missing , modify input port i.e. remove it from the inputs
  Memory_stage_component : Memory_stage_entity port map(clk, reset_module_out_fromFetch, reg1_wr_EX_OUT, reg2_wr_EX_OUT, dst1_add_EX_OUT, dst2_add_EX_OUT, MEM_RD_OUT, MEM_WR_OUT,OUT_OUT,IN_OUT,
                      CALL_EX_OUT,INC_OUT,DEC_OUT,RET_EX_OUT,RTI_EX_OUT,INT_EX_OUT,ALU_ENABLE_out_ID_EX,DP1_OUT,DP2_OUT,ADD_DST1_OUT,DATA_DST2_OUT,dst1_wb_out,dst2_wb_out,
                      PC_OUT,in_port,
                      reg1_mem_out,reg2_mem_out,dst1_add_mem_out,dst2_add_mem_out, -- output signals
                      dst1_mem_out,dst2_mem_out,out_port,mem_data_to_fetch,flag_out,flag_in);

  --WriteBack Stage
  WriteBack_stage_component : Mem_WB_entity port map(reg1_mem_out,reg2_mem_out,clk,reset_module_out_fromFetch,dst1_add_mem_out,dst2_add_mem_out,
                      dst1_mem_out,dst2_mem_out,
                      reg1_wb_out,reg2_wb_out,dst1_add_wb_out,dst2_add_wb_out, -- output signals
                      dst1_wb_out,dst2_wb_out
                      );



end main_arch ; -- arch
