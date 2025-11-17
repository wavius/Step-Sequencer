module input_interface (
    // Inputs
    input            CLOCK_50,
    input      [2:0] KEY,

    // Outputs
    output     [6:0] HEX0,
    output     [6:0] HEX1,
    output     [6:0] HEX2,
    output     [6:0] HEX3,
    output     [6:0] HEX4,
    output     [6:0] HEX5,
    output     [9:0] LEDR,

    output reg [9:0] BPM,
    output reg [6:0] Loops,
    output reg [3:0] Direction,
    output reg       Command,

    // Bidirectionals
    inout            PS2_CLK,
    inout            PS2_DAT
);
    // Internal registers
    reg led_loop, led_bpm, led_move;
    reg [3:0] current_state, next_state;

    reg led_pulse;
    reg [31:0] c;

    // Internal wires
    wire [7:0] data;
    wire       data_en;

    wire [6:0] loops_val;
    wire [9:0] bpm_val;
    wire [3:0] dir_val;
    wire       cmd_val;

    wire nReset = KEY[0];

    // Internal parameters
    localparam IDLE      = 4'b0001,
               MODE_LOOP = 4'b0010,
               MODE_BPM  = 4'b0100,
               MODE_MOVE = 4'b1000;

    localparam L       = 8'h4B,
               B       = 8'h32,
               M       = 8'h3A,
               ENTER   = 8'h5A,
               RELEASE = 8'hF0;

    // Combinational logic
    assign LEDR[9] = led_bpm;
    assign LEDR[0] = led_loop;
    assign LEDR[5] = led_move;

    // State logic
    always @(*) begin
        case (current_state)

            IDLE:
                if      (data == L) next_state = MODE_LOOP;
                else if (data == B) next_state = MODE_BPM;
                else if (data == M) next_state = MODE_MOVE;
                else                next_state = IDLE;

            MODE_LOOP:
                next_state = (data == ENTER) ? IDLE : MODE_LOOP;

            MODE_BPM:
                next_state = (data == ENTER) ? IDLE : MODE_BPM;

            MODE_MOVE:
                next_state = (data == ENTER) ? IDLE : MODE_MOVE;

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

    // Output logic
    always @(posedge CLOCK_50) begin
        if (!nReset) begin
            Loops     <= 0;
            BPM       <= 0;
            Direction <= 0;
            Command   <= 0;

            led_loop <= 0;
            led_bpm  <= 0;
            led_move <= 0;
        end
        else if (data_en) begin
            case (current_state)
                IDLE:
                begin
                    Direction <= 0;
                    Command   <= 0;

                    led_loop <= loop_set;
                    led_bpm  <= bpm_set;
                    led_move <= 0;
                end
                MODE_LOOP:
                begin
                    Loops     <= loops_val;
                    Direction <= 0;
                    Command   <= 0;

                    led_loop <= loop_set;
                    led_bpm  <= led_pulse;
                    led_move <= 0;
                end
                MODE_BPM:
                begin
                    BPM       <= bpm_val;
                    Direction <= 0;
                    Command   <= 0;

                    led_loop <= loop_set;
                    led_bpm  <= led_pulse;
                    led_move <= 0;
                end
                MODE_MOVE:
                begin
                    Direction <= dir_val;
                    Command   <= cmd_val;

                    led_loop <= loop_set;
                    led_bpm  <= bpm_set;
                    led_move <= led_pulse;
                end
            endcase
        end
    end

    // 0.25s counter
    always@(posedge CLOCK_50, negedge nReset)
    begin
        if (!nReset)
        begin
            c         <= 0;
            led_pulse <= 0;
        end
        else if (c == 32'd12_500_000) // 0.25 seconds
        begin
            led_pulse <= ~led_pulse;
            c         <= 0;
        end
        else 
        begin
            c <= c + 1;
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

    loop_fsm LOOP_FSM (
        .Clock   (CLOCK_50),
        .nReset  (nReset),
        .Enable  (current_state == MODE_LOOP), 
        .data    (data),
        .data_en (data_en),

        .Loops   (loops_val),
        .HEX0    (HEX0),
        .HEX1    (HEX1)
    );

    bpm_fsm BPM_FSM (
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

    move_input MOVE_FSM (
        .Clock     (CLOCK_50),
        .nReset    (nReset),
        .Enable    (current_state == MODE_MOVE), 
        .data      (data),
        .data_en   (data_en),

        .Direction (dir_val),
        .Command   (cmd_val)
    );
endmodule