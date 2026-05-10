`timescale 1ns / 1ps

module display_7seg (
    input clk,
    input rst,

    input [4:0] hh,
    input [5:0] mm,
    input [5:0] ss,

    input [1:0] sw,
    input blink,

    output reg [6:0] seg,
    output reg [7:0] an
);

// ----------------------
// BCD
// ----------------------
wire [3:0] hh_t = hh / 10;
wire [3:0] hh_u = hh % 10;
wire [3:0] mm_t = mm / 10;
wire [3:0] mm_u = mm % 10;
wire [3:0] ss_t = ss / 10;
wire [3:0] ss_u = ss % 10;

// ----------------------
// multiplex
// ----------------------
reg [16:0] refresh;

always @(posedge clk or posedge rst) begin
    if (rst) refresh <= 0;
    else refresh <= refresh + 1;
end

wire [2:0] sel = refresh[16:14];

reg [3:0] digit;
reg [7:0] an_temp;

// ----------------------
// selección + parpadeo
// ----------------------
always @(*) begin
    case (sel)

        // SEGUNDOS
        3'b000: begin
            digit = ss_u;
            an_temp = (sw == 2'b01 && !blink) ? 8'b11111111 : 8'b11111110;
        end

        3'b001: begin
            digit = ss_t;
            an_temp = (sw == 2'b01 && !blink) ? 8'b11111111 : 8'b11111101;
        end

        // MINUTOS
        3'b010: begin
            digit = mm_u;
            an_temp = (sw == 2'b10 && !blink) ? 8'b11111111 : 8'b11111011;
        end

        3'b011: begin
            digit = mm_t;
            an_temp = (sw == 2'b10 && !blink) ? 8'b11111111 : 8'b11110111;
        end

        // HORAS
        3'b100: begin
            digit = hh_u;
            an_temp = (sw == 2'b11 && !blink) ? 8'b11111111 : 8'b11101111;
        end

        3'b101: begin
            digit = hh_t;
            an_temp = (sw == 2'b11 && !blink) ? 8'b11111111 : 8'b11011111;
        end

        default: begin
            digit = 0;
            an_temp = 8'b11111111;
        end
    endcase
end

// ----------------------
// decoder
// ----------------------
always @(*) begin
    case (digit)
        0: seg = 7'b1000000;
        1: seg = 7'b1111001;
        2: seg = 7'b0100100;
        3: seg = 7'b0110000;
        4: seg = 7'b0011001;
        5: seg = 7'b0010010;
        6: seg = 7'b0000010;
        7: seg = 7'b1111000;
        8: seg = 7'b0000000;
        9: seg = 7'b0010000;
        default: seg = 7'b1111111;
    endcase
end

always @(*) begin
    an = an_temp;
end

endmodule