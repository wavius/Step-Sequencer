module loop_fsm (
    input            Clock,
    input            nReset,
    input      [7:0] data, 
    input            data_en,

    output reg       set, 
    output reg [6:0] Loops, // 0 - 99
    output     [6:0] HEX0,
    output     [6:0] HEX1
);

    // States
    localparam IDLE    = 4'b0001,
               INPUT1  = 4'b0010,
               INPUT2  = 4'b0100,
               INPUT3  = 4'b1000;

    // Key codes
    localparam KEY_1 = 8'h16, KEY_2 = 8'h1E, KEY_3 = 8'h26, KEY_4 = 8'h25,
               KEY_5 = 8'h2E, KEY_6 = 8'h36, KEY_7 = 8'h3D, KEY_8 = 8'h3E,
               KEY_9 = 8'h46, KEY_0 = 8'h45,
               ENTER = 8'h5A, BACKSPACE = 8'h66,
               RELEASE = 8'hF0;

    reg [3:0] current_state, next_state;

    reg [3:0] num1; // ones  
    reg [3:0] num2; // tens

    function digit;
        input [7:0] s;
        begin
            case (s)
                KEY_0,KEY_1,KEY_2,KEY_3,KEY_4,
                KEY_5,KEY_6,KEY_7,KEY_8,KEY_9: digit = 1;
                default:                       digit = 0;
            endcase
        end
    endfunction

    // state logic
    always @(*) 
    begin
        if (!data_en)
            next_state = current_state;
        else if (data == RELEASE)
            next_state = current_state;
        else 
        begin
            case (current_state)
                IDLE:
                    next_state = digit(data) ? INPUT1 : IDLE;

                INPUT1:
                    next_state = digit(data) ? INPUT2 :
                                  (data == BACKSPACE) ? IDLE :
                                  INPUT1;

                INPUT2:
                    next_state = digit(data) ? INPUT3 :
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
    always @(posedge Clock or negedge nReset) 
    begin
        if (!nReset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Input logic
    always @(posedge Clock or negedge nReset) 
    begin
        if (!nReset) 
        begin
            num1  <= 0;
            num2  <= 0;
            Loops <= 1;
            set   <= 1;  
        end
        else if (data_en && (data != RELEASE)) 
        begin
            case (current_state)
                IDLE: 
                begin
                    if (digit(data)) 
                    begin
                        set  <= 0;   
                        num1 <= isDigit(data);
                        num2 <= 0;
                    end
                end

                INPUT1: 
                begin
                    if (digit(data)) 
                    begin
                        num2 <= num1;
                        num1 <= isDigit(data);
                    end 
                    else if (data == BACKSPACE) 
                    begin
                        num1 <= 0;
                        num2 <= 0;
                    end 
                    else if (data == ENTER) 
                    begin
                        Loops <= num2*10 + num1;
                        set   <= 1;
                    end
                end

                INPUT2: 
                begin
                    if (digit(data)) 
                    begin
                        num2 <= num1;
                        num1 <= isDigit(data);
                    end 
                    else if (data == BACKSPACE) 
                    begin
                        num2 <= 0;
                    end 
                    else if (data == ENTER) 
                    begin
                        Loops <= num2*10 + num1;
                        set   <= 1;
                    end
                end

                INPUT3: 
                begin
                    if (data == BACKSPACE) 
                    begin
                        num1 <= num2;
                        num2 <= 0;
                    end 
                    else if (data == ENTER) 
                    begin
                        Loops <= num2*10 + num1;
                        set   <= 1;
                    end
                end

            endcase
        end
    end

    function [3:0] isDigit;
        input [7:0] k;
        begin
            case (k)
                KEY_0: isDigit = 0;
                KEY_1: isDigit = 1;
                KEY_2: isDigit = 2;
                KEY_3: isDigit = 3;
                KEY_4: isDigit = 4;
                KEY_5: isDigit = 5;
                KEY_6: isDigit = 6;
                KEY_7: isDigit = 7;
                KEY_8: isDigit = 8;
                KEY_9: isDigit = 9;
                default: isDigit = 0;
            endcase
        end
    endfunction

    wire [6:0] live_loops = (num2 * 10) + num1;
    sevenseg S0 (live_loops % 10, HEX0);
    sevenseg S1 (live_loops / 10, HEX1);

endmodule