module display_interface (
    input  wire        CLOCK_50,
    input  wire        nReset,

    input  wire [3:0]  Direction, // Move on grid
    input  wire        Command,   // Toggle grid
    input  wire        play_en,   // Playback enable
    input  wire        bpm_step,  // BPM pulse

    output reg  [11:0] select_note,

    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire       VGA_BLANK_N,
    output wire       VGA_SYNC_N,
    output wire       VGA_CLK    
);
    // Internal parameters
    // Grid
    localparam GRID_SIZE = 12;
    localparam SPACING   = 33;
    localparam X0 = 10'd214;
    localparam Y0 = 9'd32;

    // Movement
    localparam UP    = 4'b0001;
    localparam DOWN  = 4'b0010;
    localparam LEFT  = 4'b0100;
    localparam RIGHT = 4'b1000;

    // Internal registers
    reg grid_state;
    reg draw_enable;

    // Position
    reg [3:0] grid_x;
    reg [3:0] grid_y;

    // Grid
    reg [11:0] cols [11:0];

    // Internal wires
    wire drawing;

    wire [9:0] x_pos = X0 + grid_x * SPACING;
    wire [8:0] y_pos = Y0 + grid_y * SPACING;

    reg [3:0] dir_sync0, dir_sync1;
    reg       cmd_sync0, cmd_sync1;

    // Sync inputs
    always @(posedge CLOCK_50, negedge nReset) 
    begin
        if (!nReset) 
        begin
            dir_sync0 <= 0;
            dir_sync1 <= 0;

            cmd_sync0 <= 0;
            cmd_sync1 <= 0;
        end 
        else 
        begin
            dir_sync0 <= Direction;
            dir_sync1 <= dir_sync0;

            cmd_sync0 <= Command;
            cmd_sync1 <= cmd_sync0;
        end
    end

    wire [3:0] DIR = dir_sync1;
    wire       CMD = cmd_sync1;

    // Edge detectors
    reg [3:0] dir_prev;
    reg       cmd_prev;

    wire dir_pulse = (DIR != 0) && (dir_prev != DIR);
    wire cmd_pulse = CMD && !cmd_prev;

    always @(posedge CLOCK_50, negedge nReset) 
    begin
        if (!nReset) 
        begin
            dir_prev <= 0;
            cmd_prev <= 0;
        end 
        else 
        begin
            dir_prev <= DIR;
            cmd_prev <= CMD;
        end
    end

    // Movement logic
    always @(posedge CLOCK_50, negedge nReset) 
    begin
        if (!nReset) 
        begin
            grid_x <= 0;
            grid_y <= 0;
        end
        else if (dir_pulse && !drawing) 
        begin
            case (DIR)
                UP:    if (grid_y > 0)              grid_y <= grid_y - 1;
                DOWN:  if (grid_y < GRID_SIZE - 1)  grid_y <= grid_y + 1;
                LEFT:  if (grid_x > 0)              grid_x <= grid_x - 1;
                RIGHT: if (grid_x < GRID_SIZE - 1)  grid_x <= grid_x + 1;
            endcase
        end
    end

    // Drawing logic
    integer i;
    always @(posedge CLOCK_50, negedge nReset) begin
        if (!nReset) 
        begin
            draw_enable <= 0;
            grid_state  <= 0;
            
            for (i = 0; i < 12; i = i + 1)
            begin
                cols[i] <= 0;
            end
        end 
        else if (cmd_pulse) 
        begin 
            cols[grid_y][grid_x] <= ~cols[grid_y][grid_x];

            grid_state <= cols[grid_y][grid_x];

            // begin draw
            draw_enable <= 1;
        end 
        else if (!drawing) 
        begin
            draw_enable <= 0;
        end
    end

    // Play logic
    reg [3:0] count;
    always@(posedge bpm_step, negedge nReset)
    begin
        if (!nReset)
        begin
            count        <= 0;
            select_note  <= 0;
        end
        else if (play_en)
        begin
            select_note <= {
                cols[11][count], // B
                cols[10][count], // A#
                cols[9][count],  // A
                cols[8][count],  // G#
                cols[7][count],  // G
                cols[6][count],  // F#
                cols[5][count],  // F 
                cols[4][count],  // E
                cols[3][count],  // D#
                cols[2][count],  // D
                cols[1][count],  // C#
                cols[0][count]   // C
            };
            if (count == 4'd11)
                count    <= 0;
            else
                count    <= count + 1;
        end
        else
        begin
            count        <= 0;
            select_note  <= 0;
        end
    end

    // Internal modules
    vga_display V1 (
        .CLOCK_50    (CLOCK_50),
        .nReset      (nReset),
        .state       (grid_state),
        .draw_enable (draw_enable),
        .X           (x_pos),
        .Y           (y_pos),
        .drawing     (drawing),
        .VGA_R       (VGA_R),
        .VGA_G       (VGA_G),
        .VGA_B       (VGA_B),
        .VGA_HS      (VGA_HS),
        .VGA_VS      (VGA_VS),
        .VGA_BLANK_N (VGA_BLANK_N),
        .VGA_SYNC_N  (VGA_SYNC_N),
        .VGA_CLK     (VGA_CLK)
    );

endmodule