module loop_counter (
    input wire 	 	 Clock,
    input wire 		 nReset,
    input wire 		 nStart,  
    input wire 		 Step,    
    input wire [6:0] Loops,
    output reg       Play
);
    // Step synchronizer
    reg t0, t1;
    wire step_rise;

    always @(posedge Clock, negedge nReset) begin
        if (!nReset) begin
            t0 <= 0;
            t1 <= 0;
        end else begin
            t0 <= Step;
            t1 <= t0;
        end
    end

    assign step_rise = (t1 == 0 && t0 == 1);

    // Loop counter
    reg [11:0] Q;
    reg [11:0] total_steps;
    reg        done;
    reg [6:0]  Loops_latched;

    always @(posedge Clock, negedge nReset) begin
        if (!nReset) 
		begin
            Play          <= 0;
            done          <= 1;
            Q             <= 0;
            total_steps   <= 0;
            Loops_latched <= 0;
        end
        else if (!nStart) 
		begin
            Loops_latched <= Loops;
            total_steps   <= Loops * 7'd12 + 7'd1;
            Q             <= 0;
            done          <= 0;
            Play          <= 1;
        end
        else if (!done && step_rise) 
		begin
            if (Loops_latched == 0) 
			begin
                Play <= 1;   // infinite loop
            end 
			else if (Q == total_steps - 1) 
			begin
                Play <= 0;
                done <= 1;
            end 
			else 
			begin
                Q    <= Q + 1;
                Play <= 1;
            end
        end
    end

endmodule