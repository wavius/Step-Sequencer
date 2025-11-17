module audio_generator_16b_signed (Clock, nStart, Select, Out);
	input Clock, nStart;
	input 		   	  [11:0] Select;
	output reg signed [31:0] Out;

	// Phase increment = freq_note/freq_clock * 2^N
	parameter C    = 32'd22474, C_sh = 32'd23810, D    = 32'd25225, D_sh = 32'd26726, E    = 32'd28315, F = 32'd29999, 
			    F_sh = 32'd31782, G    = 32'd33673, G_sh = 32'd35674, A    = 32'd37796, A_sh = 32'd40043, B = 32'd42424;

	reg [3:0] sum;
	integer i;
	always@(*)
	begin
		sum = 0;
		for (i = 0; i < 12; i = i + 1)
			sum = sum + Select[i];
	end

	wire signed [31:0] amplitude [11:0];
	
	waveform_generator_16b W1  (Clock, nStart, C,    amplitude[0]);
	waveform_generator_16b W2  (Clock, nStart, C_sh, amplitude[1]);
	waveform_generator_16b W3  (Clock, nStart, D,    amplitude[2]);
	waveform_generator_16b W4  (Clock, nStart, D_sh, amplitude[3]);
	waveform_generator_16b W5  (Clock, nStart, E,    amplitude[4]);
	waveform_generator_16b W6  (Clock, nStart, F,    amplitude[5]);
	waveform_generator_16b W7  (Clock, nStart, F_sh, amplitude[6]);
	waveform_generator_16b W8  (Clock, nStart, G,    amplitude[7]);
	waveform_generator_16b W9  (Clock, nStart, G_sh, amplitude[8]);
	waveform_generator_16b W10 (Clock, nStart, A,    amplitude[9]);
	waveform_generator_16b W11 (Clock, nStart, A_sh, amplitude[10]);
	waveform_generator_16b W12 (Clock, nStart, B,    amplitude[11]);

	reg signed [63:0] amplitude_sum;
	integer j;
	always@(posedge Clock)
	begin
		amplitude_sum = 0;
		for (j = 0; j < 12; j = j + 1)
		begin
			if (Select[j]) amplitude_sum = amplitude_sum + amplitude[j];
		end
		if (sum != 0) Out <= amplitude_sum >>> 1;
		else Out <= 0;
	end
endmodule

module waveform_generator_16b (Clock, nStart, phase_increment, amplitude);
	input Clock, nStart;
	input [31:0] phase_increment;
	output signed [31:0] amplitude;

	wire [31:0] phase_angle;
	numerically_controlled_oscillator_16b N1 (Clock, nStart, phase_increment, phase_angle);

	// sine lookup table
	rom4096x32 U1 (phase_angle[31:20], Clock, amplitude);
endmodule

module numerically_controlled_oscillator_16b (Clock, nStart, phase_increment, phase_angle);
	input Clock, nStart;
	input [31:0] phase_increment;
	output reg [31:0] phase_angle;
	
	always@(posedge Clock, negedge nStart)
		if (!nStart)
			phase_angle <= 0;
		else
			phase_angle <= phase_angle + phase_increment;
endmodule