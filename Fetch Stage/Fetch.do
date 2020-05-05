vsim -gui work.fetch
add wave -position insertpoint sim:/fetch/*
force -freeze sim:/fetch/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/fetch/reset_sg 1 0
force -freeze sim:/fetch/interrupt_sg 0 0
force -freeze sim:/fetch/stall 0 0
force -freeze sim:/fetch/RET_Ex_MEM 0 0
force -freeze sim:/fetch/RTI_Ex_MEM 0 0
force -freeze sim:/fetch/CALL_Ex_Mem 0 0
force -freeze sim:/fetch/Predict 0 0
force -freeze sim:/fetch/flush 0 0
force -freeze sim:/fetch/Prediction_Done 0 0
force -freeze sim:/fetch/Jmp_PC 00000000000000000000000000000000 0
force -freeze sim:/fetch/Mem_data 00000000000000000000000000000000 0
force -freeze sim:/fetch/PC_ID_EX 00000000000000000000000000000000 0
run
force -freeze sim:/fetch/reset_sg 0 0
run