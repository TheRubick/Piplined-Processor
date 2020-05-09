vsim -gui work.interrupt

add wave -position insertpoint sim:/interrupt/*
force -freeze sim:/interrupt/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/interrupt/interrupt_sg 0 0
force -freeze sim:/interrupt/reset_sg 0 0
force -freeze sim:/interrupt/JMP 0 0
force -freeze sim:/interrupt/RET 0 0
force -freeze sim:/interrupt/RTI 0 0
force -freeze sim:/interrupt/JMPZ 0 0
force -freeze sim:/interrupt/IR 0000000000000011 0
force -freeze sim:/interrupt/RTI_MEM 0 0
force -freeze sim:/interrupt/RET_MEM 0 0
force -freeze sim:/interrupt/JMP_Ready 0 0
force -freeze sim:/interrupt/Prediction_Done 0 0
force -freeze sim:/interrupt/reset_sg 1 0
run
force -freeze sim:/interrupt/reset_sg 0 0
run
run