module move_input (
    input wire           Clock,
    input wire           nReset,
    input wire           Enable, 
    input wire     [7:0] data, 
    input wire           data_en,

    output reg [3:0] Direction,  // 1-cycle movement command
    output reg       Command     // 1-cycle ENTER pulse
);  

    // Internal registers
    reg break_code;

    // Key codes
    localparam UP    = 8'h1D,
               DOWN  = 8'h1B,
               LEFT  = 8'h1C,
               RIGHT = 8'h23,
               SPACE = 8'h5A,
               RELEASE = 8'hF0;

    // Input decoder
    always @(posedge Clock, negedge nReset) 
    begin
        if (!nReset)
            break_code <= 0;
        else if (data_en) 
        begin
            if (data == RELEASE)
                break_code <= 1;
            else
                break_code <= 0;  
        end
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
        else if (data_en && (data != RELEASE) && !break_code)
        begin
            case (data)
                UP:       Direction <= 4'b0001;  // up
                DOWN:     Direction <= 4'b0010;  // down
                LEFT:     Direction <= 4'b0100;  // left
                RIGHT:    Direction <= 4'b1000;  // right
                SPACE:    Command   <= 1'b1;     // enter pulse
                default:
                begin  
                    Direction <= 4'd0;
                    Command   <= 1'b0;
                end
            endcase
        end
        else if (break_code)
        begin
            Direction <= 4'd0;
            Command   <= 1'b0;
        end
    end

endmodule
