`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2026 05:35:04 PM
// Design Name: 
// Module Name: vga_sync
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


module vga_sync (
    input  wire        clk,
    input  wire        rst,
    input  wire        clk_25_en,
    output reg  [9:0]  hcount,
    output reg  [9:0]  vcount,
    output reg         hsync,
    output reg         vsync,
    output wire        video_en
);

    // Constantes 
    localparam H_VISIBLE = 640;
    localparam H_FP      = 16;
    localparam H_SYNC    = 96;
    localparam H_BP      = 48;
    localparam H_TOTAL   = 800;

    localparam V_VISIBLE = 480;
    localparam V_FP      = 10;
    localparam V_SYNC    = 2;
    localparam V_BP      = 33;
    localparam V_TOTAL   = 525;

    //  Contadores horizontal y vertical 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hcount <= 10'd0;
            vcount <= 10'd0;
        end else if (clk_25_en) begin

            // Al final de una línea: resetear hcount y avanzar vcount
            if (hcount == H_TOTAL - 1) begin
                hcount <= 10'd0;

                if (vcount == V_TOTAL - 1)
                    vcount <= 10'd0;     // fin de frame
                else
                    vcount <= vcount + 10'd1;

            end else begin
                hcount <= hcount + 10'd1;
            end

        end
    end

    // HSYNC 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hsync <= 1'b1;
        end else if (clk_25_en) begin

            // hcount va contando cada pixel de la línea
            // Cuando ya termina de dibujar lo visible (H_VISIBLE)
            // y pasa un pequeño espacio (H_FP),
            // en este punto se le dice a la pantalla:
            // "ya se acabó la línea"
            // hsync baja por un rato (H_SYNC ciclos)
            // y eso la pantalla lo interpreta como:
            // saltar a la siguiente línea
            if (hcount >= H_VISIBLE + H_FP &&
                hcount <  H_VISIBLE + H_FP + H_SYNC)
                hsync <= 1'b0;   // estamos en el pulso de sync
            else
                hsync <= 1'b1;   // fuera del pulso

        end
    end

    // ── VSYNC ──
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            vsync <= 1'b1;
        end else if (clk_25_en) begin
  
            // Aquí se envia el "pulso de fin de pantalla"
            // vsync en 0 = nuevo frame
            if (vcount >= V_VISIBLE + V_FP &&
                vcount <  V_VISIBLE + V_FP + V_SYNC)
                vsync <= 1'b0;   // estamos en el pulso de sync
            else
                vsync <= 1'b1;   // fuera del pulso

        end
    end

    // Zona en la que se dibuja
    // Mientras (hcount < 640) y (vcount < 480) (esta dentro de la pantalla) 
    assign video_en = (hcount < H_VISIBLE) && (vcount < V_VISIBLE);

endmodule