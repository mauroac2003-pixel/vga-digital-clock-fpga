`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2026 02:20:09 PM
// Design Name: 
// Module Name: BRAM
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

module vram (
    input  wire        clk,
    // Puerto A - escritura
    input  wire        we_a,
    input  wire [18:0] addr_a,
    input  wire [11:0] data_in,
    // Puerto B - lectura 
    input  wire [18:0] addr_b,
    output reg  [11:0] data_out
);

    // Forzar el uso de BRAM
    (* ram_style = "block" *) reg [11:0] mem [0:307199];
    
    // Inicializar la BRAM
    initial begin
        $readmemh("fondo_profe.coe", mem);
    end

    // Puerto A - escritura
    always @(posedge clk) begin
        if (we_a)
            mem[addr_a] <= data_in;
    end

    // Puerto B - lectura
    always @(posedge clk) begin
        data_out <= mem[addr_b];
    end

endmodule