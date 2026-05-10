`timescale 1ns / 1ps

module tb_clock_divider;

    reg  clk;
    reg  rst;
    wire clk_1hz;

    // Wrapper interno con contador reducido
    reg [4:0] counter_sim;
    reg       clk_1hz_reg;

    assign clk_1hz = clk_1hz_reg;

    initial clk = 0;
    always #5 clk = ~clk;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_sim  <= 0;
            clk_1hz_reg  <= 0;
        end else begin
            if (counter_sim == 4) begin
                clk_1hz_reg <= ~clk_1hz_reg;
                counter_sim <= 0;
            end else begin
                counter_sim <= counter_sim + 1;
            end
        end
    end

    real last_rise_time;
    real period_ns;

    initial begin
        $display("=== TEST: clock_divider ===");
        rst = 1;
        repeat(5) @(posedge clk);
        rst = 0;

        @(posedge clk_1hz);
        last_rise_time = $time;

        @(posedge clk_1hz);
        period_ns = $time - last_rise_time;
        $display("[%0t] Periodo medido: %0.0f ns", $time, period_ns);

        if (period_ns == 100.0)
            $display("PASS: Periodo de clk_1hz correcto");
        else
            $display("FAIL: Periodo incorrecto. Obtenido=%0.0f ns", period_ns);

        rst = 1;
        @(posedge clk); @(posedge clk);
        if (clk_1hz === 1'b0)
            $display("PASS: Reset pone clk_1hz en 0");
        else
            $display("FAIL: clk_1hz deberia ser 0 tras reset");

        $display("=== FIN TEST: clock_divider ===");
        $finish;
    end

endmodule
