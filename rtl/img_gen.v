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



// Descripción: Recorre cada píxel de la pantalla (640x480) y
// decide qué color escribir en la VRAM. Si el píxel está en
// la zona del reloj consulta la font_rom para saber si ese
// píxel del dígito está encendido o apagado. Si está fuera
// de la zona del reloj restaura la imagen original del fondo.

module img_gen (
    input  wire        clk,      // reloj 100 MHz
    input  wire        rst,      // reset
    input  wire [4:0]  hh,       // horas   (0-23)
    input  wire [5:0]  mm,       // minutos (0-59)
    input  wire [5:0]  ss,       // segundos(0-59)
    input  wire [1:0]  sw,       // modo edición (00=auto, 01=ss, 10=mm, 11=hh)
    input  wire        blink,    // señal de parpadeo ~2Hz
    // conexión con la VRAM (puerto de escritura)
    output reg         we,       // permiso para escribir en VRAM
    output reg  [18:0] addr,     // posición del píxel en la VRAM
    output reg  [11:0] data      // color del píxel (4R 4G 4B)
);

    // Posición del reloj en pantalla
    // El reloj tiene 8 caracteres (HH:MM:SS)
    // Cada carácter mide 32x64 píxeles (font 8x16 escalada x4)
    // Ancho total = 8 x 32 = 256 píxeles
    // X_INICIO = 20 (desplazado a la izquierda)
    // Y_INICIO = (480 - 64) / 2 = 208 (centrado vertical)
    localparam X_INICIO = 20;
    localparam Y_INICIO = 208;
    localparam CHAR_W   = 32;   // ancho de cada carácter en pantalla
    localparam CHAR_H   = 64;   // alto  de cada carácter en pantalla

    // Colores en formato 12 bits: 4 bits rojo, 4 verde, 4 azul
    // 12'h000 = negro  (0000 0000 0000)
    localparam COLOR_DIGITO = 12'h000;  // negro

    // Separar la hora en dígitos individuales
    // Ejemplo: hh=12 → hh_dec=1, hh_uni=2
    wire [3:0] hh_dec = hh / 10;
    wire [3:0] hh_uni = hh % 10;
    wire [3:0] mm_dec = mm / 10;
    wire [3:0] mm_uni = mm % 10;
    wire [3:0] ss_dec = ss / 10;
    wire [3:0] ss_uni = ss % 10;

    // Contadores x, y - representan el píxel actual que
    // el pintor está procesando. Van de izquierda a derecha
    // y de arriba a abajo, igual que leer un texto.
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

    // ROM de respaldo con la imagen original del fondo
    // Se usa para restaurar los píxeles apagados de los dígitos
    // y mantener la imagen visible debajo del reloj
    (* rom_style = "block" *) reg [11:0] fondo_rom [0:307199];
    initial begin
        $readmemh("fondo_profe.coe", fondo_rom);
    end

    // Cálculo combinacional
    // Todo se calcula como wire para que font_data esté
    // disponible en el mismo ciclo que se necesita
    wire        en_zona;      // estamos dentro del área del reloj
    wire [9:0]  px_rel;       // posición relativa en x dentro del área
    wire [9:0]  py_rel;       // posición relativa en y dentro del área
    wire [2:0]  char_pos_w;   // qué carácter de los 8 es este píxel
    wire [4:0]  pixel_x_w;    // posición horizontal dentro del carácter
    wire [5:0]  pixel_y_w;    // posición vertical dentro del carácter
    wire [3:0]  char_idx_w;   // índice del dígito (0-9 o 10 para ':')
    wire [2:0]  col_font_w;   // columna dentro de la font (0 a 7)
    wire [7:0]  font_addr_w;  // dirección para la font_rom
    wire [7:0]  font_data;    // respuesta de la font_rom

    // ¿estamos en la zona del reloj?
    assign en_zona = (x >= X_INICIO) && (x < X_INICIO + 8*CHAR_W) &&
                     (y >= Y_INICIO) && (y < Y_INICIO + CHAR_H);

    // posición relativa dentro del área del reloj
    assign px_rel = x - X_INICIO;
    assign py_rel = y - Y_INICIO;

    // qué carácter de los 8 es este píxel
    // dividimos px_rel entre 32 (ancho de un carácter)
    assign char_pos_w = px_rel / CHAR_W;

    // posición dentro del carácter específico
    // restamos los píxeles de los caracteres anteriores
    assign pixel_x_w = px_rel - (char_pos_w * CHAR_W);
    assign pixel_y_w = py_rel[5:0];

    // qué dígito va en esta posición
    assign char_idx_w = (char_pos_w == 3'd0) ? hh_dec :
                        (char_pos_w == 3'd1) ? hh_uni :
                        (char_pos_w == 3'd2) ? 4'd10  :  // ':'
                        (char_pos_w == 3'd3) ? mm_dec :
                        (char_pos_w == 3'd4) ? mm_uni :
                        (char_pos_w == 3'd5) ? 4'd10  :  // ':'
                        (char_pos_w == 3'd6) ? ss_dec :
                        (char_pos_w == 3'd7) ? ss_uni : 4'd0;

    // armar la dirección para la font_rom
    // los 4 bits altos = qué dígito
    // los 4 bits bajos = qué fila (pixel_y / 4)
    assign font_addr_w = { char_idx_w, pixel_y_w[5:2] };

    // qué columna de la font es esta
    // pixel_x / 4 porque cada píxel font = 4px pantalla
    assign col_font_w = pixel_x_w[4:2];

    // Conexión con la font_rom
    // font_addr_w - le preguntamos qué dígito y qué fila queremos
    // font_data   - nos devuelve 8 bits, uno por columna de esa fila
    font_rom font (
        .addr (font_addr_w),
        .data (font_data)
    );

    // Parpadeo en modo edición
    // Detecta si el carácter actual está siendo editado
    // Si está editando y blink=0 → restaura el fondo
    wire editando_hh = (sw == 2'b11) &&
                       (char_pos_w == 3'd0 || char_pos_w == 3'd1);
    wire editando_mm = (sw == 2'b10) &&
                       (char_pos_w == 3'd3 || char_pos_w == 3'd4);
    wire editando_ss = (sw == 2'b01) &&
                       (char_pos_w == 3'd6 || char_pos_w == 3'd7);
    wire editando    = editando_hh || editando_mm || editando_ss;

    // Lógica principal - para cada píxel decide qué color poner
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            we   <= 1'b0;
            addr <= 19'd0;
            data <= 12'd0;
        end else begin

            // siempre habilitamos escritura en la VRAM
            we   <= 1'b1;

            // calculamos la dirección del píxel actual en la VRAM
            // fórmula: fila × ancho_pantalla + columna
            addr <= y * 640 + x;

            if (en_zona) begin
                // si está editando y blink=0 → restaurar fondo (parpadeo)
                if (editando && !blink)
                    data <= fondo_rom[y * 640 + x];
                else begin
                    // leer el bit de esa columna en font_data
                    // bit 7 = columna izquierda, bit 0 = columna derecha
                    // por eso hacemos 7 - col_font_w
                    if (font_data[7 - col_font_w])
                        data <= COLOR_DIGITO;            // píxel encendido → negro
                    else
                        data <= fondo_rom[y * 640 + x];  // píxel apagado → imagen original
                end
            end else begin
                // fuera del área del reloj → restaurar imagen original
                data <= fondo_rom[y * 640 + x];
            end
        end
    end

endmodule