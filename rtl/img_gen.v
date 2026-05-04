`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2026 07:46:43 PM
// Design Name: 
// Module Name: img_gen
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

// ============================================================
// Módulo: img_gen
// Descripción: Recorre cada píxel de la pantalla (640x480) y
// decide qué color escribir en la VRAM. Si el píxel está en
// la zona del reloj consulta la font_rom para saber si ese
// píxel del dígito está encendido o apagado. Si está fuera
// de la zona del reloj simplemente pinta el fondo.
// ============================================================
module img_gen (
    input  wire        clk,      // reloj 100 MHz
    input  wire        rst,      // reset
    input  wire [4:0]  hh,       // horas   (0-23)
    input  wire [5:0]  mm,       // minutos (0-59)
    input  wire [5:0]  ss,       // segundos(0-59)
    // conexión con la VRAM (puerto de escritura)
    output reg         we,       // permiso para escribir en VRAM
    output reg  [18:0] addr,     // posición del píxel en la VRAM
    output reg  [11:0] data      // color del píxel (4R 4G 4B)
);

    // ============================================================
    // Posición del reloj en pantalla
    // El reloj tiene 8 caracteres (HH:MM:SS)
    // Cada carácter mide 32x64 píxeles (font 8x16 escalada x4)
    // Ancho total = 8 x 32 = 256 píxeles
    // X_INICIO = (640 - 256) / 2 = 192  (centrado horizontal)
    // Y_INICIO = (480 - 64)  / 2 = 208  (centrado vertical)
    // ============================================================
    localparam X_INICIO = 192;
    localparam Y_INICIO = 208;
    localparam CHAR_W   = 32;   // ancho de cada carácter en pantalla
    localparam CHAR_H   = 64;   // alto  de cada carácter en pantalla

    // ============================================================
    // Colores en formato 12 bits: 4 bits rojo, 4 verde, 4 azul
    // 12'hFFF = blanco  (1111 1111 1111)
    // 12'h008 = azul oscuro (0000 0000 1000)
    // ============================================================
    localparam COLOR_FONDO  = 12'h008;
    localparam COLOR_DIGITO = 12'hFFF;

    // ============================================================
    // Separar la hora en dígitos individuales
    // Ejemplo: hh=12 → hh_dec=1, hh_uni=2
    // ============================================================
    wire [3:0] hh_dec = hh / 10;
    wire [3:0] hh_uni = hh % 10;
    wire [3:0] mm_dec = mm / 10;
    wire [3:0] mm_uni = mm % 10;
    wire [3:0] ss_dec = ss / 10;
    wire [3:0] ss_uni = ss % 10;

    // ============================================================
    // Contadores x, y - representan el píxel actual que
    // el pintor está procesando. Van de izquierda a derecha
    // y de arriba a abajo, igual que leer un texto.
    // ============================================================
    reg [9:0] x;   // columna actual (0 a 639)
    reg [9:0] y;   // fila actual    (0 a 479)

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x <= 10'd0;
            y <= 10'd0;
        end else begin
            // avanzar al siguiente píxel
            if (x == 639) begin
                x <= 10'd0;          // fin de fila, volver al inicio
                if (y == 479)
                    y <= 10'd0;      // fin de pantalla, empezar de nuevo
                else
                    y <= y + 10'd1;  // siguiente fila
            end else begin
                x <= x + 10'd1;     // siguiente columna
            end
        end
    end

    // ============================================================
    // Conexión con la font_rom
    // font_addr - le preguntamos qué dígito y qué fila queremos
    // font_data - nos devuelve 8 bits, uno por columna de esa fila
    // ============================================================
    reg  [7:0] font_addr;
    wire [7:0] font_data;

    font_rom font (
        .addr (font_addr),
        .data (font_data)
    );

    // ============================================================
    // Variables internas para calcular qué píxel de la font
    // corresponde al píxel actual de la pantalla
    // ============================================================

    // char_pos: qué carácter de los 8 es este píxel
    //   0=hh_dec, 1=hh_uni, 2=':', 3=mm_dec, 4=mm_uni,
    //   5=':', 6=ss_dec, 7=ss_uni
    reg [2:0] char_pos;

    // pixel_x: posición horizontal dentro del carácter (0 a 31)
    // pixel_y: posición vertical   dentro del carácter (0 a 63)
    reg [4:0] pixel_x;
    reg [5:0] pixel_y;

    // char_idx: índice del dígito para consultar la font_rom
    //   0-9 = dígitos, 10 = ':'
    reg [3:0] char_idx;

    // col_font: columna dentro de la font (0 a 7)
    // Es pixel_x dividido entre 4 porque cada píxel
    // de la font ocupa 4 píxeles en pantalla
    reg [2:0] col_font;

    // ============================================================
    // Lógica principal - para cada píxel decide qué color poner
    // ============================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            we        <= 1'b0;
            addr      <= 19'd0;
            data      <= 12'd0;
            font_addr <= 8'd0;
        end else begin

            // siempre habilitamos escritura en la VRAM
            we <= 1'b1;

            // calculamos la dirección del píxel actual en la VRAM
            // fórmula: fila × ancho_pantalla + columna
            addr <= y * 640 + x;

            // ── ¿Estamos dentro del área del reloj? ──
            if (x >= X_INICIO && x < X_INICIO + 8*CHAR_W &&
                y >= Y_INICIO && y < Y_INICIO + CHAR_H) begin

                // posición relativa dentro del área del reloj
                // (cuántos píxeles desde el inicio del reloj)
                pixel_x = x - X_INICIO;
                pixel_y = y - Y_INICIO;

                // qué carácter de los 8 es este píxel
                // dividimos pixel_x entre 32 (ancho de un carácter)
                char_pos = pixel_x / CHAR_W;

                // posición dentro del carácter específico
                // restamos los píxeles de los caracteres anteriores
                pixel_x = pixel_x - (char_pos * CHAR_W);

                // qué dígito va en esta posición
                case (char_pos)
                    3'd0: char_idx = hh_dec;
                    3'd1: char_idx = hh_uni;
                    3'd2: char_idx = 4'd10;   // ':'
                    3'd3: char_idx = mm_dec;
                    3'd4: char_idx = mm_uni;
                    3'd5: char_idx = 4'd10;   // ':'
                    3'd6: char_idx = ss_dec;
                    3'd7: char_idx = ss_uni;
                    default: char_idx = 4'd0;
                endcase

                // armar la dirección para la font_rom
                // los 4 bits altos = qué dígito
                // los 4 bits bajos = qué fila (pixel_y / 4)
                font_addr = { char_idx, pixel_y[5:2] };

                // qué columna de la font es esta
                // pixel_x / 4 porque cada píxel font = 4px pantalla
                col_font = pixel_x[4:2];

                // leer el bit de esa columna en font_data
                // bit 7 = columna izquierda, bit 0 = columna derecha
                // por eso hacemos 7 - col_font
                if (font_data[7 - col_font])
                    data <= COLOR_DIGITO;  // píxel encendido → blanco
                else
                    data <= COLOR_FONDO;   // píxel apagado   → azul

            end else begin
                // fuera del área del reloj → solo fondo
                data <= COLOR_FONDO;
            end
        end
    end

endmodule