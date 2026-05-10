`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2026 02:26:09 PM
// Design Name: 
// Module Name: font_rom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Se encarga de almacenar como se ven los numeros
// esto debido a que su forma no cambia por lo cual es mejor 
// mantenerlos fijos en un solo bloque encargado de 
// saber su forma para nada mas ser consultados

module font_rom (
    input  wire [7:0] addr,  // {dígito[3:0], fila[3:0]}
    output reg  [7:0] data   // 8 píxeles de esa fila
);

    always @(*) begin
        case (addr)
            
            
            //Ej: 8'h03 
            // En este caso el primer digito hex significa el numero (0)
            // el segundo digito represetan la fila a consultar (fila 3)
            
            // Dígito 0 
            8'h00: data = 8'b00111100;
            8'h01: data = 8'b01100110;
            8'h02: data = 8'b01100110;
            8'h03: data = 8'b01100110;
            8'h04: data = 8'b01100110;
            8'h05: data = 8'b01100110;
            8'h06: data = 8'b01100110;
            8'h07: data = 8'b01100110;
            8'h08: data = 8'b01100110;
            8'h09: data = 8'b01100110;
            8'h0A: data = 8'b01100110;
            8'h0B: data = 8'b01100110;
            8'h0C: data = 8'b01100110;
            8'h0D: data = 8'b01100110;
            8'h0E: data = 8'b01111110;
            8'h0F: data = 8'b00111100;

            // Dígito 1 
            8'h10: data = 8'b00011000;
            8'h11: data = 8'b00111000;
            8'h12: data = 8'b01111000;
            8'h13: data = 8'b00011000;
            8'h14: data = 8'b00011000;
            8'h15: data = 8'b00011000;
            8'h16: data = 8'b00011000;
            8'h17: data = 8'b00011000;
            8'h18: data = 8'b00011000;
            8'h19: data = 8'b00011000;
            8'h1A: data = 8'b00011000;
            8'h1B: data = 8'b00011000;
            8'h1C: data = 8'b00011000;
            8'h1D: data = 8'b00011000;
            8'h1E: data = 8'b01111110;
            8'h1F: data = 8'b01111110;

            // Dígito 2 
            8'h20: data = 8'b00111100;
            8'h21: data = 8'b01100110;
            8'h22: data = 8'b00000110;
            8'h23: data = 8'b00000110;
            8'h24: data = 8'b00000110;
            8'h25: data = 8'b00001100;
            8'h26: data = 8'b00011000;
            8'h27: data = 8'b00110000;
            8'h28: data = 8'b01100000;
            8'h29: data = 8'b01100000;
            8'h2A: data = 8'b01100000;
            8'h2B: data = 8'b01100000;
            8'h2C: data = 8'b01100110;
            8'h2D: data = 8'b01100110;
            8'h2E: data = 8'b01111110;
            8'h2F: data = 8'b01111110;

            // Dígito 3 
            8'h30: data = 8'b00111100;
            8'h31: data = 8'b01100110;
            8'h32: data = 8'b00000110;
            8'h33: data = 8'b00000110;
            8'h34: data = 8'b00000110;
            8'h35: data = 8'b00011100;
            8'h36: data = 8'b00000110;
            8'h37: data = 8'b00000110;
            8'h38: data = 8'b00000110;
            8'h39: data = 8'b00000110;
            8'h3A: data = 8'b00000110;
            8'h3B: data = 8'b00000110;
            8'h3C: data = 8'b01100110;
            8'h3D: data = 8'b01100110;
            8'h3E: data = 8'b00111100;
            8'h3F: data = 8'b00000000;

            // Dígito 4 
            8'h40: data = 8'b00001100;
            8'h41: data = 8'b00011100;
            8'h42: data = 8'b00111100;
            8'h43: data = 8'b01101100;
            8'h44: data = 8'b01101100;
            8'h45: data = 8'b11001100;
            8'h46: data = 8'b11001100;
            8'h47: data = 8'b11111110;
            8'h48: data = 8'b00001100;
            8'h49: data = 8'b00001100;
            8'h4A: data = 8'b00001100;
            8'h4B: data = 8'b00001100;
            8'h4C: data = 8'b00001100;
            8'h4D: data = 8'b00001100;
            8'h4E: data = 8'b00001100;
            8'h4F: data = 8'b00000000;

            // Dígito 5 
            8'h50: data = 8'b01111110;
            8'h51: data = 8'b01100000;
            8'h52: data = 8'b01100000;
            8'h53: data = 8'b01100000;
            8'h54: data = 8'b01100000;
            8'h55: data = 8'b01111100;
            8'h56: data = 8'b00000110;
            8'h57: data = 8'b00000110;
            8'h58: data = 8'b00000110;
            8'h59: data = 8'b00000110;
            8'h5A: data = 8'b00000110;
            8'h5B: data = 8'b00000110;
            8'h5C: data = 8'b01100110;
            8'h5D: data = 8'b01100110;
            8'h5E: data = 8'b00111100;
            8'h5F: data = 8'b00000000;

            // Dígito 6 
            8'h60: data = 8'b00111100;
            8'h61: data = 8'b01100110;
            8'h62: data = 8'b01100000;
            8'h63: data = 8'b01100000;
            8'h64: data = 8'b01100000;
            8'h65: data = 8'b01111100;
            8'h66: data = 8'b01100110;
            8'h67: data = 8'b01100110;
            8'h68: data = 8'b01100110;
            8'h69: data = 8'b01100110;
            8'h6A: data = 8'b01100110;
            8'h6B: data = 8'b01100110;
            8'h6C: data = 8'b01100110;
            8'h6D: data = 8'b01100110;
            8'h6E: data = 8'b00111100;
            8'h6F: data = 8'b00000000;

            // Dígito 7 
            8'h70: data = 8'b01111110;
            8'h71: data = 8'b01100110;
            8'h72: data = 8'b00000110;
            8'h73: data = 8'b00000110;
            8'h74: data = 8'b00001100;
            8'h75: data = 8'b00001100;
            8'h76: data = 8'b00011000;
            8'h77: data = 8'b00011000;
            8'h78: data = 8'b00110000;
            8'h79: data = 8'b00110000;
            8'h7A: data = 8'b00110000;
            8'h7B: data = 8'b00110000;
            8'h7C: data = 8'b00110000;
            8'h7D: data = 8'b00110000;
            8'h7E: data = 8'b00110000;
            8'h7F: data = 8'b00000000;

            // Dígito 8 
            8'h80: data = 8'b00111100;
            8'h81: data = 8'b01100110;
            8'h82: data = 8'b01100110;
            8'h83: data = 8'b01100110;
            8'h84: data = 8'b01100110;
            8'h85: data = 8'b00111100;
            8'h86: data = 8'b01100110;
            8'h87: data = 8'b01100110;
            8'h88: data = 8'b01100110;
            8'h89: data = 8'b01100110;
            8'h8A: data = 8'b01100110;
            8'h8B: data = 8'b01100110;
            8'h8C: data = 8'b01100110;
            8'h8D: data = 8'b01100110;
            8'h8E: data = 8'b00111100;
            8'h8F: data = 8'b00000000;

            // Dígito 9 
            8'h90: data = 8'b00111100;
            8'h91: data = 8'b01100110;
            8'h92: data = 8'b01100110;
            8'h93: data = 8'b01100110;
            8'h94: data = 8'b01100110;
            8'h95: data = 8'b00111110;
            8'h96: data = 8'b00000110;
            8'h97: data = 8'b00000110;
            8'h98: data = 8'b00000110;
            8'h99: data = 8'b00000110;
            8'h9A: data = 8'b00000110;
            8'h9B: data = 8'b00000110;
            8'h9C: data = 8'b01100110;
            8'h9D: data = 8'b01100110;
            8'h9E: data = 8'b00111100;
            8'h9F: data = 8'b00000000;

            // Dos puntos : 
            8'hA0: data = 8'b00000000;
            8'hA1: data = 8'b00000000;
            8'hA2: data = 8'b00000000;
            8'hA3: data = 8'b00011000;
            8'hA4: data = 8'b00011000;
            8'hA5: data = 8'b00000000;
            8'hA6: data = 8'b00000000;
            8'hA7: data = 8'b00000000;
            8'hA8: data = 8'b00000000;
            8'hA9: data = 8'b00000000;
            8'hAA: data = 8'b00011000;
            8'hAB: data = 8'b00011000;
            8'hAC: data = 8'b00000000;
            8'hAD: data = 8'b00000000;
            8'hAE: data = 8'b00000000;
            8'hAF: data = 8'b00000000;

            // Cualquier otra dirección 
            default: data = 8'b00000000;

        endcase
    end

endmodule
