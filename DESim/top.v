`default_nettype none
module top (
    input wire         CLOCK_50,
    input wire [3:0]   KEY,
    inout wire         PS2_CLK,
    inout wire         PS2_DAT,

    output wire [9:0]  LEDR,
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5,

    output wire [9:0]  VGA_X,
    output wire [8:0]  VGA_Y,
    output wire [23:0] VGA_COLOR,
    output wire        plot
);
    //---------------------------------------------------------
    // DESim Reset & PS2 clock history
    //---------------------------------------------------------
    wire Resetn = KEY[0];
    reg  prev_ps2_clk;

    always @(posedge CLOCK_50)
        prev_ps2_clk <= PS2_CLK;

    wire negedge_ps2_clk = prev_ps2_clk & ~PS2_CLK;

    //---------------------------------------------------------
    // 33-bit PS/2 serial shifter
    //---------------------------------------------------------
    reg [32:0] Serial;

    always @(posedge CLOCK_50) begin
        if (!Resetn)
            Serial <= 33'b0;
        else if (negedge_ps2_clk) begin
            Serial[31:0] <= Serial[32:1];
            Serial[32]   <= PS2_DAT;
        end
    end

    //---------------------------------------------------------
    // Bit counter → one full scan code ready every 11 bits
    //---------------------------------------------------------
    reg [3:0] bit_count;
    reg       data_ready;

    always @(posedge CLOCK_50 or negedge Resetn) begin
        if (!Resetn) begin
            bit_count  <= 0;
            data_ready <= 0;
        end
        else if (negedge_ps2_clk) begin
            if (bit_count == 10) begin
                bit_count  <= 0;
                data_ready <= 1;
            end else begin
                bit_count  <= bit_count + 1;
                data_ready <= 0;
            end
        end
        else begin
            data_ready <= 0;
        end
    end

    //---------------------------------------------------------
    // Stable scan code
    //---------------------------------------------------------
    reg [8:0] scan_code;

    always @(posedge CLOCK_50) begin
        if (data_ready)
            scan_code <= Serial[30:23];
    end

    //---------------------------------------------------------
    // Instantiate your NEW unified input interface
    //---------------------------------------------------------
    step_sequencer S1 (
        // Inputs
        .CLOCK_50    (CLOCK_50),
        .KEY         (KEY[2:0]),

        // Outputs
        .HEX0        (HEX0),
        .HEX1        (HEX1),
        .HEX2        (HEX2),
        .HEX3        (HEX3),
        .HEX4        (HEX4),
        .HEX5        (HEX5),
        .LEDR        (LEDR),
        
        .sim_data    (scan_code),
        .sim_data_en (data_ready),

        .VGA_X       (VGA_X),
        .VGA_Y       (VGA_Y),
        .VGA_COLOR   (VGA_COLOR),
        .plot        (plot)
    );

endmodule