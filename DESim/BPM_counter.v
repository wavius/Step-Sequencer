module BPM_counter (Clock, nReset, nStart, BPM, Step);
	input Clock, nReset, nStart;
    input [9:0] BPM; // Max 511 BPM [8:0]
	output reg Step;

   reg [31:0] Q;
   reg [63:0] target; 
   wire [63:0] BPMs = 64'd50_000_000;
   always@(posedge Clock)
   begin
		// target = freq_clock * 60/BPM
      if (!nReset)
      begin
        Step   <= 0;
        Q      <= 0;
      end
      else if (!nStart)
      begin
          target <= (64'd50_000_000 * 60) / BPMs;
          Step   <= 1;
          Q      <= 0;
      end
      else if (!BPM)
      begin
          Step <= 0;
          Q    <= 0;
      end
      else if (Q == target)
      begin
          Q    <= 0;
          Step <= 1;
      end       
      else
      begin
          Q    <= Q + 1;
          Step <= 0;
      end 
    end
endmodule