`timescale 1ns / 1ps
// ============================================================
// Testbench: tb_control_hora_manual
// Módulo bajo prueba: control_hora_manual
// Descripción: Verifica el conteo automático de segundos,
//              minutos y horas, así como el modo edición
//              con btn_up y btn_down para ss, mm y hh.
// ============================================================

module tb_control_hora_manual;

    // ── Entradas ──
    reg        clk;
    reg        clk_1hz;
    reg        rst;
    reg [1:0]  sw;
    reg        btn_up;
    reg        btn_down;

    // ── Salidas ──
    wire [4:0] hh;
    wire [5:0] mm;
    wire [5:0] ss;

    // ── Instancia ──
    control_hora_manual uut (
        .clk     (clk),
        .clk_1hz (clk_1hz),
        .rst     (rst),
        .sw      (sw),
        .btn_up  (btn_up),
        .btn_down(btn_down),
        .hh      (hh),
        .mm      (mm),
        .ss      (ss)
    );

    // ── Reloj 100 MHz ──
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Tarea: generar un tick de 1 Hz ──
    task tick_1hz_pulse;
        begin
            clk_1hz = 1;
            @(posedge clk);
            clk_1hz = 0;
            @(posedge clk);
        end
    endtask

    // ── Tarea: pulso de botón (1 ciclo) ──
    task press_up;
        begin
            btn_up = 1;
            @(posedge clk);
            btn_up = 0;
            @(posedge clk);
        end
    endtask

    task press_down;
        begin
            btn_down = 1;
            @(posedge clk);
            btn_down = 0;
            @(posedge clk);
        end
    endtask

    // ── Estímulos ──
    initial begin
        $display("=== TEST: control_hora_manual ===");

        // Init
        rst      = 1;
        clk_1hz  = 0;
        sw       = 2'b00;
        btn_up   = 0;
        btn_down = 0;
        repeat(5) @(posedge clk);
        rst = 0;
        $display("[%0t] Reset liberado. hh=%0d mm=%0d ss=%0d", $time, hh, mm, ss);

        // ── Test 1: Conteo automático de segundos ──
        $display("[%0t] Test 1: Conteo automático (sw=00)", $time);
        sw = 2'b00;
        repeat(3) tick_1hz_pulse;
        repeat(5) @(posedge clk);

        if (ss == 3)
            $display("PASS: ss=%0d tras 3 ticks (esperado 3)", ss);
        else
            $display("FAIL: ss=%0d (esperado 3)", ss);

        // ── Test 2: Rollover de segundos a minutos ──
        $display("[%0t] Test 2: Rollover ss→mm", $time);
        rst = 1; @(posedge clk); rst = 0;
        sw = 2'b00;
        repeat(59) tick_1hz_pulse;
        repeat(5) @(posedge clk);
        if (ss == 59 && mm == 0)
            $display("INFO: ss=59 antes del rollover OK");

        tick_1hz_pulse;
        repeat(5) @(posedge clk);
        if (ss == 0 && mm == 1)
            $display("PASS: Rollover ss→mm correcto (ss=%0d mm=%0d)", ss, mm);
        else
            $display("FAIL: Rollover fallido (ss=%0d mm=%0d)", ss, mm);

        // ── Test 3: Edición de segundos con btn_up ──
        $display("[%0t] Test 3: Edición de ss con btn_up (sw=01)", $time);
        rst = 1; @(posedge clk); rst = 0;
        sw = 2'b01;
        press_up;
        press_up;
        press_up;
        repeat(5) @(posedge clk);
        if (ss == 3)
            $display("PASS: ss=%0d tras 3 btn_up (esperado 3)", ss);
        else
            $display("FAIL: ss=%0d (esperado 3)", ss);

        // ── Test 4: Edición de minutos con btn_down ──
        $display("[%0t] Test 4: Edición de mm con btn_down (sw=10)", $time);
        rst = 1; @(posedge clk); rst = 0;
        sw = 2'b10;
        // llevar mm a 59 primero
        repeat(59) begin press_up; end
        repeat(5) @(posedge clk);
        if (mm == 59)
            $display("INFO: mm=59 OK antes de rollover btn_up");
        press_up; // debería volver a 0
        repeat(5) @(posedge clk);
        if (mm == 0)
            $display("PASS: Rollover mm=59→0 con btn_up correcto");
        else
            $display("FAIL: mm=%0d (esperado 0)", mm);

        // ── Test 5: Edición de horas ──
        $display("[%0t] Test 5: Edición de hh (sw=11)", $time);
        rst = 1; @(posedge clk); rst = 0;
        sw = 2'b11;
        press_up;
        press_up;
        repeat(5) @(posedge clk);
        if (hh == 2)
            $display("PASS: hh=%0d tras 2 btn_up (esperado 2)", hh);
        else
            $display("FAIL: hh=%0d (esperado 2)", hh);

        press_down;
        repeat(5) @(posedge clk);
        if (hh == 1)
            $display("PASS: hh=%0d tras btn_down (esperado 1)", hh);
        else
            $display("FAIL: hh=%0d (esperado 1)", hh);

        $display("=== FIN TEST: control_hora_manual ===");
        $finish;
    end

endmodule
