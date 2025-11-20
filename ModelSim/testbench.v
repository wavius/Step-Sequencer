`timescale 1ns/1ps
`default_nettype none

module testbench;

    reg CLOCK_50;
    reg [3:0] KEY;

    reg [8:0] sim_data;
    reg       sim_data_en;

    // Outputs
    wire [9:0] VGA_X;
    wire [8:0] VGA_Y;
    wire [23:0] VGA_COLOR;
    wire plot;

    wire [9:0] LEDR;
    wire [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;

    // Instantiate DUT
    step_sequencer DUT (
        .CLOCK_50   (CLOCK_50),
        .KEY        ({2'b00, KEY[0]}),

        .LEDR       (LEDR),
        .HEX0       (HEX0),
        .HEX1       (HEX1),
        .HEX2       (HEX2),
        .HEX3       (HEX3),
        .HEX4       (HEX4),
        .HEX5       (HEX5),

        .sim_data   (sim_data),
        .sim_data_en(sim_data_en)
    );

    // 50 MHz clock
    always #10 CLOCK_50 = ~CLOCK_50;

    //---------------------------------------------------------
    // Helper task to send scan codes
    //---------------------------------------------------------
    task send_scancode(input [7:0] code);
    begin
        sim_data     = code;
        sim_data_en  = 1;
        #20;
        sim_data_en  = 0;
        #80;
    end
    endtask


    initial begin
        // Init
        CLOCK_50   = 0;
        KEY        = 4'b1111;
        sim_data   = 8'h00;
        sim_data_en= 0;

        // Reset
        #5;
        KEY[0] = 0;
        #100;
        KEY[0] = 1;
        #200;

        // -----------------------------------------------------
        // b 9 9 9 Enter   l 1 Enter   m Space —— long wait —— Enter Space
        // -----------------------------------------------------

        // l
        send_scancode(8'h4B);

        // 1
        send_scancode(8'h16);

        // Enter
        send_scancode(8'h5A);

        // b
        send_scancode(8'h32);

        // 999
        send_scancode(8'h46);
        send_scancode(8'h46);
        send_scancode(8'h46);

        // Enter
        send_scancode(8'h5A);

        // Space
        send_scancode(8'h29);

         send_scancode(8'hF0);

        // >>> Long delay here <<<
        //#20000;    // adjust as needed
        #50000;
        $stop;
    end

endmodule