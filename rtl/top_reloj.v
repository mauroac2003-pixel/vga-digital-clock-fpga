`timescale 1ns / 1ps

// ============================================================
// Módulo: top_vga_reloj
// Descripción: Módulo principal que integra todos los
// subsistemas. Mantiene el display 7 segmentos para debug
// y agrega la salida VGA con el reloj en pantalla.
// ============================================================
module top_reloj (
    input  wire        clk,       // reloj 100 MHz
    input  wire        rst_sw,    // reset - SW0
    input  wire [1:0]  sw,        // modo edición - SW2:SW1
    input  wire        btn_up,    // incrementar - BTNU
    input  wire        btn_down,  // decrementar - BTND
    // display 7 segmentos (para debug)
    output wire [6:0]  seg,
    output wire [7:0]  an,
    // salidas VGA
    output wire        hsync,
    output wire        vsync,
    output wire [3:0]  vga_r,
    output wire [3:0]  vga_g,
    output wire [3:0]  vga_b
);

    // ============================================================
    // Señales internas
    // ============================================================

    // señales que ya tenían
    wire        rst_clean;
    wire        btn_up_clean;
    wire        btn_down_clean;
    wire        clk_1hz;
    wire [4:0]  hh;
    wire [5:0]  mm;
    wire [5:0]  ss;

    // señales nuevas para VGA
    wire        clk_25_en;    // enable de 25 MHz para vga_sync
    wire [9:0]  hcount;       // contador horizontal del vga_sync
    wire [9:0]  vcount;       // contador vertical del vga_sync
    wire        video_en;     // activo cuando estamos en zona visible

    // señales entre img_gen y vram
    wire        we;           // permiso de escritura del img_gen
    wire [18:0] wr_addr;      // dirección de escritura del img_gen
    wire [11:0] wr_data;      // color que escribe el img_gen

    // señal entre vram y salida RGB
    wire [11:0] pixel_color;  // color leído de la vram

    // ============================================================
    // Blink para display 7 segmentos (~2 Hz)
    // ============================================================
    reg [25:0] blink_cnt;
    reg        blink;

    always @(posedge clk or posedge rst_clean) begin
        if (rst_clean) begin
            blink_cnt <= 26'd0;
            blink     <= 1'b0;
        end else begin
            if (blink_cnt == 26'd25_000_000) begin
                blink     <= ~blink;
                blink_cnt <= 26'd0;
            end else begin
                blink_cnt <= blink_cnt + 26'd1;
            end
        end
    end

    // ============================================================
    // Debouncers
    // ============================================================
    debouncer db_rst (
        .clk        (clk),
        .rst        (1'b0),
        .signal_in  (rst_sw),
        .signal_clean(rst_clean)
    );

    debouncer db_up (
        .clk        (clk),
        .rst        (1'b0),
        .signal_in  (btn_up),
        .signal_clean(btn_up_clean)
    );

    debouncer db_down (
        .clk        (clk),
        .rst        (1'b0),
        .signal_in  (btn_down),
        .signal_clean(btn_down_clean)
    );

    // ============================================================
    // Divisor 1 Hz - para que el reloj avance cada segundo
    // ============================================================
    clock_divider div_1hz (
        .clk    (clk),
        .rst    (rst_clean),
        .clk_1hz(clk_1hz)
    );

    // ============================================================
    // Control de hora - mantiene hh, mm, ss actualizados
    // ============================================================
    control_hora_manual reloj (
        .clk     (clk),
        .clk_1hz (clk_1hz),
        .rst     (rst_clean),
        .sw      (sw),
        .btn_up  (btn_up_clean),
        .btn_down(btn_down_clean),
        .hh      (hh),
        .mm      (mm),
        .ss      (ss)
    );

    // ============================================================
    // Display 7 segmentos - para verificar que la hora
    // funciona correctamente mientras se prueba el VGA
    // ============================================================
    display_7seg disp (
        .clk  (clk),
        .rst  (rst_clean),
        .hh   (hh),
        .mm   (mm),
        .ss   (ss),
        .sw   (sw),
        .blink(blink),
        .seg  (seg),
        .an   (an)
    );

    // ============================================================
    // Divisor 25 MHz - genera el enable para el vga_sync
    // ============================================================
    clk_25MHz div_25 (
        .clk      (clk),
        .rst      (rst_clean),
        .clk_25_en(clk_25_en)
    );

    // ============================================================
    // VGA sync - genera hcount, vcount, hsync, vsync, video_en
    // ============================================================
    vga_sync sync (
        .clk      (clk),
        .rst      (rst_clean),
        .clk_25_en(clk_25_en),
        .hcount   (hcount),
        .vcount   (vcount),
        .hsync    (hsync),
        .vsync    (vsync),
        .video_en (video_en)
    );

    // ============================================================
    // img_gen - recorre la pantalla y escribe colores en la VRAM
    // ============================================================
    img_gen imagen (
        .clk  (clk),
        .rst  (rst_clean),
        .hh   (hh),
        .mm   (mm),
        .ss   (ss),
        .we   (we),
        .addr (wr_addr),
        .data (wr_data)
    );

    // ============================================================
    // VRAM - almacena el color de cada píxel
    // Puerto A: img_gen escribe
    // Puerto B: vga_ctrl lee usando hcount y vcount
    // ============================================================
    vram memoria (
        .clk     (clk),
        .we_a    (we),
        .addr_a  (wr_addr),
        .data_in (wr_data),
        .addr_b  (vcount * 640 + hcount),
        .data_out(pixel_color)
    );

    // ============================================================
    // Salidas RGB
    // Si video_en está activo mandamos el color de la VRAM
    // Si no estamos en zona visible mandamos negro
    // Los 12 bits del color se dividen en tres grupos de 4:
    //   pixel_color[11:8] → rojo
    //   pixel_color[7:4]  → verde
    //   pixel_color[3:0]  → azul
    // ============================================================
    assign vga_r = video_en ? pixel_color[11:8] : 4'h0;
    assign vga_g = video_en ? pixel_color[7:4]  : 4'h0;
    assign vga_b = video_en ? pixel_color[3:0]  : 4'h0;

endmodule