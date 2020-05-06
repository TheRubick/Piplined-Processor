vsim work.ex_stage
add wave -position end  sim:/ex_stage/CLK
add wave -position end  sim:/ex_stage/RST
add wave -position end  sim:/ex_stage/IR
add wave -position end  sim:/ex_stage/PC_ID
add wave -position end  sim:/ex_stage/DP1
add wave -position end  sim:/ex_stage/DP2
add wave -position end  sim:/ex_stage/R1
add wave -position end  sim:/ex_stage/R2
add wave -position end  sim:/ex_stage/Stall
add wave -position end  sim:/ex_stage/LOADCASE
add wave -position end  sim:/ex_stage/INT
add wave -position end  sim:/ex_stage/JMPZ
#add wave -position end  sim:/ex_stage/PR_Done
#add wave -position end  sim:/ex_stage/Flush
add wave -position end  sim:/ex_stage/OUT1
add wave -position end  sim:/ex_stage/OUT2
add wave -position end  sim:/ex_stage/IMM
add wave -position end  sim:/ex_stage/flagin
add wave -position end  sim:/ex_stage/flagout
add wave -position end  sim:/ex_stage/ALUOUT
add wave -position end  sim:/ex_stage/ADD_DST1_EX
add wave -position end  sim:/ex_stage/DATA_DST2_EX
add wave -position end  sim:/ex_stage/DP1_EX
add wave -position end  sim:/ex_stage/DP2_EX
add wave -position end  sim:/ex_stage/PC_EX
add wave -position end  sim:/ex_stage/Flush_out
add wave -position end  sim:/ex_stage/Predication
add wave -position end  sim:/ex_stage/Predication_Done
add wave -position end  sim:/ex_stage/BranchPredicator_Map/ZeroFlag
add wave -position end  sim:/ex_stage/BranchPredicator_Map/result
add wave -position end  sim:/ex_stage/BranchPredicator_Map/compare
add wave -position end  sim:/ex_stage/BranchPredicator_Map/FSM_Predicator/current_state


force -freeze sim:/ex_stage/CLK 1 0, 0 {50 ps} -r 100
force -freeze sim:/ex_stage/RST 1 0
add wave -position 7  sim:/ex_stage/ALU_Enable
force -freeze sim:/ex_stage/ALU_Enable 0 0
force -freeze sim:/ex_stage/DP1 0 0
force -freeze sim:/ex_stage/DP2 0 0
force -freeze sim:/ex_stage/R1 0 0
force -freeze sim:/ex_stage/R2 0 0
force -freeze sim:/ex_stage/Stall 0 0
force -freeze sim:/ex_stage/LOADCASE 0 0
force -freeze sim:/ex_stage/INT 0 0
force -freeze sim:/ex_stage/JMPZ 0 0
#force -freeze sim:/ex_stage/PR_Done 0 0
#force -freeze sim:/ex_stage/Flush 0 0
force -freeze sim:/ex_stage/OUT1 00000000000000000000000000000000 0
force -freeze sim:/ex_stage/OUT2 00000000000000000000000000000000 0
force -freeze sim:/ex_stage/IMM 00000000000000000000000000000000 0
force -freeze sim:/ex_stage/PC_ID 00000000000000000000000000000000 0
force -freeze sim:/ex_stage/IR 0000000000000000 0
run

force -freeze sim:/ex_stage/RST 0 0
force -freeze sim:/ex_stage/ALU_Enable 1 0
force -freeze sim:/ex_stage/IR 0010000000000000
force -freeze sim:/ex_stage/OUT1 00000000000000000000000000000001 0
force -freeze sim:/ex_stage/OUT2 00000000000000000000000000000010 0
force -freeze sim:/ex_stage/IMM 00000000000000000000000000000100 0
run
force -freeze sim:/ex_stage/OUT1 11111111111111111111111111111111 0
run

force -freeze sim:/ex_stage/IR 0011110000000000 0
force -freeze sim:/ex_stage/OUT1 00000000000000000000000000000001 0
force -freeze sim:/ex_stage/IMM 00000000000000000000000000000100 0
run


----------------------



#vsim work.branchpredicator
#add wave -position end  sim:/branchpredicator/CLK
#add wave -position end  sim:/branchpredicator/RST
#add wave -position end  sim:/branchpredicator/JMPZ
#add wave -position end  sim:/branchpredicator/ZeroFlag
#dd wave -position end  sim:/branchpredicator/Predication_Done
#add wave -position end  sim:/branchpredicator/Flush
#add wave -position end  sim:/branchpredicator/Predication
#add wave -position end  sim:/branchpredicator/result
#add wave -position end  sim:/branchpredicator/FSM_Predicator/current_state
#force -freeze sim:/branchpredicator/CLK 1 0, 0 {50 ps} -r 100
#force -freeze sim:/branchpredicator/RST 1 0
#run
#force -freeze sim:/branchpredicator/ZeroFlag 0 0
#force -freeze sim:/branchpredicator/JMPZ 0 0
#run
#force -freeze sim:/branchpredicator/RST 0 0
#force -freeze sim:/branchpredicator/JMPZ 1 0
