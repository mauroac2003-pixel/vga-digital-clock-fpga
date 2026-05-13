#!/bin/bash
# ============================================================
# Script: run_tb_img_gen.sh
# Descripción: Compila y ejecuta el testbench de ../sim/tb_img_gen
# Uso: cd sim/ && ./run_tb_img_gen.sh
# ============================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
RTL_DIR="$(dirname "$0")/../rtl"
OUT_DIR="$(dirname "$0")/../sim/out"
mkdir -p "$OUT_DIR"

TB_NAME="tb_img_gen"
echo "=============================================="
echo " Test: $TB_NAME"
echo "=============================================="

iverilog -o "$OUT_DIR/${TB_NAME}.out" \
         $RTL_DIR/font_rom.v $RTL_DIR/img_gen.v \
         "$(dirname "$0")/../sim/tb_img_gen.v" 2>"$OUT_DIR/${TB_NAME}_compile.log"

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR DE COMPILACIÓN${NC}"
    cat "$OUT_DIR/${TB_NAME}_compile.log"
    exit 1
fi

vvp "$OUT_DIR/${TB_NAME}.out" | tee "$OUT_DIR/${TB_NAME}_result.log"

passes=$(grep -c "^PASS" "$OUT_DIR/${TB_NAME}_result.log")
fails=$(grep -c "^FAIL" "$OUT_DIR/${TB_NAME}_result.log")

echo "=============================================="
if [ "$fails" -eq 0 ] && [ "$passes" -gt 0 ]; then
    echo -e " ${GREEN}PASS ($passes checks)${NC}"
    exit 0
elif [ "$fails" -gt 0 ]; then
    echo -e " ${RED}FAIL ($fails fallos, $passes OK)${NC}"
    exit 1
else
    echo -e " INFO (sin assertions)"
    exit 0
fi
echo "=============================================="
