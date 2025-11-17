module move_input (
    input            Clock,
    input            nReset,
    input            Enable, 
    input      [7:0] data, 
    input            data_en,

    output reg [3:0] Direction,  // movement command
    output reg       Command     // pulse
);  

    // Internal registers
    reg [1:0] current_state, next_state;
    reg break_code;

    // States
    localparam IDLE = 2'b01,
               MOVE = 2'b10;

    // Key codes
    localparam UP    = 8'h1D,
               DOWN  = 8'h1B,
               LEFT  = 8'h1C,
               RIGHT = 8'h23,
               ENTER = 8'h5A,
               RELEASE = 8'hF0;

    // Input decoder
    always @(posedge Clock, negedge nReset) begin
        if (!nReset)
            break_code <= 0;
        else if (data_en) begin
            if (data == RELEASE)
                break_code <= 1;
            else if (break_code)
                break_code <= 0;
            else
                break_code <= 0;  
        end
    end

    // State logic
    always @(*) 
    begin
        if (!Enable)
            next_state = IDLE;
        else if (!data_en)
            next_state = current_state;
        else if (data_en && !break_code) 
            next_state = MOVE;
    end

    // State register
    always @(posedge Clock, negedge nReset)
    begin
        if (!nReset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Output logic
    always @(posedge Clock, negedge nReset)
    begin
        if (!nReset) 
        begin
            Direction <= 4'd0;
            Command   <= 1'b0;
        end
        else if (!Enable)
        begin
            Direction <= 4'd0;
            Command   <= 1'b0;
        end
        else 
        begin
            // clear pulses each cycle
            Direction <= 4'd0;
            Command   <= 1'b0;

            if (data_en && (data != RELEASE) && !break_code)
            begin
                case (data)
                    UP:       Direction <= 4'b0001;  // up
                    DOWN:     Direction <= 4'b0010;  // down
                    LEFT:     Direction <= 4'b0100;  // left
                    RIGHT:    Direction <= 4'b1000;  // right
                    ENTER:    Command   <= 1'b1;     // enter pulse
                endcase
            end
        end
    end

endmodule
