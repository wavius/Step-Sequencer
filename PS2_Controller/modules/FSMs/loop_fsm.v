module loop_fsm (
    input            Clock,
    input            nReset,
    input            Enable,
    input      [7:0] data, 
    input            data_en,

    output reg [6:0] Loops, // 0 - 99
    output     [6:0] HEX0,
    output     [6:0] HEX1,
    output     [2:0] LEDR
);  
    // Internal registers
    reg [2:0] current_state, next_state;
    reg [3:0] num1; // ones  
    reg [3:0] num2; // tens
    reg break_code;

    // States
    localparam IDLE    = 3'b0001,
               INPUT1  = 3'b0010,
               INPUT2  = 3'b0100;

    // Key codes
    localparam KEY_1 = 8'h16, KEY_2 = 8'h1E, KEY_3 = 8'h26, KEY_4 = 8'h25,
               KEY_5 = 8'h2E, KEY_6 = 8'h36, KEY_7 = 8'h3D, KEY_8 = 8'h3E,
               KEY_9 = 8'h46, KEY_0 = 8'h45,
               ENTER = 8'h24, BACKSPACE = 8'h2D,
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
        else if (data_en && (data != RELEASE) && !break_code) 
        begin
            case (current_state)
                IDLE:
                    next_state = isDigit(data) ? INPUT1 : IDLE;

                INPUT1:
                    next_state = isDigit(data)       ? INPUT2 :
                                 (data == BACKSPACE) ? IDLE :
                                 (data == ENTER)     ? IDLE :
                                                       INPUT1;

                INPUT2:
                    next_state =  (data == BACKSPACE) ? INPUT1 :
                                  (data == ENTER)     ? IDLE :
                                                        INPUT2;
            endcase
        end
    end

    // State register
    always @(posedge Clock, negedge nReset) 
    begin
        if (!nReset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Input logic
    always @(posedge Clock, negedge nReset) 
    begin
        if (!nReset) 
        begin
            num2  <= 0;
            num1  <= 0;
            Loops <= 0;
        end
        else if (!Enable)
        begin
            num2  <= num2;
            num1  <= num1;
            Loops <= Loops;
        end
        else if (data_en && (data != RELEASE) && !break_code) 
        begin
            case (current_state)
                IDLE: 
                begin
                    if (isDigit(data)) 
                    begin 
                        num2 <= 0;
                        num1 <= decodeDigit(data);
                    end
                    else if (data == ENTER)
                    begin
                        Loops <= (num2 * 10) + num1;
                    end
                end

                INPUT1: 
                begin
                    if (isDigit(data)) 
                    begin
                        num2 <= num1;
                        num1 <= decodeDigit(data);
                    end 
                    else if (data == BACKSPACE) 
                    begin
                        num2 <= 0;
                        num1 <= 0;
                    end 
                    else if (data == ENTER) 
                    begin
                        Loops <= num2*10 + num1;
                    end
                end

                INPUT2: 
                begin
                    if (data == BACKSPACE) 
                    begin
                        num2 <= 0;
                        num1 <= num2;
                    end 
                    else if (data == ENTER) 
                    begin
                        Loops <= num2*10 + num1;
                    end
                end

            endcase
        end
    end

    // Functions
    function [3:0] decodeDigit;
        input [7:0] k;
        begin
            case (k)
                KEY_0: decodeDigit = 0;
                KEY_1: decodeDigit = 1;
                KEY_2: decodeDigit = 2;
                KEY_3: decodeDigit = 3;
                KEY_4: decodeDigit = 4;
                KEY_5: decodeDigit = 5;
                KEY_6: decodeDigit = 6;
                KEY_7: decodeDigit = 7;
                KEY_8: decodeDigit = 8;
                KEY_9: decodeDigit = 9;
                default: decodeDigit = 0;
            endcase
        end
    endfunction

    function isDigit;
        input [7:0] s;
        begin
            case (s)
                KEY_0,KEY_1,KEY_2,KEY_3,KEY_4,
                KEY_5,KEY_6,KEY_7,KEY_8,KEY_9: isDigit = 1;
                default:                       isDigit = 0;
            endcase
        end
    endfunction

    // 7-segment displays
    wire [6:0] live_loops = (num2 * 10) + num1;
    sevenseg S0 (live_loops % 10, HEX0);
    sevenseg S1 (live_loops / 10, HEX1);

endmodule