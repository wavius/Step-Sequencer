`timescale 1ns / 1ps

module testbench ( );
    parameter CLOCK_PERIOD = 10;

    reg [9:0] SW;
    reg [1:0] KEY;
    reg CLOCK_50;
	 // Bidirectional I2C lines
    wire FPGA_I2C_SCLK;
    wire FPGA_I2C_SDAT;
    pullup(FPGA_I2C_SCLK);
    pullup(FPGA_I2C_SDAT);

    // Unused audio lines
    wire AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK;
    wire AUD_XCK, AUD_DACDAT;

    initial begin
    CLOCK_50 <= 1'b0;
    end // initial

    always @ (*)
    begin : Clock_Generator
    #((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
    end
	
    initial begin
    KEY[0] <= 1'b0;
    #10 KEY[0] <= 1'b1;
    end // initial

    initial begin
    SW <= 10'b0010000011; 
    KEY[1] = 1; // not pressed;
    #20 KEY[1] <= 0; // pressed
    #10 KEY[1] <= 1; // not pressed
    end // initial

    initial begin
    $display("Simulation start");
    #10;
    $display("Start asserted");
    KEY[0] = 0; #20 KEY[0] = 1; // manual reset pulse
    end

    audio_interface U1 (
	// Inputs
	CLOCK_50,
	KEY,
	SW,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK
    ); 

endmodule