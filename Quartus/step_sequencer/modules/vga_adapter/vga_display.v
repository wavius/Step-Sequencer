module vga_display (
    input  wire        CLOCK_50,
    input  wire        nReset,
    input  wire        state,        // 1 = white, 0 = blue
    input  wire        draw_enable,  // 1-cycle start pulse

    input  wire [9:0]  X,            // center or reference point
    input  wire [8:0]  Y,
    input  wire [9:0]  OLD_X,
    input  wire [8:0]  OLD_Y,

    output reg         drawing,      // 1 while drawing 30x30 block

    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire       VGA_BLANK_N,
    output wire       VGA_SYNC_N,
    output wire       VGA_CLK   
);

    // States
    localparam RESET_WAIT        = 6'b000001,
               RESET_DRAW        = 6'b000010,
               IDLE              = 6'b000100,
               DRAW_CURSOR_RESET = 6'b001000,
               DRAW_CURSOR       = 6'b010000,
               DRAW_BOX          = 6'b100000;

    localparam WHITE = 9'h1FF,
               BLUE  = 9'd7,
               RED   = 9'h1C0;

    localparam X0 = 10'd214;
    localparam Y0 = 9'd32;

    // Internal wires
    wire reset_grid; 

    // Internal registers
    reg [5:0] current_state, next_state;
    reg [5:0] dx, dy;         
    reg [3:0] grid_x, grid_y;  
    reg [9:0] current_x;
    reg [8:0] current_y;
    reg [8:0] color;
    reg       write;

    // Combinational
    assign reset_grid = (grid_x == 11 && grid_y == 11 && dx == 30 && dy == 30);

    always @(*) begin
        case (current_state)
            RESET_WAIT:        next_state = VGA_SYNC_N    ? RESET_DRAW        : RESET_WAIT;
            RESET_DRAW:        next_state = reset_grid  ? DRAW_CURSOR_RESET : RESET_DRAW;
            DRAW_CURSOR_RESET: next_state = (!drawing)  ? IDLE              : DRAW_CURSOR_RESET;
            DRAW_CURSOR:       next_state = (!drawing)  ? DRAW_BOX          : DRAW_CURSOR;
            DRAW_BOX:          next_state = (!drawing)  ? IDLE              : DRAW_BOX;
            IDLE:              next_state = draw_enable ? DRAW_CURSOR       : IDLE;
            default:           next_state =               RESET_WAIT;
        endcase
    end

    // Sequential
    always@(posedge CLOCK_50, negedge nReset)
    begin
        if (!nReset)
        begin
            current_state <= RESET_WAIT;
        end
        else
        begin
            current_state <= next_state;
        end
    end

    // Draw logic
    always @(posedge CLOCK_50, negedge nReset) begin
        if (!nReset) 
        begin
            drawing <= 0;
            write   <= 0;
            
            dx        <= 0; 
            dy        <= 0;
            grid_x    <= 0; 
            grid_y    <= 0;
            current_x <= X0;
            current_y <= Y0;
            
            color <= WHITE;
        end 
        else 
        begin
            case (current_state)
                RESET_WAIT: 
                begin
                    write   <= 0;
                    drawing <= 0;
                    color   <= WHITE;

                    dx     <= 0; 
                    dy     <= 0;
                    grid_x <= 0; 
                    grid_y <= 0;
                end

                RESET_DRAW: 
                begin
                    drawing <= 1;
                    write   <= 1;
                    color   <= WHITE;

                    current_x <= X0 + grid_x * 33 + dx;
                    current_y <= Y0 + grid_y * 33 + dy;

                    if (dx < 30)
                        dx <= dx + 1;
                    else 
                    begin
                        dx <= 0;
                        if (dy < 30)
                            dy <= dy + 1;
                        else 
                        begin
                            dy <= 0;
                            if (grid_x < 11)
                                grid_x <= grid_x + 1;
                            else 
                            begin
                                grid_x <= 0;
                                if (grid_y < 11)
                                    grid_y <= grid_y + 1;
                            end
                        end
                    end
                end

                DRAW_CURSOR_RESET:
                begin
                    drawing <= 1;
                    write   <= 1;
                    color   <= RED;

                    current_x <= X + dx;
                    current_y <= Y + dy;

                    if (dx < 30)
                        dx <= dx + 1;
                    else 
                    begin
                        dx <= 0;
                        if (dy < 30)
                            dy <= dy + 1;
                        else 
                        begin
                            dy <= 0;
                            drawing <= 0;
                        end
                    end
                end

                DRAW_CURSOR: 
                begin
                    drawing <= 1;
                    write   <= 1;
                    color   <= RED;

                    current_x <= X + dx;
                    current_y <= Y + dy;

                    if (dx < 30)
                        dx <= dx + 1;
                    else 
                    begin
                        dx <= 0;
                        if (dy < 30)
                            dy <= dy + 1;
                        else 
                        begin
                            dy <= 0;
                            drawing <= 0;
                        end
                    end
                end

                DRAW_BOX:
                begin
                    drawing <= 1;
                    write   <= 1;
                    color   <= state ? BLUE : WHITE;

                    current_x <= OLD_X + dx;
                    current_y <= OLD_Y + dy;

                    if (dx < 30)
                        dx <= dx + 1;
                    else 
                    begin
                        dx <= 0;
                        if (dy < 30)
                            dy <= dy + 1;
                        else 
                        begin
                            dy <= 0;
                            drawing <= 0;
                        end
                    end
                end

                IDLE: 
                begin
                    dx <= 0; 
                    dy <= 0;
                    if (draw_enable)
                        drawing <= 1;
                    else
                        drawing <= 0;
                end
            endcase
        end
    end

    // VGA adapter
    `define VGA_MEMORY
    vga_adapter VGA (
        .resetn      (nReset),
        .clock       (CLOCK_50),
        .color       (color),
        .x           (current_x),
        .y           (current_y),
        .write       (write),
        .VGA_R       (VGA_R),
        .VGA_G       (VGA_G),
        .VGA_B       (VGA_B),
        .VGA_HS      (VGA_HS),
        .VGA_VS      (VGA_VS),
        .VGA_BLANK_N (VGA_BLANK_N),
        .VGA_SYNC_N  (VGA_SYNC_N),
        .VGA_CLK     (VGA_CLK)
    );
    defparam VGA.RESOLUTION       = "640x480";
    defparam VGA.BACKGROUND_IMAGE = "./MIF/grid.mif";
    defparam VGA.COLOR_DEPTH      = 9;

endmodule