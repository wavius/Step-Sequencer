module bpm_fsm (
    input            Clock,
    input            nReset,
    input            Enable,  
    input      [7:0] data, 
    input            data_en,

    output reg [9:0] BPM,    // 0 - 999
    output     [6:0] HEX3,
    output     [6:0] HEX4,
    output     [6:0] HEX5
); 
    // Internal registers
    reg [3:0] current_state, next_state;
    reg [3:0] num1; // ones
    reg [3:0] num2; // tens
    reg [3:0] num3; // hundreds
    reg break_code;

    // States
    localparam IDLE    = 4'b00001,
               INPUT1  = 4'b00010,
               INPUT2  = 4'b00100,
               INPUT3  = 4'b01000;

    // Key codes
    localparam KEY_1 = 8'h16, KEY_2 = 8'h1E, KEY_3 = 8'h26, KEY_4 = 8'h25,
               KEY_5 = 8'h2E, KEY_6 = 8'h36, KEY_7 = 8'h3D, KEY_8 = 8'h3E,
               KEY_9 = 8'h46, KEY_0 = 8'h45,
               ENTER = 8'h24, BACKSPACE = 8'h2D,
               RELEASE = 8'hF0;

    // Input decoder
    always @(posedge Clock or negedge nReset) begin
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
                    next_state = isDigit(data) ? INPUT2 :
                                  (data == BACKSPACE) ? IDLE :
                                  (data == ENTER)     ? IDLE :
                                  INPUT1;

                INPUT2:
                    next_state = isDigit(data) ? INPUT3 :
                                  (data == BACKSPACE) ? INPUT1 :
                                  (data == ENTER)     ? IDLE :
                                  INPUT2;

                INPUT3:
                    next_state = (data == BACKSPACE) ? INPUT2 :
                                 (data == ENTER)     ? IDLE :
                                 INPUT3;
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
            num1 <= 0;
            num2 <= 0;
            num3 <= 0;
            BPM  <= 0;
        end
        else if (!Enable)
        begin
            num1 <= num1;
            num2 <= num2;
            num3 <= num3;
            BPM  <= BPM;
        end
        else if (data_en && (data != RELEASE) && !break_code) 
        begin
            case (current_state)
                IDLE: 
                begin
                    if (isDigit(data))
                    begin
                        num1 <= decodeDigit(data);
                        num2 <= 0;
                        num3 <= 0;
                    end
                    else if (data == ENTER)
                    begin
                        BPM <= num3*100 + num2*10 + num1;
                    end
                end

                INPUT1: 
                begin
                    if (isDigit(data))
                    begin
                        num1 <= decodeDigit(data);
                        num2 <= num1;
                        num3 <= 0;
                    end 
                    else if (data == BACKSPACE)
                    begin
                        num1 <= 0;
                        num2 <= 0;
                        num3 <= 0;
                    end
                    else if (data == ENTER)
                    begin
                        BPM <= num3*100 + num2*10 + num1;
                    end
                end

                INPUT2:
                begin
                    if (isDigit(data))
                    begin
                        num1 <= decodeDigit(data);
                        num2 <= num1;
                        num3 <= num2;
                    end
                    else if (data == BACKSPACE)
                    begin
                        num1 <= num2;
                        num2 <= 0;
                        num3 <= 0;
                    end
                    else if (data == ENTER)
                    begin
                        BPM <= num3*100 + num2*10 + num1;
                    end
                end

                INPUT3:
                begin
                    if (data == BACKSPACE)
                    begin
                        num1 <= num2;
                        num2 <= num3;
                        num3 <= 0;
                    end
                    else if (data == ENTER)
                    begin
                        BPM <= num3*100 + num2*10 + num1;
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
    wire [9:0] live_bpm = (num3 * 100) + (num2 * 10) + num1;
    sevenseg H3 (live_bpm / 100, HEX5);
    sevenseg H4 ((live_bpm / 10) % 10, HEX4);
    sevenseg H5 (live_bpm % 10, HEX3);

endmodule