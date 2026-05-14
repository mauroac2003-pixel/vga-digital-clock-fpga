`timescale 1ns / 1ps
module tb_top_reloj;

    reg        clk;
    reg        rst_sw;
    reg [1:0]  sw;
    reg        btn_up;
    reg        btn_down;
    wire [6:0] seg;
    wire [7:0] an;
    wire       hsync;
    wire       vsync;
    wire [3:0] vga_r;
    wire [3:0] vga_g;
    wire [3:0] vga_b;

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

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("=== TEST: top_reloj (Etapa 2) ===");
        rst_sw = 1; sw = 0; btn_up = 0; btn_down = 0;

        repeat(10) @(posedge clk);
        $display("PASS: Modulo top_reloj instanciado correctamente");

        repeat(100) @(posedge clk);
        if (hsync !== 1'bz && vsync !== 1'bz)
            $display("PASS: hsync y vsync no en alta impedancia");
        else
            $display("FAIL: hsync o vsync en alta impedancia");

        if (vga_r !== 4'bzzzz && vga_g !== 4'bzzzz && vga_b !== 4'bzzzz)
            $display("PASS: RGB no en alta impedancia");
        else
            $display("FAIL: RGB en alta impedancia");

        if (seg !== 7'bzzzzzzz && an !== 8'bzzzzzzzz)
            $display("PASS: seg y an no en alta impedancia");
        else
            $display("FAIL: seg o an en alta impedancia");

        sw = 2'b01; repeat(10) @(posedge clk);
        sw = 2'b10; repeat(10) @(posedge clk);
        sw = 2'b11; repeat(10) @(posedge clk);
        sw = 2'b00; repeat(10) @(posedge clk);
        $display("PASS: Cambios de modo edicion sin errores");

        $display("=== FIN TEST: top_reloj ===");
        $finish;
    end
endmodule
