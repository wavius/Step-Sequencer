transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/rom {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/rom/rom512x16.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/vga_adapter {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/vga_adapter/vga_pll.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/vga_adapter {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/vga_adapter/vga_display.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/vga_adapter {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/vga_adapter/vga_controller.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/vga_adapter {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/vga_adapter/vga_address_translator.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/vga_adapter {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/vga_adapter/vga_adapter.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/ps2_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/ps2_controller/PS2_Controller.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/ps2_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/ps2_controller/Altera_UP_PS2_Data_In.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/ps2_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/ps2_controller/Altera_UP_PS2_Command_Out.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/input_controllers {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/input_controllers/sevenseg.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/input_controllers {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/input_controllers/move_input.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/input_controllers {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/input_controllers/loop_input.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/input_controllers {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/input_controllers/bpm_input.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/dac_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/dac_controller/DAC_controller.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/avconf {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/avconf/I2C_Controller.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/avconf {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/avconf/avconf.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_generators {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_generators/loop_counter.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_generators {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_generators/BPM_counter.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_generators {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_generators/audio_generator_16b_signed.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_generators {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_generators/audio_generator_12b_unsigned.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller/Audio_Controller.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller/Audio_Clock.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller/Altera_UP_SYNC_FIFO.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller/Altera_UP_Clock_Edge.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller/Altera_UP_Audio_Out_Serializer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller/Altera_UP_Audio_In_Deserializer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/audio_controller/Altera_UP_Audio_Bit_Counter.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer {D:/GitHub/ECE241-Project/Quartus/step_sequencer/step_sequencer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer {D:/GitHub/ECE241-Project/Quartus/step_sequencer/input_interface.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer {D:/GitHub/ECE241-Project/Quartus/step_sequencer/display_interface.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer {D:/GitHub/ECE241-Project/Quartus/step_sequencer/audio_interface.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/rom {D:/GitHub/ECE241-Project/Quartus/step_sequencer/modules/rom/rom256x12.v}
vlog -vlog01compat -work work +incdir+D:/GitHub/ECE241-Project/Quartus/step_sequencer/db {D:/GitHub/ECE241-Project/Quartus/step_sequencer/db/audio_clock_altpll.v}

