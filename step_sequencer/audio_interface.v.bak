module audio_interface (
	// Inputs
	CLOCK_50,
	KEY,
	SW,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,
	DAC_I2C_SDAT, // PIN_AC18, GPIO_0[0]

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	DAC_I2C_SCLK, // PIN_Y17,  GPIO_0[1]
	DAC_I2C_A0,   // PIN_AD17, GPIO_0[2]
	LEDR
);

	// Inputs
	input		  CLOCK_50;
	input	[1:0] KEY;
	input	[9:0] SW;

	// Bidirectionals
	inout  		  AUD_BCLK;
	inout		  AUD_ADCLRCK;
	inout		  AUD_DACLRCK;

	inout		  FPGA_I2C_SDAT;
	inout		  DAC_I2C_SDAT;

	// Outputs
	output	      AUD_XCK;
	output	      AUD_DACDAT;

	output	      FPGA_I2C_SCLK;
	output        DAC_I2C_SCLK;
	output        DAC_I2C_A0;
	output [9:0]  LEDR;

	// Internal Wires
	wire          audio_out_allowed;
	wire          write_audio_out;

	wire [11:0]   Select; // Tone select
	wire          Step;   // Step pulse
	wire          nStart; // Start playback
	wire [9:0]   BPM;    // Beats per minute
	wire [6:0]    Loops;  // Number of playback loops
	wire          Play;   // Playback enable
	wire [31:0]   Audio_out;    // Audio output

	// DAC clock signals
	wire clk781_250kHz;

	// DAC wires
	wire 		  clk_2x400kHz = clk781kHz; // 50_000_000 / 64
	wire [11:0]   DAC_signal;

	// DAC I2C
	wire 		  SCL_in  = DAC_I2C_SCLK;
	wire 		  SDA_in  = DAC_I2C_SDAT;

	wire 		  SCL_o, SCL_t;
	wire 		  SDA_o, SDA_t;

	// Internal Registers
	reg [31:0]    left_channel_audio_out;
	reg [31:0]    right_channel_audio_out;

	// Sequential Logic
	always@(posedge CLOCK_50)
	begin
		if (Play)
		begin
			left_channel_audio_out	<= Audio_out;
			right_channel_audio_out <= Audio_out;
		end
		else
		begin
			left_channel_audio_out	<= 0;
			right_channel_audio_out <= 0;
		end
	end

	// Combinational Logic
	assign DAC_I2C_SCLK = SCL_t ? 1'bz : SCL_o;
	assign DAC_I2C_SDAT = SDA_t ? 1'bz : SDA_o;
	assign DAC_I2C_A0   = 1'b0;

	assign write_audio_out = audio_out_allowed;

	assign Select = {5'b0, SW[6:0]};
	assign nStart = KEY[1];
	assign BPM    = 10'd100;
	assign Loops  = {4'b0, SW[9:7]};

	assign LEDR[7:0] = Audio_out[7:0];
	assign LEDR[9]   = Step;
	assign LEDR[8]   = Play;

	// Internal Modules
	BPM_counter B1 (
		.Clock  (CLOCK_50), 
		.nStart (nStart), 
		.BPM    (BPM), 
		.Step   (Step)
	);

	loop_counter L1 (
		.nReset (KEY[0]),
		.nStart (nStart), 
		.Step   (Step), 
		.Loops  (Loops), 
		.Play   (Play)
	);

	audio_generator_16b_signed A1 (
		.Clock  (CLOCK_50),
		.nStart (nStart),
		.Select (Select),
		.Out    (Audio_out)
	);

	audio_generator_12b_unsigned A2 (
		.Clock  (CLOCK_50),
		.nStart (nStart),
		.Select (Select),
		.Out    (DAC_signal)
	);

	Audio_Controller AC1 (
		// Inputs
		.CLOCK_50				 (CLOCK_50),
		.reset					 (~KEY[0]),

		.clear_audio_in_memory	 (),
		.read_audio_in			 (),
		
		.clear_audio_out_memory	 (),
		.left_channel_audio_out	 (left_channel_audio_out),
		.right_channel_audio_out (right_channel_audio_out),
		.write_audio_out		 (write_audio_out),

		.AUD_ADCDAT				 (),

		// Bidirectionals
		.AUD_BCLK				 (AUD_BCLK),
		.AUD_ADCLRCK			 (AUD_ADCLRCK),
		.AUD_DACLRCK			 (AUD_DACLRCK),

		// Outputs
		.audio_in_available		 (),
		.left_channel_audio_in	 (),
		.right_channel_audio_in	 (),

		.audio_out_allowed		 (audio_out_allowed),

		.AUD_XCK			     (AUD_XCK),
		.AUD_DACDAT				 (AUD_DACDAT)
	);

	avconf #(.USE_MIC_INPUT(1)) AVC1 (
		.FPGA_I2C_SCLK (FPGA_I2C_SCLK),
		.FPGA_I2C_SDAT (FPGA_I2C_SDAT),
		.CLOCK_50      (CLOCK_50),
		.reset		   (~KEY[0])
	);

	// Clock generator for DAC
	clkGen50MHz_781kHz CG1 (
		.clk50MHz (CLOCK_50),
		.rst        (~KEY[0]),
		.clk781kHz  (clk781kHz)
	);

	DAC_controller DC1 (
		.clk          (CLOCK_50),
		.rst          (~KEY[0]),

		// I2C lines
		.SCL_i        (SCL_in),
		.SCL_o        (SCL_o),
		.SCL_t        (SCL_t),
		.SDA_i        (SDA_in),
		.SDA_o        (SDA_o),
		.SDA_t        (SDA_t),

		// DAC signals
		.data_i       (DAC_signal),
		.data_reg     (),
		.enable       (audio_out_allowed),
		.mode_i       (2'b00),
		.mode_reg     (),

		.writeToMem   (1'b0),
		.readFromMem  (1'b0),

		// 400kHz
		.i2cSpeed     (2'b01),
		.A0           (DAC_I2C_A0),

		// Clocks
		.clk_2x100kHz (),
		.clk_2x400kHz (clk_2x400kHz),
		.clk_2x1_7MHz (),
		.clk_2x3_4MHz ()
	);
endmodule