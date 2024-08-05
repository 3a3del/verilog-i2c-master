`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muhammed Adel
// 
// Create Date: 08/05/2024 03:38:10 AM
// Design Name: 
// Module Name: Single Port RAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module RAM #(parameter N = 8)(
    input clk,               // System clock
    input [N-1:0] addr,      // Address bus
    input [N-1:0] wdata,     // Data input for write
    output reg [N-1:0] rdata,// Data output for read
    input we,                // Write enable
    input re                 // Read enable
);
    reg [N-1:0] mem [0:255]; // Memory array (256 x N-bit)

    // Memory initialization in TestBench
//    integer i;
//    initial begin
//        for (i = 0; i < 256; i = i + 1) begin  
//            mem[i] = {N{1'b0}};
//        end
//    end

    always @(posedge clk) begin
        if (we && !re) begin
            mem[addr] <= wdata;  // Write operation
        end
        else if (re && !we) begin
            rdata <= mem[addr];  // Read operation
        end
    end
endmodule
