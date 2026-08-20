###############################################################################
# Makefile — TinyALU BFM Testbench  |  Cadence Xcelium
#
# Flujo: setup → xmvhdl → xmvlog → xmelab → xmsim
# Alternativa rápida: target "xrun" usa el compilador todo-en-uno.
#
# Uso:
#   make          → setup + compila + elabora + simula
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
# Directorios y bibliotecas
# ---------------------------------------------------------------------------
DUT_DIR  := tinyalu_dut
# IMPORTANTE: no poner comentarios inline en WORKLIB; Make los incluye en el valor
WORKLIB  := worklib
# strip() elimina espacios accidentales al usar la variable
W        := $(strip $(WORKLIB))
WORKDIR  := $(W)
WAVES    := dump.shm

# ---------------------------------------------------------------------------
# Archivos de configuración de Cadence
# ---------------------------------------------------------------------------
CDSLIB   := cds.lib
HDLVAR   := hdl.var

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
CDSLIB_OPT  := -cdslib $(CDSLIB)
HDLVAR_OPT  := -hdlvar $(HDLVAR)

XMVHDL_OPTS := -v93 -work $(W) $(CDSLIB_OPT) $(HDLVAR_OPT)
XMVLOG_OPTS := -sv   -work $(W) $(CDSLIB_OPT) $(HDLVAR_OPT)
XMELAB_OPTS     := -access +rwc -timescale 1ns/1ps -work $(W) \
                   $(CDSLIB_OPT) $(HDLVAR_OPT)
XMELAB_COV_OPTS := -access +rwc -timescale 1ns/1ps -work $(W) \
                   -coverage all \
                   $(CDSLIB_OPT) $(HDLVAR_OPT)

XMSIM_OPTS      := -input run.do $(CDSLIB_OPT) $(HDLVAR_OPT)
XMSIM_COV_OPTS  := -input run.do -covworkdir ./cov_work \
                   $(CDSLIB_OPT) $(HDLVAR_OPT)

# Directorio de cobertura
COV_WORK := cov_work

# Opciones todo-en-uno para xrun
XRUN_OPTS := \
    -v93                     \
    -sv                      \
    -timescale 1ns/1ps       \
    -access +rwc             \
    -top $(TOP)     \
    -input run.do

# ---------------------------------------------------------------------------
# Target por defecto: flujo paso a paso
# ---------------------------------------------------------------------------
.PHONY: all setup compile_vhdl compile_sv elab sim elab_cov sim_cov xrun waves cov clean help

all: sim

# ---------------------------------------------------------------------------
# 0. Crear cds.lib, hdl.var y el directorio de la biblioteca
# ---------------------------------------------------------------------------
setup: $(CDSLIB) $(HDLVAR) $(WORKDIR)

$(CDSLIB):
	@echo ">>> Generando $(CDSLIB)..."
	@echo 'INCLUDE $$CDS_INST_DIR/tools/inca/files/cds.lib' > $(CDSLIB)
	@echo 'DEFINE  $(W) ./$(W)'                              >> $(CDSLIB)

$(HDLVAR):
	@echo ">>> Generando $(HDLVAR)..."
	@echo 'INCLUDE $$CDS_INST_DIR/tools/inca/files/hdl.var' > $(HDLVAR)
	@echo 'DEFINE  WORK $(W)'                                >> $(HDLVAR)

$(WORKDIR):
	@echo ">>> Creando directorio de biblioteca '$(W)'..."
	mkdir -p $(W)

# ---------------------------------------------------------------------------
# 1. Compilar VHDL
# ---------------------------------------------------------------------------
compile_vhdl: setup $(VHDL_SRCS)
	@echo ">>> Compilando VHDL..."
	$(XMVHDL) $(XMVHDL_OPTS) $(VHDL_SRCS)

# ---------------------------------------------------------------------------
# 2. Compilar SystemVerilog
# ---------------------------------------------------------------------------
compile_sv: compile_vhdl $(SV_SRCS)
	@echo ">>> Compilando SystemVerilog..."
	$(XMVLOG) $(XMVLOG_OPTS) $(SV_SRCS)

# ---------------------------------------------------------------------------
# 3. Elaborar
# ---------------------------------------------------------------------------
elab: compile_sv
	@echo ">>> Elaborando..."
	$(XMELAB) $(XMELAB_OPTS) $(TOP)

# ---------------------------------------------------------------------------
# 4. Simular
# ---------------------------------------------------------------------------
sim: elab
	@echo ">>> Simulando..."
	$(XMSIM) $(XMSIM_OPTS) $(W).$(TOP)

# ---------------------------------------------------------------------------
# 3b. Elaborar con cobertura habilitada
# ---------------------------------------------------------------------------
elab_cov: compile_sv
	@echo ">>> Elaborando con cobertura..."
	$(XMELAB) $(XMELAB_COV_OPTS) $(TOP)

# ---------------------------------------------------------------------------
# 4b. Simular con cobertura y generar reporte
# ---------------------------------------------------------------------------
sim_cov: elab_cov
	@echo ">>> Simulando con cobertura..."
	$(XMSIM) $(XMSIM_COV_OPTS) $(W).$(TOP)
	@echo ">>> Generando reporte de cobertura..."
	imc -load $(COV_WORK) -execcmd \
	    "report -summary -detail -out coverage_report.txt; exit" || true
	@echo ">>> Reporte guardado en coverage_report.txt"

# ---------------------------------------------------------------------------
# Flujo todo-en-uno con xrun (más rápido para desarrollo)
# ---------------------------------------------------------------------------
xrun: setup
	@echo ">>> Ejecutando xrun (todo-en-uno)..."
	$(XRUN) $(XRUN_OPTS)    \
	    $(CDSLIB_OPT)        \
	    $(HDLVAR_OPT)        \
	    $(VHDL_SRCS)         \
	    $(SV_SRCS)

# ---------------------------------------------------------------------------
# Abrir formas de onda en SimVision
# ---------------------------------------------------------------------------
waves:
	@echo ">>> Abriendo SimVision..."
	simvision $(WAVES) &

# ---------------------------------------------------------------------------
# Reporte de cobertura con IMC (sobre un cov_work existente)
# ---------------------------------------------------------------------------
cov:
	@echo ">>> Generando reporte de cobertura..."
	imc -load $(COV_WORK) -execcmd \
	    "report -summary -detail -out coverage_report.txt; exit"

# ---------------------------------------------------------------------------
# Limpieza
# ---------------------------------------------------------------------------
clean:
	@echo ">>> Limpiando artefactos..."
	rm -rf $(W) $(WAVES) $(CDSLIB) $(HDLVAR) $(COV_WORK) \
	       *.log *.key *.diag cov_work coverage_report.txt \
	       xrun.history .simvision *.shm *.dsn *.trn

# ---------------------------------------------------------------------------
# Ayuda
# ---------------------------------------------------------------------------
help:
	@echo ""
	@echo "  Targets disponibles:"
	@echo "    make           → compile VHDL → compile SV → elab → sim"
	@echo "    make sim_cov   → compile → elab con coverage → sim → reporte"
	@echo "    make cov       → reporte imc sobre cov_work existente"
	@echo "    make xrun      → flujo todo-en-uno (xrun)"
	@echo "    make waves     → abre SimVision con dump.shm"
	@echo "    make clean     → borra todos los artefactos"
	@echo ""
