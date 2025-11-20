`timescale 1ns/1ps
`default_nettype none

module rom512x16 (
    input  wire [8:0]  address,
    input  wire        clock,
    output reg  [15:0] q
);

    // ROM storage
    reg [15:0] mem [0:511];

    // Load from file
    initial begin
        $readmemh("sine512.hex", mem);
    end

    // Synchronous read (matches Altsyncram default behavior)
    always @(posedge clock) begin
        q <= mem[address];
    end

endmodule