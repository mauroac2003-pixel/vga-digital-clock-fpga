`timescale 1ns / 1ps
// ============================================================
// Testbench: tb_font_rom
// Módulo bajo prueba: font_rom
// Descripción: Verifica que la ROM de caracteres devuelva
//              los patrones correctos para cada dígito (0-9)
//              y el carácter ':' (índice 10).
// ============================================================

module tb_font_rom;

    // ── Entradas ──
    reg [7:0] addr;

    // ── Salidas ──
    wire [7:0] data;

    // ── Instancia ──
    font_rom uut (
        .addr(addr),
        .data(data)
    );

    // ── Tarea: verificar una dirección ──
    task check_addr;
        input [7:0] a;
        input [7:0] expected;
        begin
            addr = a;
            #10;
            if (data === expected)
                $display("PASS: addr=0x%02X → data=0x%02X", a, data);
            else
                $display("FAIL: addr=0x%02X → data=0x%02X (esperado 0x%02X)", a, data, expected);
        end
    endtask

    // ── Estímulos ──
    initial begin
        $display("=== TEST: font_rom ===");

        // ── Dígito 0 ──
        $display("-- Dígito 0 --");
        check_addr(8'h00, 8'b00111100); // fila 0
        check_addr(8'h0F, 8'b00111100); // fila 15

        // ── Dígito 1 ──
        $display("-- Dígito 1 --");
        check_addr(8'h10, 8'b00011000); // fila 0
        check_addr(8'h1E, 8'b01111110); // fila 14

        // ── Dígito 5 ──
        $display("-- Dígito 5 --");
        check_addr(8'h50, 8'b01111110); // fila 0
        check_addr(8'h55, 8'b01111100); // fila 5

        // ── Dígito 8 ──
        $display("-- Dígito 8 --");
        check_addr(8'h80, 8'b00111100); // fila 0
        check_addr(8'h85, 8'b00111100); // fila 5 (mitad del 8)

        // ── Dígito 9 ──
        $display("-- Dígito 9 --");
        check_addr(8'h90, 8'b00111100); // fila 0
        check_addr(8'h95, 8'b00111110); // fila 5

        // ── Carácter ':' (índice 10 = 0xA) ──
        $display("-- Carácter colon (:) --");
        check_addr(8'hA3, 8'b00011000); // fila 3 - punto superior
        check_addr(8'hAA, 8'b00011000); // fila 10 - punto inferior
        check_addr(8'hA0, 8'b00000000); // fila 0 - vacía

        // ── Dirección inválida → debe retornar 0 ──
        $display("-- Dirección inválida --");
        check_addr(8'hFF, 8'b00000000);
        check_addr(8'hB0, 8'b00000000);

        $display("=== FIN TEST: font_rom ===");
        $finish;
    end

endmodule
