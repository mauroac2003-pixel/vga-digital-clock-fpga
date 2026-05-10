`timescale 1ns / 1ps

module tb_vga_sync;

    reg clk;
    reg rst;
    reg clk_25_en;

    wire [9:0] hcount;
    wire [9:0] vcount;
    wire       hsync;
    wire       vsync;
    wire       video_en;

    vga_sync uut (
        .clk      (clk),
        .rst      (rst),
        .clk_25_en(clk_25_en),
        .hcount   (hcount),
        .vcount   (vcount),
        .hsync    (hsync),
        .vsync    (vsync),
        .video_en (video_en)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Generador de clk_25_en: pulso cada 4 ciclos
    integer cnt_25;
    initial begin cnt_25 = 0; clk_25_en = 0; end
    always @(posedge clk) begin
        if (rst) begin
            cnt_25    <= 0;
            clk_25_en <= 0;
        end else begin
            if (cnt_25 == 3) begin
                cnt_25    <= 0;
                clk_25_en <= 1;
            end else begin
                cnt_25    <= cnt_25 + 1;
                clk_25_en <= 0;
            end
        end
    end

    // Variables
    integer hsync_fail;
    integer vsync_fail;
    integer h;
    integer v;

    initial begin
        $display("=== TEST: vga_sync ===");

        rst       = 1;
        hsync_fail = 0;
        vsync_fail = 0;
        repeat(10) @(posedge clk);
        rst = 0;
        $display("[%0t] Reset liberado", $time);

        // Esperar 2 frames completos para estabilizar
        repeat(800 * 525 * 4 * 2) @(posedge clk);

        // Test 1: video_en en zona visible
        wait(hcount == 10 && vcount == 10);
        @(posedge clk);
        if (video_en === 1'b1)
            $display("PASS: video_en=1 en zona visible (hcount=%0d vcount=%0d)", hcount, vcount);
        else
            $display("FAIL: video_en=0 en zona visible");

        // Test 2: video_en fuera de zona visible
        wait(hcount == 700);
        @(posedge clk);
        if (video_en === 1'b0)
            $display("PASS: video_en=0 fuera de zona visible (hcount=%0d)", hcount);
        else
            $display("FAIL: video_en=1 fuera de zona visible");

        // Test 3: hsync baja en zona correcta (656..751)
        wait(hcount >= 656 && hcount < 752);
        repeat(2) @(posedge clk);
        if (hsync === 1'b0)
            $display("PASS: hsync=0 en zona de sync (hcount=%0d)", hcount);
        else
            $display("FAIL: hsync=%b en zona de sync (hcount=%0d)", hsync, hcount);

        // Test 4: hsync sube fuera de zona sync
        wait(hcount < 656);
        @(posedge clk);
        if (hsync === 1'b1)
            $display("PASS: hsync=1 fuera de zona sync (hcount=%0d)", hcount);
        else
            $display("FAIL: hsync=%b fuera de zona sync", hsync);

        // Test 5: vsync baja en zona correcta (490..491)
        wait(vcount == 491);
        repeat(2) @(posedge clk);
        if (vsync === 1'b0)
            $display("PASS: vsync=0 en zona de sync vertical (vcount=%0d)", vcount);
        else
            $display("FAIL: vsync=%b en zona sync vertical (vcount=%0d)", vsync, vcount);

        // Test 6: Reset
        rst = 1;
        repeat(5) @(posedge clk);
        if (hcount === 0 && vcount === 0)
            $display("PASS: Reset pone hcount=0 vcount=0");
        else
            $display("FAIL: hcount=%0d vcount=%0d tras reset", hcount, vcount);

        $display("=== FIN TEST: vga_sync ===");
        $finish;
    end

endmodule
