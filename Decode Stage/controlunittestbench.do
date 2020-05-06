vsim -gui work.control_unit
add wave -position insertpoint sim:/control_unit/*
force -freeze sim:/control_unit/reset 1 0
force -freeze sim:/control_unit/clk 1 0, 0 {50 ps} -r 100
run
force -freeze sim:/control_unit/reset 0 0
force -freeze sim:/control_unit/flush 0 0
force -freeze sim:/control_unit/IR 1010000011000011 0
force -freeze sim:/control_unit/call 0 0
force -freeze sim:/control_unit/RTI 0 0
force -freeze sim:/control_unit/interrupt 0 0
force -freeze sim:/control_unit/two_instruction 0 0
run
force -freeze sim:/control_unit/IR 0000000000000011 0
run
force -freeze sim:/control_unit/two_instruction 1 0
force -freeze sim:/control_unit/IR 0000000100000011 0
run