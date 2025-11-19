module vga_display (
    input         CLOCK_50,
    input         nReset,
    input         state,
    input         draw_enable,

    input [9:0]   X,
    input [8:0]   Y,

    output [9:0]  VGA_X,
    output [8:0]  VGA_Y, 
    output [23:0] VGA_COLOR, 
    output        plot
);
    // Internal registers
    reg [9:0]  current_x;
    reg [8:0]  current_y;
    reg        write;

    reg [1:0]  current_state, next_state;
    reg        drawing;
    reg [15:0] count;

    // Internal wires
    reg [8:0] color;        // 9 bit color
    wire       VGA_SYNC; 

    // Sequential logic
    always@(posedge draw_enable)
    begin
        color <= state ? 9'H1FF : 9'd7; // White : Blue
    end

    // State parameters
    localparam IDLE = 2'b01, DRAW = 2'b10;
        
    // State logic
    always@(*)
    begin
       if (!VGA_SYNC)
        begin
            next_state = IDLE;
        end
        else
        case (current_state)
            IDLE:
            begin
                next_state = draw_enable ? DRAW : IDLE;
            end
            DRAW:
            begin
                next_state = drawing ? DRAW : IDLE;
            end
        endcase
    end

    always@(posedge CLOCK_50, negedge nReset)
    begin
        if (!nReset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Draw logic
    always@(posedge CLOCK_50, negedge nReset)
    begin
        if (!nReset)
        begin
            drawing   <= 0;
            write     <= 0;
            current_x <= X;
            current_y <= Y;
        end
        else
        begin
            case(current_state)
                IDLE:
                begin
                    drawing   <= 1;
                    write     <= 0;
                    current_x <= X;
                    current_y <= Y;
                end
                DRAW:
                begin
                    write   <= 1;
                    if (current_x < X + 30) 
                    begin
                        current_x <= current_x + 1;
                    end 
                    else 
                    begin
                        current_x <= X;
                        if (current_y > Y - 30) 
                        begin
                            current_y <= current_y - 1;
                        end 
                        else 
                        begin
                            write   <= 0;
                            drawing <= 0;
                        end
                    end
                end
            endcase
        end
    end

    // Internal modules
    `define VGA_MEMORY              // include a memory module in the VGA adapter
    vga_adapter VGA (
        .resetn(nReset),
        .clock(CLOCK_50),
        .color(color),              // used to draw pixels on top of background
        .x(X),                      // used to draw pixels on top of background
        .y(Y),                      // used to draw pixels on top of background
        .write(write),              // used to draw pixels on top of background
        .VGA_X(VGA_X),              // the output VGA x coordinate (column)
        .VGA_Y(VGA_Y),              // the output VGA y coordinate (row)
        .VGA_COLOR(VGA_COLOR),      // the output VGA color
        .VGA_SYNC(VGA_SYNC),        // indicates when background MIF has been drawn
        .plot(plot));               // the output VGA plot signal
		defparam VGA.RESOLUTION = "640x480";
        // choose background image according to resolution and color depth
		defparam VGA.BACKGROUND_IMAGE = "./MIF/grid.mif";
		defparam VGA.COLOR_DEPTH = 9;

endmodule