`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2026 06:52:26 PM
// Design Name: 
// Module Name: clk_25MHz
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

module clk_25MHz (
    input  wire clk,
    input  wire rst,
    output reg  clk_25_en
);

    //Necesitamos generar un reloj de 25MHz, se consigue con un 
    //contador que cada 4 ciclos genere un pulso
    //ya que el reloj de la FPGA es de 100MHz
    reg [1:0] cnt;  // contador 0, 1, 2, 3

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 2'd0;
            clk_25_en <= 1'b0;
        end else begin
            if (cnt == 2'd3) begin
                cnt <= 2'd0;
                clk_25_en <= 1'b1;  // pulso de un ciclo
            end else begin
                cnt <= cnt + 2'd1;
                clk_25_en <= 1'b0;
            end
        end
    end

endmodule