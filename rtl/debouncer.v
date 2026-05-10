`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2026 05:44:28 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer (
    input wire clk,
    input wire rst,
    input wire signal_in,      // botón o switch
    output reg signal_clean
);

reg [15:0] counter;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 0;
        signal_clean <= 0;
    end else begin
        if (signal_in != signal_clean) begin
            counter <= counter + 1;

            if (counter == 16'hFFFF) begin
                signal_clean <= signal_in;
                counter <= 0;
            end

        end else begin
            counter <= 0;
        end
    end
end

endmodule
