`timescale 1ns/1ps
`default_nettype none

module rom256x12 (
    input  wire [7:0]  address,
    input  wire        clock,
    output reg  [11:0] q
);

    // ROM storage
    reg [11:0] mem [0:255];

    // Initialize from MIF
    initial begin
        $readmemh("sine256.hex", mem);
    end

    // Synchronous read (matches Altsyncram default behavior)
    always @(posedge clock) begin
        q <= mem[address];
    end

endmodule