`timescale 1ns / 1ps
// ============================================================
// Testbench: tb_vram
// Módulo bajo prueba: vram (BRAM doble puerto)
// Descripción: Verifica escritura por puerto A y lectura
//              por puerto B en diferentes direcciones.
// ============================================================

module tb_vram;

    // ── Entradas ──
    reg         clk;
    reg         we_a;
    reg  [18:0] addr_a;
    reg  [11:0] data_in;
    reg  [18:0] addr_b;

    // ── Salidas ──
    wire [11:0] data_out;

    // ── Instancia ──
    vram uut (
        .clk     (clk),
        .we_a    (we_a),
        .addr_a  (addr_a),
        .data_in (data_in),
        .addr_b  (addr_b),
        .data_out(data_out)
    );

    // ── Reloj 100 MHz ──
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Tarea: escribir en dirección ──
    task write_mem;
        input [18:0] addr;
        input [11:0] data;
        begin
            @(posedge clk);
            we_a    = 1;
            addr_a  = addr;
            data_in = data;
            @(posedge clk);
            we_a = 0;
        end
    endtask

    // ── Tarea: leer de dirección ──
    task read_mem;
        input [18:0] addr;
        begin
            addr_b = addr;
            @(posedge clk);
            @(posedge clk); // 1 ciclo de latencia BRAM
        end
    endtask

    // ── Estímulos ──
    initial begin
        $display("=== TEST: vram (BRAM doble puerto) ===");

        we_a    = 0;
        addr_a  = 0;
        data_in = 0;
        addr_b  = 0;
        repeat(5) @(posedge clk);

        // ── Test 1: Escribir y leer misma dirección ──
        $display("[%0t] Test 1: Escritura y lectura en addr=0", $time);
        write_mem(19'd0, 12'hFFF);
        read_mem(19'd0);
        if (data_out === 12'hFFF)
            $display("PASS: Lectura addr=0 → data=0xFFF");
        else
            $display("FAIL: Lectura addr=0 → data=0x%03X (esperado 0xFFF)", data_out);

        // ── Test 2: Dirección diferente ──
        $display("[%0t] Test 2: Escritura y lectura en addr=100", $time);
        write_mem(19'd100, 12'hA5C);
        read_mem(19'd100);
        if (data_out === 12'hA5C)
            $display("PASS: Lectura addr=100 → data=0xA5C");
        else
            $display("FAIL: Lectura addr=100 → data=0x%03X (esperado 0xA5C)", data_out);

        // ── Test 3: Última dirección válida (640*480-1 = 307199) ──
        $display("[%0t] Test 3: Escritura en addr=307199 (último píxel)", $time);
        write_mem(19'd307199, 12'h123);
        read_mem(19'd307199);
        if (data_out === 12'h123)
            $display("PASS: Lectura addr=307199 → data=0x123");
        else
            $display("FAIL: Lectura addr=307199 → data=0x%03X (esperado 0x123)", data_out);

        // ── Test 4: Sin write_enable no debe escribir ──
        $display("[%0t] Test 4: we_a=0 no debe sobreescribir", $time);
        read_mem(19'd0); // valor previo: 0xFFF
        we_a    = 0;
        addr_a  = 19'd0;
        data_in = 12'h000;
        @(posedge clk);
        read_mem(19'd0);
        if (data_out === 12'hFFF)
            $display("PASS: Dato preservado sin we_a");
        else
            $display("FAIL: Dato sobreescrito sin we_a (data=0x%03X)", data_out);

        // ── Test 5: Puertos A y B independientes ──
        $display("[%0t] Test 5: Escritura en addr=50, lectura en addr=100 simultáneo", $time);
        write_mem(19'd50, 12'hBBB);
        addr_b = 19'd100;
        @(posedge clk);
        @(posedge clk);
        if (data_out === 12'hA5C)
            $display("PASS: Puerto B lee addr=100 independientemente");
        else
            $display("FAIL: Puerto B interferido (data=0x%03X)", data_out);

        $display("=== FIN TEST: vram ===");
        $finish;
    end

endmodule
