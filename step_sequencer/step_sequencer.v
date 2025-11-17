module step_sequencer(
    // Inputs
    input            CLOCK_50,
    input      [3:0] KEY,
	 input 	   [9:0] SW,

    // Outputs
    output     [6:0] HEX0,
    output     [6:0] HEX1,
    output     [6:0] HEX2,
    output     [6:0] HEX3,
    output     [6:0] HEX4,
    output     [6:0] HEX5,
    output     [9:0] LEDR,
	 
	 output 		 AUD_XCK,
	 output 		 AUD_DACDAT,

	 output 	 	 FPGA_I2C_SCLK,
	 output 	 	 DAC_I2C_SCLK, // PIN_Y17,  GPIO_0[1]
	 output 		 DAC_I2C_A0,   // PIN_AD17, GPIO_0[2]
	 
	 // Bidirectionals
	 inout 		 AUD_BCLK,
	 inout 		 AUD_ADCLRCK,
	 inout 		 AUD_DACLRCK,

	 inout 		 FPGA_I2C_SDAT,
	 inout 		 DAC_I2C_SDAT, // PIN_AC18, GPIO_0[0]
	 
	 inout       PS2_CLK,
    inout       PS2_DAT
);
	 
	 // Internal wires
	 wire       nReset;
	 wire       Select;
	 
	 wire       Start;
	 wire [6:0] Loops;
	 wire [9:0] BPM;
	 wire [3:0] Direction;
	 wire 		Command;
	 
	 
	 // Combinational logic
	 assign nReset = KEY[0];
	 assign Select = {2'b0, SW[9:0]};


	audio_interface A1 (
		// Inputs
		.CLOCK_50      (CLOCK_50),
		.nStart        (~Start),       // Start playback
		.nReset        (nReset),       // Reset
		.Select        (Select),	    // Tone select
		.Loops         (Loops),        // Number of playback loops
		.BPM           (BPM),          // Beats per minute
		

		// Bidirectionals
		.AUD_BCLK      (AUD_BCLK),
		.AUD_ADCLRCK   (AUD_ADCLRCK ),
		.AUD_DACLRCK   (AUD_DACLRCK ),

		.FPGA_I2C_SDAT (FPGA_I2C_SDAT),
		.DAC_I2C_SDAT  (DAC_I2C_SDAT),  // PIN_AC18, GPIO_0[0]

		// Outputs
		.AUD_XCK       (AUD_XCK),
		.AUD_DACDAT    (AUD_DACDAT),

		.FPGA_I2C_SCLK (FPGA_I2C_SCLK),
		.DAC_I2C_SCLK  (DAC_I2C_SCLK ), // PIN_Y17,  GPIO_0[1]
		.DAC_I2C_A0    (DAC_I2C_A0),    // PIN_AD17, GPIO_0[2]
	);
	
	input_interface I1 (
    // Inputs
    .CLOCK_50  (CLOCK_50),
    .nReset    (nReset),

    // Outputs
    .HEX0		(HEX0),
    .HEX1		(HEX1),
    .HEX2		(HEX2),
    .HEX3		(HEX3),
    .HEX4		(HEX4),
    .HEX5		(HEX5),
    .LEDR		(LEDR[9:0]),

    .BPM       (BPM),
    .Loops		(Loops),
    .Direction (Direction),
    .Command   (Command),
	 .Start     (Start),

    // Bidirectionals
    .PS2_CLK	(PS2_CLK),
    .PS2_DAT   (PS2_DAT)
);

endmodule


