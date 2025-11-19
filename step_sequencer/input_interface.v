module input_interface (
    // Inputs
    input wire        CLOCK_50,
    input wire        nReset,
    input wire        play_en,

    // Outputs
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5,
    output wire [9:0] LEDR,

    output reg [9:0] BPM,
    output reg [6:0] Loops,
    output reg [3:0] Direction,
    output reg       Command,
    output reg       Start,

    // Bidirectionals
    inout wire       PS2_CLK,
    inout wire       PS2_DAT
);
    // Internal wires
    wire [7:0] data;
    wire       data_en;

    wire [6:0] loops_val;
    
    wire [9:0] bpm_val;

    wire [3:0] dir_val;
    wire       cmd_val;

    // State codes
    localparam IDLE      = 5'b00001,
               MODE_LOOP = 5'b00010,
               MODE_BPM  = 5'b00100,
               MODE_MOVE = 5'b01000,
               MODE_PLAY = 5'b10000;

    // Mode keys
    localparam L       = 8'h4B,
               B       = 8'h32,
               M       = 8'h3A,
               SPACE   = 8'h29,
               ENTER   = 8'h5A,
               RELEASE = 8'hF0;

    // Internal registers
    reg [4:0] current_state, next_state;
    reg       break_code;

    // State logic
    always @(*) 
    begin
        next_state = current_state; 
        case (current_state)
            IDLE:
                if      (data == L)     next_state = MODE_LOOP;
                else if (data == B)     next_state = MODE_BPM;
                else if (data == M)     next_state = MODE_MOVE;
                else if (data == SPACE) next_state = MODE_PLAY;
                else                    next_state = IDLE;

            MODE_LOOP:
                next_state = (data == ENTER) ? IDLE : MODE_LOOP;

            MODE_BPM:
                next_state = (data == ENTER) ? IDLE : MODE_BPM;

            MODE_MOVE:
                next_state = (data == ENTER) ? IDLE : MODE_MOVE;

            MODE_PLAY:
                next_state = (!play_en) ? IDLE : MODE_PLAY;

            default:
                next_state = IDLE;
        endcase
    end

    // State register
    always @(posedge CLOCK_50) begin
        if (!nReset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Output registers
    always @(posedge CLOCK_50) begin
        if (!nReset) 
        begin
            Loops     <= 0;
            BPM       <= 0;
            Direction <= 0;
            Command   <= 0;
            Start     <= 0;
        end
        else if (data_en) 
        begin
            case (current_state)
                MODE_LOOP:
                begin
                    Loops     <= loops_val;
                    Direction <= 0;
                    Command   <= 0;
                    Start     <= 0;
                end

                MODE_BPM:
                begin
                    BPM       <= bpm_val;
                    Direction <= 0;
                    Command   <= 0;
                    Start     <= 0;
                end

                MODE_MOVE:
                begin
                    Direction <= dir_val;
                    Command   <= cmd_val;
                    Start     <= 0;
                end

                MODE_PLAY:
                begin
                    Direction <= 0;
                    Command   <= 0;
                    Start     <= 1;
                end

                default:
                begin
                    Direction <= 0;
                    Command   <= 0;
                    Start     <= 0;
                end
            endcase
        end
    end

    // Internal modules
    PS2_Controller P1 (
        .CLOCK_50   (CLOCK_50),
        .reset      (~nReset),

        .the_command(),
        .send_command(),

        .PS2_CLK    (PS2_CLK),
        .PS2_DAT    (PS2_DAT),

        .command_was_sent(),
        .error_communication_timed_out(),

        .received_data    (data),
        .received_data_en (data_en)
    );

    loop_input LOOP_IN (
        .Clock   (CLOCK_50),
        .nReset  (nReset),
        .Enable  (current_state == MODE_LOOP),
        .data    (data),
        .data_en (data_en),

        .Loops   (loops_val),
        .HEX0    (HEX0),
        .HEX1    (HEX1)
    );

    bpm_input BPM_IN (
        .Clock   (CLOCK_50),
        .nReset  (nReset),
        .Enable  (current_state == MODE_BPM),
        .data    (data),
        .data_en (data_en),

        .BPM     (bpm_val),
        .HEX3    (HEX3),
        .HEX4    (HEX4),
        .HEX5    (HEX5)
    );

    move_input MOVE_IN (
        .Clock     (CLOCK_50),
        .nReset    (nReset),
        .Enable    (current_state == MODE_MOVE),
        .data      (data),
        .data_en   (data_en),

        .Direction (dir_val),
        .Command   (cmd_val)
    );


    // LEDR logic
    reg       led_pulse;
    reg [31:0] c;

    always @(posedge CLOCK_50 or negedge nReset) begin
        if (!nReset) begin
            c         <= 0;
            led_pulse <= 0;
        end
        else if (c == 32'd1_250_000) begin
            led_pulse <= ~led_pulse;
            c         <= 0;
        end
        else begin
            c <= c + 1;
        end
    end

    reg led_loop, led_bpm, led_move;
    assign LEDR[9] = led_bpm;
    assign LEDR[0] = led_loop;
    assign LEDR[5:4] = {led_move, led_move};

    always @(posedge CLOCK_50) begin
        if (!nReset) begin
            led_loop <= 0;
            led_bpm  <= 0;
            led_move <= 0;
        end
        else begin
            case (current_state)
                IDLE:
                begin
                    led_loop <= 1;
                    led_bpm  <= 1;
                    led_move <= 1;
                end
                MODE_LOOP:
                begin
                    led_loop <= led_pulse;
                    led_bpm  <= 1;
                    led_move <= 1;
                end
                MODE_BPM:
                begin
                    led_loop <= 1;
                    led_bpm  <= led_pulse;
                    led_move <= 1;
                end
                MODE_MOVE:
                begin
                    led_loop <= 1;
                    led_bpm  <= 1;
                    led_move <= led_pulse;
                end
            endcase
        end
    end
	
	 assign LEDR[8:6] = 0;
	 assign LEDR[3:1] = 0;
    assign HEX2 = 7'b1111111;
endmodule