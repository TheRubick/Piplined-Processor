vsim -gui work.main
force -freeze sim:/main/clk 1 0, 0 {50 ps} -r 100
mem load -i D:/CMP-THIRD-YEAR-2ND-TERM/Arch/project/Piplined-Processor/Assembler/instructionMemory.mem /main/fetchStage/memory/ram
mem load -i D:/CMP-THIRD-YEAR-2ND-TERM/Arch/project/Piplined-Processor/Assembler/dataMemory.mem /main/Memory_stage_component/dataMemComponent/ram
force -freeze sim:/main/reset_sg 1 0
add wave -position insertpoint  \
sim:/main/clk
add wave -position insertpoint  \
sim:/main/reset_sg
add wave -position insertpoint  \
sim:/main/interrupt_sg
add wave -position insertpoint  \
sim:/main/in_port \
sim:/main/out_port
add wave -position 25  sim:/main/Memory_stage_component/flag_from_execute
add wave -position 26  sim:/main/Memory_stage_component/flag_to_execute
add wave -position insertpoint  \
sim:/main/PC_IF_ID
add wave -position insertpoint  \
sim:/main/Decode/reg_file1/loop1(0)/regs/q
add wave -position insertpoint  \
sim:/main/Decode/reg_file1/loop1(1)/regs/q
add wave -position insertpoint  \
sim:/main/Decode/reg_file1/loop1(2)/regs/q
add wave -position insertpoint  \
sim:/main/Decode/reg_file1/loop1(3)/regs/q
add wave -position insertpoint  \
sim:/main/Decode/reg_file1/loop1(4)/regs/q
add wave -position insertpoint  \
sim:/main/Decode/reg_file1/loop1(5)/regs/q
add wave -position insertpoint  \
sim:/main/Decode/reg_file1/loop1(6)/regs/q
add wave -position insertpoint  \
sim:/main/Decode/reg_file1/loop1(7)/regs/q
add wave -position insertpoint  \
sim:/main/Memory_stage_component/spInputData \
sim:/main/Memory_stage_component/spOutputData
run
force -freeze sim:/main/reset_sg 0 0
force -freeze sim:/main/in_port 1'h118 0
run
run
run
run
run
force -freeze sim:/main/in_port 1'h18 0
run
force -freeze sim:/main/in_port 1'h2 0
run
force -freeze sim:/main/in_port 1'h30 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
force -freeze sim:/main/in_port 1'h38 0
run
run
run
run
run
force -freeze sim:/main/in_port 1'h50 0
run
force -freeze sim:/main/in_port 1'h0 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run