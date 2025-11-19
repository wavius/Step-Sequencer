module display_interface (
    input         CLOCK_50,
    input         nReset, 

    input         play_enable,    // playback enable; move through sequence when high
    input         start_playback, // Start playback signal

    input         bpm_step,    // pulse that toggles with bpm

    input [3:0]   Direction, // Direction to move
    input         Command,   // Draw enable
    
    output reg [11:0] Select,

    output [9:0]  VGA_X,
    output [8:0]  VGA_Y, 
    output [23:0] VGA_COLOR, 
    output        plot
);  
    // Internal registers
    reg [2:0] next_state, current_state;
    reg [9:0] x_pos;
    reg [8:0] y_pos;
    reg [3:0] latched_direction;
    reg       draw_enable;

    reg [11:0] cols [11:0];

    // Internal wires
    wire grid_state;

    // Directions
    localparam UP = 4'b0001, DOWN = 4'b0010, LEFT = 4'b0100, RIGHT = 4'b1000;
    // State codes
    localparam IDLE = 3'b001, MOVE = 3'b010, PLAY = 3'b100;

    // Combinational logic
    assign grid_state = cols[decode_y(y_pos)][decode_x(x_pos)];

    always@(*)
    begin
        case(current_state)
            IDLE:
            begin
                if (start_playback)            next_state = PLAY; 
                else if (Direction != 4'b0000) next_state = MOVE;
                else                           next_state = IDLE;
            end
            MOVE:
            begin
                next_state = IDLE;
            end
            PLAY:
            begin
                if (!play_enable) next_state = IDLE;
                else              next_state = PLAY;
            end
        endcase
    end

    integer i, j;
    reg seq_enable;
    always@(posedge CLOCK_50, negedge nReset)
    begin
        if (!nReset)
        begin
            x_pos             <= 10'd214;
            y_pos             <= 9'd414;
            latched_direction <= 4'b0000;
            draw_enable       <= 0;
            seq_enable        <= 0;
            
            for (i = 0; i < 12; i = i + 1)
                cols[i] <= 12'd0;
        end
        else
        begin
            case(current_state)
                IDLE:
                begin
                    if (Direction != 4'b000)
                    begin
                        latched_direction <= Direction;
                    end
                    else if (Command)
                    begin
                        draw_enable <= 1;
                        cols[decode_y(y_pos)][decode_x(x_pos)] <= ~cols[decode_y(y_pos)][decode_x(x_pos)];
                    end
                    else
                    begin
                        draw_enable <= 0;
                    end
                end
                MOVE:
                begin
                    case(latched_direction)
                        UP:
                        begin
                            if (y_pos > 9'd54 + 9'd32)
                                y_pos <= y_pos - 9'd32;
                        end
                        DOWN:
                        begin
                            if (y_pos < 9'd446 - 9'd32)
                                y_pos <= y_pos + 9'd32;
                        end
                        LEFT:
                        begin
                            if (x_pos > 10'd214 + 10'd32)
                                x_pos <= x_pos - 10'd32;
                        end
                        RIGHT:
                        begin
                            if (x_pos < 10'd596 - 10'd32)
                                x_pos <= x_pos + 10'd32;
                        end
                    endcase
                end
                PLAY:
                begin
                    seq_enable <= play_enable;
                end
            endcase
        end
    end

    always@(posedge CLOCK_50, negedge nReset)
    begin
        if (!nReset)
        begin
            current_state <= IDLE;
        end
        else
        begin
            current_state <= next_state;
        end
    end

    // Sequencer
    reg [4:0] current_column;
    always@(posedge bpm_step, negedge nReset)
    begin
        if (!nReset)
        begin
            Select         <= 0;
            current_column <= 0;
        end
        else if (seq_enable)
        begin
            Select <= cols[current_column];
            if (current_column == 4'd11)
                current_column <= 0;
            else
                current_column <= current_column + 1;
        end
    end

    // Functions
    function [3:0] decode_y;
        input [8:0] y;
    begin
        decode_y = (y - 9'd414) / 9'd32;
        if (decode_y < 0) decode_y = 0;
        if (decode_y > 11) decode_y = 11;
    end
    endfunction

    function [3:0] decode_x;
        input [9:0] x;
    begin
        decode_x = (x - 10'd214) / 10'd32;
        if (decode_x < 0) decode_x = 0;
        if (decode_x > 11) decode_x = 11;
    end
    endfunction

    // Internal modules
    vga_display V1 (
        .CLOCK_50    (CLOCK_50),
        .nReset      (nReset),
        .state       (grid_state),       // Current grid square on or off ?
        .draw_enable (draw_enable), // Set high to draw square

        .X           (x_pos),
        .Y           (y_pos),

        .VGA_X       (VGA_X),
        .VGA_Y       (VGA_Y), 
        .VGA_COLOR   (VGA_COLOR), 
        .plot        (plot)
    );

endmodule