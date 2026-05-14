#!/bin/bash
# ============================================================
# Script: run_tests.sh
# Descripción: Ejecuta todos los scripts de testbench
#              del proyecto VGA Digital Clock.
#              Llama a cada script individual y consolida
#              el reporte final de PASS/FAIL.
# Uso: cd sim/ && ./run_tests.sh
# ============================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
TOTAL=0

SCRIPT_DIR="$(dirname "$0")"

echo "=============================================="
echo " Ejecutando testbenches - VGA Digital Clock"
echo "=============================================="
echo ""

run_script() {
    local script=$1
    local name=$(basename "$script" .sh | sed 's/run_//')

    echo -n "► $name ... "

    output=$(bash "$script" 2>&1)
    exit_code=$?

    passes=$(echo "$output" | grep -c "^PASS")
    fails=$(echo "$output" | grep -c "^FAIL")

    if [ $exit_code -eq 0 ] && [ "$fails" -eq 0 ] && [ "$passes" -gt 0 ]; then
        echo -e "${GREEN}PASS ($passes checks)${NC}"
        PASS=$((PASS + 1))
    elif [ "$fails" -gt 0 ] || [ $exit_code -ne 0 ]; then
        echo -e "${RED}FAIL ($fails fallos, $passes OK)${NC}"
        echo "$output" | grep "^FAIL\|ERROR" | sed 's/^/  /'
        FAIL=$((FAIL + 1))
    else
        echo -e "${YELLOW}INFO (sin assertions)${NC}"
        PASS=$((PASS + 1))
    fi

    TOTAL=$((TOTAL + 1))
}

echo "── Etapa 1: Módulos base ──────────────────────"
run_script "$SCRIPT_DIR/run_tb_clock_divider.sh"
run_script "$SCRIPT_DIR/run_tb_clk_25MHz.sh"
run_script "$SCRIPT_DIR/run_tb_debouncer.sh"
run_script "$SCRIPT_DIR/run_tb_control_hora_manual.sh"
run_script "$SCRIPT_DIR/run_tb_vga_sync.sh"
run_script "$SCRIPT_DIR/run_tb_vram.sh"
run_script "$SCRIPT_DIR/run_tb_font_rom.sh"
run_script "$SCRIPT_DIR/run_tb_display_7seg.sh"

echo ""
echo "── Etapa 2: Sistema funcional VGA ────────────"
run_script "$SCRIPT_DIR/run_tb_img_gen.sh"
run_script "$SCRIPT_DIR/run_tb_top_reloj.sh"

echo ""
echo "=============================================="
echo " RESUMEN"
echo "=============================================="
echo -e " Total:  $TOTAL"
echo -e " ${GREEN}PASS:   $PASS${NC}"
echo -e " ${RED}FAIL:   $FAIL${NC}"
echo "=============================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
else
    exit 0
fi
