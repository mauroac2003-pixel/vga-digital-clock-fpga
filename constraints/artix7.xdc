## This file is a general .xdc for the Nexys A7-100T

## Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports {clk}];
create_clock -add -name clk -period 10.00 -waveform {0 5} [get_ports {clk}];

## Switches
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports {rst_sw}]; #sw[0]
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports {sw[0]}];  #sw[1]
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports {sw[1]}];  #sw[2]

## Buttons
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports {btn_up}];
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports {btn_down}];

## 7 segment display
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]; #ca
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]; #cb
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]; #cc
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]; #cd
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]; #ce
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]; #cf
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]; #cg
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports {seg[7]}]; #dp
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports {an[0]}];
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports {an[1]}];
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports {an[2]}];
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports {an[3]}];
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports {an[4]}];
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports {an[5]}];
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports {an[6]}];
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports {an[7]}];

## VGA - Sincronización
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports {hsync}];
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports {vsync}];

## VGA - Canal Rojo
set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports {vga_r[0]}];
set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports {vga_r[1]}];
set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports {vga_r[2]}];
set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports {vga_r[3]}];

## VGA - Canal Verde
set_property -dict { PACKAGE_PIN C6    IOSTANDARD LVCMOS33 } [get_ports {vga_g[0]}];
set_property -dict { PACKAGE_PIN A5    IOSTANDARD LVCMOS33 } [get_ports {vga_g[1]}];
set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports {vga_g[2]}];
set_property -dict { PACKAGE_PIN A6    IOSTANDARD LVCMOS33 } [get_ports {vga_g[3]}];

## VGA - Canal Azul
set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports {vga_b[0]}];
set_property -dict { PACKAGE_PIN C7    IOSTANDARD LVCMOS33 } [get_ports {vga_b[1]}];
set_property -dict { PACKAGE_PIN D7    IOSTANDARD LVCMOS33 } [get_ports {vga_b[2]}];
set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS33 } [get_ports {vga_b[3]}];
