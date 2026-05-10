`timescale 1ns / 1ps
// ============================================================
// Testbench: tb_clk_25MHz
// Módulo bajo prueba: clk_25MHz
// Descripción: Verifica que el generador de enable de 25 MHz
//              produzca exactamente un pulso de 1 ciclo
//              cada 4 ciclos de reloj (100 MHz / 4 = 25 MHz).
// ============================================================

module tb_clk_25MHz;

    // ── Entradas ──
    reg clk;
    reg rst;

    // ── Salidas ──
    wire clk_25_en;

    // ── Instancia del módulo bajo prueba ──
    clk_25MHz uut (
        .clk      (clk),
        .rst      (rst),
        .clk_25_en(clk_25_en)
    );

    // ── Reloj 100 MHz ──
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Variables ──
    integer pulses;
    integer cycle;
    integer last_pulse_cycle;
    integer spacing;

    // ── Estímulos ──
    initial begin
        $display("=== TEST: clk_25MHz ===");

        rst    = 1;
        pulses = 0;
        repeat(5) @(posedge clk);
        rst = 0;
        $display("[%0t] Reset liberado", $time);

        // Contar 8 pulsos y verificar que ocurran cada 4 ciclos
        last_pulse_cycle = 0;
        cycle            = 0;

        repeat(40) begin
            @(posedge clk);
            cycle = cycle + 1;
            if (clk_25_en) begin
                pulses = pulses + 1;
                spacing = cycle - last_pulse_cycle;
                if (pulses > 1) begin
                    if (spacing == 4)
                        $display("PASS: Pulso %0d cada 4 ciclos (ciclo %0d)", pulses, cycle);
                    else
                        $display("FAIL: Pulso %0d en ciclo %0d, espaciado=%0d (esperado 4)", pulses, cycle, spacing);
                end
                last_pulse_cycle = cycle;
            end
        end

        // Verificar que rst apaga el enable
        rst = 1;
        @(posedge clk);
        @(posedge clk);
        if (clk_25_en === 1'b0)
            $display("PASS: Reset pone clk_25_en en 0");
        else
            $display("FAIL: clk_25_en debería ser 0 tras reset");

        $display("Total pulsos detectados en 40 ciclos: %0d (esperado ~9)", pulses);
        $display("=== FIN TEST: clk_25MHz ===");
        $finish;
    end

endmodule
