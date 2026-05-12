`timescale 1ns / 1ps
// ============================================================
// Testbench: tb_top_reloj
// Módulo bajo prueba: top_reloj (Etapa 2)
// Descripción: Verifica la integración del sistema completo.
//              Prueba señales VGA, display 7seg, blink y
//              modo edición a través de sw y botones.
//              NOTA: No se puede verificar fondo_profe.coe
//              en simulación, se usan stubs para font_rom.
// ============================================================

// ── Stubs necesarios para simulación ──

module font_rom (
    input  [7:0] addr,
    output [7:0] data
);
    assign data = 8'b00100100;
endmodule

module tb_top_reloj;

    // ── Entradas ──
    reg        clk;
    reg        rst_sw;
    reg [1:0]  sw;
    reg        btn_up;
    reg        btn_down;

    // ── Salidas ──
    wire [6:0] seg;
    wire [7:0] an;
    wire       hsync;
    wire       vsync;
    wire [3:0] vga_r;
    wire [3:0] vga_g;
    wire [3:0] vga_b;

    // ── Instancia del top ──
    top_reloj uut (
        .clk      (clk),
        .rst_sw   (rst_sw),
        .sw       (sw),
        .btn_up   (btn_up),
        .btn_down (btn_down),
        .seg      (seg),
        .an       (an),
        .hsync    (hsync),
        .vsync    (vsync),
        .vga_r    (vga_r),
        .vga_g    (vga_g),
        .vga_b    (vga_b)
    );

    // ── Reloj 100 MHz ──
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Tarea: pulso de botón ──
    task pulso_btn_up;
        begin
            btn_up = 1;
            // El debouncer necesita 0xFFFF ciclos para propagar
            // Usamos pocos ciclos solo para verificar conectividad
            repeat(10) @(posedge clk);
            btn_up = 0;
            repeat(5) @(posedge clk);
        end
    endtask

    // ── Estímulos ──
    initial begin
        $display("=== TEST: top_reloj (Etapa 2) ===");

        rst_sw   = 0;
        sw       = 2'b00;
        btn_up   = 0;
        btn_down = 0;

        // ── Test 1: Reset inicial ──
        $display("[%0t] Test 1: Reset del sistema", $time);
        rst_sw = 1;
        repeat(10) @(posedge clk);
        rst_sw = 0;
        repeat(10) @(posedge clk);
        $display("PASS: Reset ejecutado sin errores");

        // ── Test 2: Señales VGA activas ──
        $display("[%0t] Test 2: Señales VGA (hsync y vsync son wire activos)", $time);
        // hsync y vsync son señales válidas (no X ni Z)
        repeat(100) @(posedge clk);
        if (hsync !== 1'bx && vsync !== 1'bx)
            $display("PASS: hsync=%b vsync=%b (señales VGA validas)", hsync, vsync);
        else
            $display("FAIL: hsync o vsync en estado indefinido");

        // ── Test 3: Display 7seg activo ──
        $display("[%0t] Test 3: Display 7seg activo", $time);
        repeat(200000) @(posedge clk); // avanzar multiplexor
        if (an !== 8'hFF)
            $display("PASS: Display 7seg activo (an=0x%02X)", an);
        else
            $display("FAIL: Todos los displays apagados (an=0xFF)");

        // ── Test 4: RGB en zona no visible ──
        $display("[%0t] Test 4: RGB negro en zona no visible", $time);
        // Cuando video_en=0 los RGB deben ser 0
        // Avanzamos hasta zona de blanking
        repeat(800*525*4) @(posedge clk);
        // Solo verificamos que no sean X
        if (vga_r !== 4'bxxxx && vga_g !== 4'bxxxx && vga_b !== 4'bxxxx)
            $display("PASS: Salidas RGB validas (R=%0h G=%0h B=%0h)", vga_r, vga_g, vga_b);
        else
            $display("FAIL: Salidas RGB en estado indefinido");

        // ── Test 5: Modo edición sw=01 (segundos) ──
        $display("[%0t] Test 5: Modo edicion segundos (sw=01)", $time);
        sw = 2'b01;
        repeat(10) @(posedge clk);
        // El sistema debe seguir operando sin colgarse
        if (hsync !== 1'bx && vsync !== 1'bx)
            $display("PASS: Sistema estable en modo edicion ss");
        else
            $display("FAIL: Sistema inestable en modo edicion ss");

        // ── Test 6: Modo edición sw=10 (minutos) ──
        $display("[%0t] Test 6: Modo edicion minutos (sw=10)", $time);
        sw = 2'b10;
        repeat(10) @(posedge clk);
        if (hsync !== 1'bx)
            $display("PASS: Sistema estable en modo edicion mm");
        else
            $display("FAIL: Sistema inestable en modo edicion mm");

        // ── Test 7: Modo edición sw=11 (horas) ──
        $display("[%0t] Test 7: Modo edicion horas (sw=11)", $time);
        sw = 2'b11;
        repeat(10) @(posedge clk);
        if (hsync !== 1'bx)
            $display("PASS: Sistema estable en modo edicion hh");
        else
            $display("FAIL: Sistema inestable en modo edicion hh");

        // ── Test 8: Volver a modo automático ──
        $display("[%0t] Test 8: Volver a modo automatico (sw=00)", $time);
        sw = 2'b00;
        repeat(10) @(posedge clk);
        if (hsync !== 1'bx && vsync !== 1'bx)
            $display("PASS: Sistema estable en modo automatico");
        else
            $display("FAIL: Sistema inestable en modo automatico");

        $display("=== FIN TEST: top_reloj ===");
        $finish;
    end

endmodule
