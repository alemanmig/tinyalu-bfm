###############################################################################
# Makefile — TinyALU BFM Testbench  |  Cadence Xcelium
#
# Flujo: xmvhdl (compile VHDL) → xmvlog (compile SV) → xmelab → xmsim
# Alternativa rápida: target "xrun" usa el compilador todo-en-uno.
#
# Uso:
#   make          → compila + elabora + simula (flujo paso a paso)
#   make xrun     → flujo todo-en-uno con xrun
#   make waves    → abre SimVision con las formas de onda grabadas
#   make cov      → genera reporte de cobertura
#   make clean    → borra artefactos generados
###############################################################################

# ---------------------------------------------------------------------------
# Herramientas Xcelium
# ---------------------------------------------------------------------------
XMVHDL  := xmvhdl
XMVLOG  := xmvlog
XMELAB  := xmelab
XMSIM   := xmsim
XRUN    := xrun

# ---------------------------------------------------------------------------
# Directorios
# ---------------------------------------------------------------------------
DUT_DIR := tinyalu_dut
WORK    := xcelium.d        # directorio de work library generado por Xcelium
WAVES   := dump.shm

# ---------------------------------------------------------------------------
# Archivos VHDL del DUT  (orden de compilación: sub-bloques antes del top)
# ---------------------------------------------------------------------------
VHDL_SRCS := \
    $(DUT_DIR)/single_cycle_add_and_xor.vhd \
    $(DUT_DIR)/three_cycle_mult.vhd \
    $(DUT_DIR)/tinyalu.vhd

# ---------------------------------------------------------------------------
# Archivos SystemVerilog del testbench
# ---------------------------------------------------------------------------
SV_SRCS := \
    tinyalu_pkg.sv \
    tinyalu_bfm.sv \
    scoreboard.sv  \
    coverage.sv    \
    tester.sv      \
    top.sv

# ---------------------------------------------------------------------------
# Módulo/entidad top para elaboración y simulación
# ---------------------------------------------------------------------------
TOP := top

# ---------------------------------------------------------------------------
# Opciones de compilación
# ---------------------------------------------------------------------------
XMVHDL_OPTS := -v93 -work worklib
XMVLOG_OPTS := -sv -work worklib
XMELAB_OPTS := -access +rwc -timescale 1ns/1ps -work worklib
XMSIM_OPTS  := -input run.do

# Opciones extra para cobertura (descomentar si se desea cobertura)
# COV_OPTS    := -coverage all -covfile covfile.tcl

# Opciones todo-en-uno para xrun
XRUN_OPTS := \
    -v93                     \
    -sv                      \
    -timescale 1ns/1ps       \
    -access +rwc             \
    -top $(TOP)              \
    -input run.do

# ---------------------------------------------------------------------------
# Target por defecto: flujo paso a paso
# ---------------------------------------------------------------------------
.PHONY: all compile_vhdl compile_sv elab sim xrun waves cov clean help

all: sim

## 1. Compilar VHDL
compile_vhdl: $(VHDL_SRCS)
	@echo ">>> Compilando VHDL..."
	$(XMVHDL) $(XMVHDL_OPTS) $(VHDL_SRCS)

## 2. Compilar SystemVerilog
compile_sv: compile_vhdl $(SV_SRCS)
	@echo ">>> Compilando SystemVerilog..."
	$(XMVLOG) $(XMVLOG_OPTS) $(SV_SRCS)

## 3. Elaborar
elab: compile_sv
	@echo ">>> Elaborando..."
	$(XMELAB) $(XMELAB_OPTS) $(TOP)

## 4. Simular
sim: elab
	@echo ">>> Simulando..."
	$(XMSIM) $(XMSIM_OPTS) worklib.$(TOP)

# ---------------------------------------------------------------------------
# Flujo todo-en-uno con xrun (más rápido para desarrollo)
# ---------------------------------------------------------------------------
xrun:
	@echo ">>> Ejecutando xrun (todo-en-uno)..."
	$(XRUN) $(XRUN_OPTS) \
	    $(VHDL_SRCS)     \
	    $(SV_SRCS)

# ---------------------------------------------------------------------------
# Abrir formas de onda en SimVision
# ---------------------------------------------------------------------------
waves:
	@echo ">>> Abriendo SimVision..."
	simvision $(WAVES) &

# ---------------------------------------------------------------------------
# Reporte de cobertura con IMC
# ---------------------------------------------------------------------------
cov:
	@echo ">>> Generando reporte de cobertura..."
	imc -load cov_work/scope/worklib -execcmd \
	    "report -summary -detail -out coverage_report.txt; exit"

# ---------------------------------------------------------------------------
# Limpieza
# ---------------------------------------------------------------------------
clean:
	@echo ">>> Limpiando artefactos..."
	rm -rf $(WORK) $(WAVES) *.log *.key *.diag \
	       cov_work coverage_report.txt xrun.history \
	       .simvision *.shm *.dsn *.trn

# ---------------------------------------------------------------------------
# Ayuda
# ---------------------------------------------------------------------------
help:
	@echo ""
	@echo "  Targets disponibles:"
	@echo "    make          → compile VHDL → compile SV → elab → sim"
	@echo "    make xrun     → flujo todo-en-uno (xrun)"
	@echo "    make waves    → abre SimVision con dump.shm"
	@echo "    make cov      → genera reporte de cobertura (IMC)"
	@echo "    make clean    → borra todos los artefactos"
	@echo ""
