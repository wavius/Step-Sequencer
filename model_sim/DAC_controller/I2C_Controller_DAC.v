// Adapted from I2C_Controller.v

module I2C_Controller_DAC (
	CLOCK,            // Controller Work Clock
	DAC_I2C_SCLK,     // I2C CLOCK
 	DAC_I2C_SDAT,     // I2C DATA
	I2C_DATA,         // DATA:[SLAVE_ADDR, CMD, DATA_MSB, DATA_LSB]
	GO,               // GO transfer
	END,              // END transfer 
	ACK,              // ACK
	RESET,
	// TEST
	SD_COUNTER,
	SDO
);
	input  CLOCK;
	input  [31:0] I2C_DATA;	
	input  GO;
	input  RESET;	
 	inout  DAC_I2C_SDAT;	
	output DAC_I2C_SCLK;
	output END;	
	output ACK;

	// TEST
	output [7:0] SD_COUNTER;
	output SDO;

	reg SDO;
	reg SCLK;
	reg END;
	reg [31:0] SD;
	reg [7:0] SD_COUNTER;

	wire DAC_I2C_SCLK = SCLK | (((SD_COUNTER >= 4) & (SD_COUNTER <= 39)) ? ~CLOCK : 0);
	wire DAC_I2C_SDAT = SDO ? 1'bz : 0;

	reg ACK1, ACK2, ACK3, ACK4;
	wire ACK = ACK1 | ACK2 | ACK3 | ACK4;

	//-- I2C COUNTER
	always @(negedge RESET, posedge CLOCK) begin
		if (!RESET)
			SD_COUNTER = 7'b1111111;
		else begin
			if (GO == 0)
				SD_COUNTER = 0;
			else if (SD_COUNTER < 7'b1111111)
				SD_COUNTER = SD_COUNTER + 1;	
		end
	end
	//----

	always @(negedge RESET, posedge CLOCK) begin
		if (!RESET) 
		begin
			SCLK = 1;
			SDO = 1;
			ACK1 = 0;
			ACK2 = 0;
			ACK3 = 0;
			ACK4 = 0;
			END = 1;
		end 
		else
		case (SD_COUNTER)
			7'd0  : begin ACK1 = 0; ACK2 = 0; ACK3 = 0; ACK4 = 0; END = 0; SDO = 1; SCLK = 1; end
			// start
			7'd1  : begin SD = I2C_DATA; SDO = 0; end
			7'd2  : SCLK = 0;
			// SLAVE ADDR
			7'd3  : SDO = SD[31];
			7'd4  : SDO = SD[30];
			7'd5  : SDO = SD[29];
			7'd6  : SDO = SD[28];
			7'd7  : SDO = SD[27];
			7'd8  : SDO = SD[26];
			7'd9  : SDO = SD[25];
			7'd10 : SDO = SD[24];	
			7'd11 : SDO = 1'b1; // ACK

			// CMD
			7'd12 : begin SDO = SD[23]; ACK1 = DAC_I2C_SDAT; end
			7'd13 : SDO = SD[22];
			7'd14 : SDO = SD[21];
			7'd15 : SDO = SD[20];
			7'd16 : SDO = SD[19];
			7'd17 : SDO = SD[18];
			7'd18 : SDO = SD[17];
			7'd19 : SDO = SD[16];
			7'd20 : SDO = 1'b1; // ACK

			// MSB
			7'd21 : begin SDO = SD[15]; ACK2 = DAC_I2C_SDAT; end
			7'd22 : SDO = SD[14];
			7'd23 : SDO = SD[13];
			7'd24 : SDO = SD[12];
			7'd25 : SDO = SD[11];
			7'd26 : SDO = SD[10];
			7'd27 : SDO = SD[9];
			7'd28 : SDO = SD[8];
			7'd29 : SDO = 1'b1; // ACK

			// LSB
			7'd30 : begin SDO = SD[7]; ACK3 = DAC_I2C_SDAT; end
			7'd31 : SDO = SD[6];
			7'd32 : SDO = SD[5];
			7'd33 : SDO = SD[4];
			7'd34 : SDO = SD[3];
			7'd35 : SDO = SD[2];
			7'd36 : SDO = SD[1];
			7'd37 : SDO = SD[0];
			7'd38 : SDO = 1'b1; // ACK
			
			// stop
			7'd39 : begin SDO = 1'b0; SCLK = 1'b0; ACK4 = DAC_I2C_SDAT; end	
			7'd40 : SCLK = 1'b1; 
			7'd41 : begin SDO = 1'b1; END = 1; end 
		endcase
	end

endmodule