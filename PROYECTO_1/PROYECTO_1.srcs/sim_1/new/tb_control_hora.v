`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2026 05:21:40 PM
// Design Name: 
// Module Name: tb_control_hora
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


module tb_control_hora;

reg clk;
reg rst;
wire [4:0] hh;
wire [5:0] mm;
wire [5:0] ss;

// instancia
control_hora uut (
    .clk_1hz(clk),
    .rst(rst),
    .hh(hh),
    .mm(mm),
    .ss(ss)
);

// reloj simulado (acelerado)
always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;

    #10 rst = 0;

    // correr simulación
    #100000 $finish;
end

endmodule
