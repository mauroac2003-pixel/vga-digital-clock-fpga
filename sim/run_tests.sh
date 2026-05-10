#!/bin/bash
# ============================================================
# Script: run_tests.sh
# Descripción: Compila y ejecuta todos los testbenches del
#              proyecto usando Icarus Verilog (iverilog).
#              Reporta PASS/FAIL por módulo.
# Uso: ./run_tests.sh
# ============================================================

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sin color

# Directorios
RTL_DIR="../rtl"
TB_DIR="."
OUT_DIR="./out"

mkdir -p "$OUT_DIR"

# Contador de resultados
PASS=0
FAIL=0
TOTAL=0

echo "=============================================="
echo " Ejecutando testbenches - VGA Digital Clock"
echo "=============================================="
echo ""

# ── Función para correr un testbench ──
run_tb() {
    local tb_file="$1"
    local rtl_files="$2"
    local tb_name=$(basename "$tb_file" .v)

    echo -n "► $tb_name ... "

    # Compilar
    iverilog -o "$OUT_DIR/${tb_name}.out" \
             $rtl_files \
             "$tb_file" 2>"$OUT_DIR/${tb_name}_compile.log"

    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR DE COMPILACIÓN${NC}"
        echo "  Ver: $OUT_DIR/${tb_name}_compile.log"
        FAIL=$((FAIL + 1))
        TOTAL=$((TOTAL + 1))
        return
    fi

    # Ejecutar y capturar salida
    vvp "$OUT_DIR/${tb_name}.out" > "$OUT_DIR/${tb_name}_result.log" 2>&1

    # Contar PASS y FAIL en la salida
    local passes=$(grep -c "^PASS" "$OUT_DIR/${tb_name}_result.log")
    local fails=$(grep -c "^FAIL" "$OUT_DIR/${tb_name}_result.log")

    if [ "$fails" -eq 0 ] && [ "$passes" -gt 0 ]; then
        echo -e "${GREEN}PASS ($passes checks)${NC}"
        PASS=$((PASS + 1))
    elif [ "$fails" -gt 0 ]; then
        echo -e "${RED}FAIL ($fails fallos, $passes OK)${NC}"
        grep "^FAIL" "$OUT_DIR/${tb_name}_result.log" | sed 's/^/  /'
        FAIL=$((FAIL + 1))
    else
        echo -e "${YELLOW}INFO (sin assertions PASS/FAIL)${NC}"
        PASS=$((PASS + 1))
    fi

    TOTAL=$((TOTAL + 1))
}

# ── Ejecutar cada testbench ──

run_tb "$TB_DIR/tb_clock_divider.v" \
       "$RTL_DIR/clock_divider.v"

run_tb "$TB_DIR/tb_clk_25MHz.v" \
       "$RTL_DIR/clk_25MHz.v"

run_tb "$TB_DIR/tb_debouncer.v" \
       "$RTL_DIR/debouncer.v"

run_tb "$TB_DIR/tb_control_hora_manual.v" \
       "$RTL_DIR/control_hora_manual.v"

run_tb "$TB_DIR/tb_vga_sync.v" \
       "$RTL_DIR/vga_sync.v"

run_tb "$TB_DIR/tb_vram.v" \
       "$RTL_DIR/BRAM.v"

run_tb "$TB_DIR/tb_font_rom.v" \
       "$RTL_DIR/font_rom.v"

run_tb "$TB_DIR/tb_display_7seg.v" \
       "$RTL_DIR/display_7seg.v"

# ── Resumen ──
echo ""
echo "=============================================="
echo " RESUMEN"
echo "=============================================="
echo -e " Total:  $TOTAL"
echo -e " ${GREEN}PASS:   $PASS${NC}"
echo -e " ${RED}FAIL:   $FAIL${NC}"
echo "=============================================="

# Retornar código de error si hubo fallos
if [ "$FAIL" -gt 0 ]; then
    exit 1
else
    exit 0
fi
