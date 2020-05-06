vsim -gui work.decode_stage
add wave -position insertpoint sim:/decode_stage/*
force -freeze sim:/decode_stage/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/decode_stage/reset 1 0
add wave -position insertpoint  \
sim:/decode_stage/control_unit1/clk \
sim:/decode_stage/control_unit1/reset \
sim:/decode_stage/control_unit1/flush \
sim:/decode_stage/control_unit1/IR \
sim:/decode_stage/control_unit1/call \
sim:/decode_stage/control_unit1/RTI \
sim:/decode_stage/control_unit1/interrupt \
sim:/decode_stage/control_unit1/two_instruction \
sim:/decode_stage/control_unit1/reg_write1 \
sim:/decode_stage/control_unit1/reg_write2 \
sim:/decode_stage/control_unit1/memory_read \
sim:/decode_stage/control_unit1/memory_write \
sim:/decode_stage/control_unit1/alu_src2 \
sim:/decode_stage/control_unit1/out_signal \
sim:/decode_stage/control_unit1/alu_enable \
sim:/decode_stage/control_unit1/jz \
sim:/decode_stage/control_unit1/jmp \
sim:/decode_stage/control_unit1/IR_out \
sim:/decode_stage/control_unit1/EA \
sim:/decode_stage/control_unit1/IMM \
sim:/decode_stage/control_unit1/decoderOut \
sim:/decode_stage/control_unit1/one_operand \
sim:/decode_stage/control_unit1/two_operand \
sim:/decode_stage/control_unit1/memory \
sim:/decode_stage/control_unit1/branch \
sim:/decode_stage/control_unit1/reset_flush \
sim:/decode_stage/control_unit1/decoderIn \
sim:/decode_stage/control_unit1/mux1_out \
sim:/decode_stage/control_unit1/mux2_out \
sim:/decode_stage/control_unit1/mux3_out \
sim:/decode_stage/control_unit1/mux4_out \
sim:/decode_stage/control_unit1/X \
sim:/decode_stage/control_unit1/nop \
sim:/decode_stage/control_unit1/IR_temp_out \
sim:/decode_stage/control_unit1/decreament_sp \
sim:/decode_stage/control_unit1/increament_sp \
sim:/decode_stage/control_unit1/return_signal \
sim:/decode_stage/control_unit1/stall1 \
sim:/decode_stage/control_unit1/reg_write1_signal \
sim:/decode_stage/control_unit1/reg_write2_signal \
sim:/decode_stage/control_unit1/memory_read_signal \
sim:/decode_stage/control_unit1/memory_write_signal \
sim:/decode_stage/control_unit1/alu_src2_signal \
sim:/decode_stage/control_unit1/out_signal_signal \
sim:/decode_stage/control_unit1/alu_enable_signal \
sim:/decode_stage/control_unit1/jz_signal \
sim:/decode_stage/control_unit1/jmp_signal \
sim:/decode_stage/control_unit1/stall_out \
sim:/decode_stage/control_unit1/mux3_sel \
sim:/decode_stage/control_unit1/IR_bit15 \
sim:/decode_stage/control_unit1/current_state
run
force -freeze sim:/decode_stage/reset 0 0
force -freeze sim:/decode_stage/flush 0 0
force -freeze sim:/decode_stage/memory 0 0
force -freeze sim:/decode_stage/IR 1010000011000011 0
force -freeze sim:/decode_stage/RET 0 0
force -freeze sim:/decode_stage/INT 0 0
force -freeze sim:/decode_stage/CALL 0 0
force -freeze sim:/decode_stage/RTI 0 0
force -freeze sim:/decode_stage/TWO_INST 0 0
force -freeze sim:/decode_stage/PC_IF_EX 00000000000000000000000000000000 0
run
force -freeze sim:/decode_stage/IR 1000000000000011 0
run
force -freeze sim:/decode_stage/IR 0000000100000011 0
run