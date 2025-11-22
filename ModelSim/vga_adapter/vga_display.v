`default_nettype none
module vga_display (
    input  wire        CLOCK_50,
    input  wire        nReset,
    input  wire        state,        // 1 = white, 0 = blue
    input  wire        draw_enable,  // 1-cycle start pulse

    input  wire [9:0]  X,            // center or reference point
    input  wire [8:0]  Y,

    output reg         drawing,      // 1 while drawing 30x30 block

    output wire [9:0]  VGA_X,
    output wire [8:0]  VGA_Y, 
    output wire [23:0] VGA_COLOR, 
    output wire        plot
);

    // States
    localparam RESET_WAIT  = 4'b0001,
               RESET_DRAW  = 4'b0010,
               IDLE        = 4'b0100,
               DRAW        = 4'b1000;

    localparam WHITE = 9'h1FF,
               BLUE  = 9'd7;

    localparam X0 = 10'd214;
    localparam Y0 = 9'd32;

    // Internal wires
    wire reset_grid; 
    wire VGA_SYNC;

    // Internal registers
    reg [3:0] current_state, next_state;
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
            RESET_WAIT:  next_state = VGA_SYNC    ? RESET_DRAW : RESET_WAIT;
            RESET_DRAW:  next_state = reset_grid  ? IDLE       : RESET_DRAW;
            IDLE:        next_state = draw_enable ? DRAW       : IDLE;
            DRAW:        next_state = (!drawing)  ? IDLE       : DRAW;
            default:     next_state =               RESET_WAIT;
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
                    color   <= BLUE;

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

                IDLE: 
                begin
                    dx <= 0; 
                    dy <= 0;
                    if (draw_enable)
                        drawing <= 1;
                    else
                        drawing <= 0;
                end

                DRAW: 
                begin
                    drawing <= 1;
                    write   <= 1;
                    color   <= state ? WHITE : BLUE;

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
            endcase
        end
    end

    // VGA adapter
    `define VGA_MEMORY
    vga_adapter VGA (
        .resetn    (nReset),
        .clock     (CLOCK_50),
        .color     (color),
        .x         (current_x),
        .y         (current_y),
        .write     (write),

        .VGA_X     (VGA_X),
        .VGA_Y     (VGA_Y),
        .VGA_COLOR (VGA_COLOR),
        .VGA_SYNC  (VGA_SYNC),
        .plot      (plot)
    );
    defparam VGA.RESOLUTION       = "640x480";
    defparam VGA.BACKGROUND_IMAGE = "./MIF/grid.mif";
    defparam VGA.COLOR_DEPTH      = 9;

endmodule