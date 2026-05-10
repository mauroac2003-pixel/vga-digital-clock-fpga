`timescale 1ns / 1ps
// ============================================================
// Testbench: tb_debouncer
// Módulo bajo prueba: debouncer
// Descripción: Verifica que el módulo antirrebote no propague
//              pulsos cortos (rebotes) y sí propague señales
//              estables durante 0xFFFF ciclos.
// ============================================================

module tb_debouncer;

    // ── Entradas ──
    reg clk;
    reg rst;
    reg signal_in;

    // ── Salidas ──
    wire signal_clean;

    // ── Instancia ──
    debouncer uut (
        .clk        (clk),
        .rst        (rst),
        .signal_in  (signal_in),
        .signal_clean(signal_clean)
    );

    // ── Reloj 100 MHz ──
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Estímulos ──
    initial begin
        $display("=== TEST: debouncer ===");

        rst       = 1;
        signal_in = 0;
        repeat(5) @(posedge clk);
        rst = 0;
        $display("[%0t] Reset liberado. signal_clean inicial = %b", $time, signal_clean);

        // ── Test 1: Pulso corto (rebote) NO debe pasar ──
        $display("[%0t] Test 1: Pulso corto de 10 ciclos (rebote)", $time);
        signal_in = 1;
        repeat(10) @(posedge clk);
        signal_in = 0;
        repeat(10) @(posedge clk);

        if (signal_clean === 1'b0)
            $display("PASS: Pulso corto no propagado (debounce correcto)");
        else
            $display("FAIL: Pulso corto propagado incorrectamente");

        // ── Test 2: Señal estable durante 0xFFFF+1 ciclos SÍ debe pasar ──
        $display("[%0t] Test 2: Señal estable durante 0xFFFF+10 ciclos", $time);
        signal_in = 1;
        repeat(16'hFFFF + 10) @(posedge clk);

        if (signal_clean === 1'b1)
            $display("PASS: Señal estable propagada correctamente");
        else
            $display("FAIL: Señal estable no fue propagada");

        // ── Test 3: Bajar señal estable ──
        $display("[%0t] Test 3: Bajar señal estable", $time);
        signal_in = 0;
        repeat(16'hFFFF + 10) @(posedge clk);

        if (signal_clean === 1'b0)
            $display("PASS: Bajada de señal propagada correctamente");
        else
            $display("FAIL: Bajada no propagada");

        // ── Test 4: Reset ──
        signal_in = 1;
        repeat(100) @(posedge clk);
        rst = 1;
        @(posedge clk);
        if (signal_clean === 1'b0)
            $display("PASS: Reset limpia signal_clean");
        else
            $display("FAIL: Reset no limpió signal_clean");

        $display("=== FIN TEST: debouncer ===");
        $finish;
    end

endmodule
