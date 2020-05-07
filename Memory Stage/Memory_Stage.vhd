LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY Memory_stage_entity IS
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
		dst1_mem_output,dst2_mem_output,out_port_output,mem_data_to_fetch : OUT std_logic_vector(31 DOWNTO 0)
		);
END ENTITY Memory_stage_entity;

ARCHITECTURE Memory_stage_arch OF Memory_stage_entity IS

--Latch component
component WAR_latch is
  port (
    d: in std_logic;
    clk: in std_logic;
    clear: in std_logic;
enable: in std_logic;
    q: out std_logic

  ) ;
 end component;

--generic latch component
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
 
--mux2_generic component
component mux2_generic is
GENERIC(
   INPUT_WIDTH : INTEGER := 1);
  port (
    in1,in2: in std_logic_vector (INPUT_WIDTH - 1 downto 0);
sel: in std_logic;
    mux_out: out std_logic_vector (INPUT_WIDTH - 1 downto 0)
    );

end component;

--mux4_generic component
component mux4_generic is
GENERIC(
   INPUT_WIDTH : INTEGER := 16);
  port (
    inp0: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
	 inp1: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
 inp2: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
 inp3: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
    sel: in std_logic_vector (1 downto 0);
    mux_output: out std_logic_vector(INPUT_WIDTH - 1 downto 0)
  ) ;
end component ;

-- data memory component
component dataMemory IS
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address : IN  std_logic_vector(31 DOWNTO 0);
		datain  : IN  std_logic_vector(31 DOWNTO 0);
		dataout : OUT std_logic_vector(31 DOWNTO 0));
END component;


signal RF,SF,FlagRegEnable,WR_sig,RD_sig,
		incSpWire,decSpWire : std_logic;
signal FlagRegInput,Flag4BitsOutput : std_logic_vector(3 downto 0);
signal Flag_CT,current_address,current_data,datamem1,dataMem2,dp1MuxOutput,dataInputCurrentData,
	dst2_mem_wire,
	spInputData,spOutputData,updateSpInput,updateSpPlusTwo,updateSpMinusTwo,dp1MuxStackPointerOutput : std_logic_vector(31 downto 0);
signal currentDataSel,updateSpSel : std_logic_vector(1 downto 0);

BEGIN

	--RF signal
		RFlatch : WAR_latch port map(rti_ex,clk,reset,'1',RF); 
	--SF signal
		SFlatch : WAR_latch port map(int_ex,clk,reset,'1',SF);

	--Flag Register Part
		-- 4 Bit Flag Register
		FlagRegMux: mux2_generic GENERIC MAP (INPUT_WIDTH => 4) port map("0000","0000",RF,FlagRegInput);
		FlagRegEnable <= RF or ALU;
		Flag4BitsReg : generic_WAR_reg GENERIC MAP (REG_WIDTH => 4) port map(FlagRegInput,clk,reset,FlagRegEnable,Flag4BitsOutput);
		--concatinating the output with 28 bits
		Flag_CT <= "0000000000000000000000000000" & Flag4BitsOutput;
		
	--Current data part
		currentDataSel <= (call_ex or int_ex) & SF; --selector of this part
		CurrentDataBlock : mux4_generic GENERIC MAP (INPUT_WIDTH => 32) port map(data_dst2_ex,Flag_CT,pc_ex_mem,"UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU",currentDataSel,current_data);
		
	
	
	--Data Memory Part
		dp1Mux: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map(address_dst1_ex,dst1_mem,dp1,dp1MuxOutput);
		dp2Mux: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map(data_dst2_ex,dst2_mem,dp2,dst2_mem_wire);
		
		--Read and Write signals
		RD_sig <= RF or mem_rd_ex;
		WR_sig <= SF or mem_wr_ex;
		
		dataMemComponent : dataMemory port map(clk,WR_sig,current_address,current_data,datamem1);
		mem_data_to_fetch <= datamem1;
		
		dp1MuxDataMem1: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map(datamem1,dp1MuxOutput,RD_sig,dataMem2);
		inputPortMuxDataMem2: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map(dataMem2,input_port,in_ex,dst1_mem_output);
		
	--output port part
		OutPortLatch : generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) port map(dst2_mem_wire,clk,reset,'1',out_port_output); -- here we used wire because we need the dst2_mem output to be "input" in the out port
	
	--sp part
		
		--sp Latch
		spLatch: generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) port map(spInputData,clk,reset,'1',spOutputData);
		--incSpWire
		incSpWire <= inc_ex or RF or SF or rti_ex or int_ex or ret_ex;
		--decSpWire
		decSpWire <= dec_ex or int_ex or call_ex;
		--updateSp Latch
		updateSpPlusTwo <= spInputData + 2;
		updateSpMinusTwo <= spInputData - 2;
		--mux41 of assigning the updateSpInput
		updateSpSel <= decSpWire & incSpWire;
		spUpdateInputMux : mux4_generic GENERIC MAP (INPUT_WIDTH => 32) port map(spOutputData,updateSpPlusTwo,updateSpMinusTwo,"UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU",updateSpSel,updateSpInput);
		updateSpLatch: generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) port map(updateSpInput,clk,reset,'1',spInputData);
		--dp1MuxOutputMuxspOutput
		dp1MuxOutputMuxspOutput: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map(dp1MuxOutput,spOutputData,decSpWire,dp1MuxStackPointerOutput);
		--dp1MuxStackPointerOutput Mux spInput
		dp1MuxSPOutputMuxspInput: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map(dp1MuxStackPointerOutput,spInputData,incSpWire,current_address);
		
	--Output wires of this stage
		reg1_wr_ex_output <= reg1_wr_ex;
		reg2_wr_ex_output <= reg2_wr_ex;
		dst1_add_ex_output <= dst1_add_ex;
		dst2_add_ex_output <= dst2_add_ex;
		--dst1_mem_output is assigned above
		dst2_mem_output <= dst2_mem_wire;
END Memory_stage_arch;



