module control_hora_manual (
    input clk,
    input clk_1hz,
    input rst,

    input [1:0] sw,
    input btn_up,
    input btn_down,

    output reg [4:0] hh,
    output reg [5:0] mm,
    output reg [5:0] ss
);

// flancos
reg btn_up_d, btn_down_d;

always @(posedge clk) begin
    btn_up_d   <= btn_up;
    btn_down_d <= btn_down;
end

wire up_pulse   = btn_up & ~btn_up_d;
wire down_pulse = btn_down & ~btn_down_d;

// sincronizar 1Hz
reg clk_1hz_d;

always @(posedge clk) begin
    clk_1hz_d <= clk_1hz;
end

wire tick_1hz = clk_1hz & ~clk_1hz_d;

// ----------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        hh <= 0;
        mm <= 0;
        ss <= 0;
    end else begin

        // ----------------------
        // MODO AUTOMÁTICO
        // ----------------------
        if (sw == 2'b00 && tick_1hz) begin
            if (ss == 59) begin
                ss <= 0;

                if (mm == 59) begin
                    mm <= 0;

                    if (hh == 23)
                        hh <= 0;
                    else
                        hh <= hh + 1;

                end else begin
                    mm <= mm + 1;
                end

            end else begin
                ss <= ss + 1;
            end
        end

        // ----------------------
        // MODO EDICIÓN
        // ----------------------
        case (sw)

            2'b01: begin // segundos
                if (up_pulse)   ss <= (ss == 59) ? 0  : ss + 1;
                if (down_pulse) ss <= (ss == 0)  ? 59 : ss - 1;
            end

            2'b10: begin // minutos
                if (up_pulse)   mm <= (mm == 59) ? 0  : mm + 1;
                if (down_pulse) mm <= (mm == 0)  ? 59 : mm - 1;
            end

            2'b11: begin // horas
                if (up_pulse)   hh <= (hh == 23) ? 0  : hh + 1;
                if (down_pulse) hh <= (hh == 0)  ? 23 : hh - 1;
            end

        endcase
    end
end

endmodule