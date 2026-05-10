`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2026 05:51:55 PM
// Design Name: 
// Module Name: clock_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_divider (
    input clk,        // 100 MHz
    input rst,
    output reg clk_1hz
);

reg [26:0] counter;  // suficiente para 100M

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 0;
        clk_1hz <= 0;
    end else begin
        if (counter == 50_000_000 - 1) begin
            clk_1hz <= ~clk_1hz;
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
end

endmodule
