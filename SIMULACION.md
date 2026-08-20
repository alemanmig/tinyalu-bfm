# TinyALU BFM — Guía de simulación con Cadence Xcelium

Testbench de verificación funcional del TinyALU usando el patrón BFM (Bus Functional Model).  
Herramientas requeridas: **Cadence Xcelium** (`xmvhdl`, `xmvlog`, `xmelab`, `xmsim`, `xrun`, `imc`/`xcrg`).

---

## Estructura del proyecto

```
tinyalu-bfm/
├── tinyalu_dut/                  # DUT en VHDL
│   ├── single_cycle_add_and_xor.vhd
│   ├── three_cycle_mult.vhd
│   └── tinyalu.vhd
├── tinyalu_pkg.sv                # Tipos compartidos (enum operation_t)
├── tinyalu_bfm.sv                # Interface BFM (clk, reset, tareas send_op/reset_alu)
├── tester.sv                     # Generador de estímulos
├── scoreboard.sv                 # Verificador de resultados
├── coverage.sv                   # Cobertura funcional (module alu_coverage)
├── top.sv                        # Top del testbench
├── run.do                        # Script TCL para xmsim (waveforms + run)
└── Makefile
```

Archivos generados automáticamente (no versionar):

```
worklib/          # Biblioteca de compilación (flujo paso a paso)
xrun_work/        # Biblioteca de xrun (flujo todo-en-uno)
cds.lib           # Mapeado de bibliotecas Cadence
hdl.var           # Variables de entorno Cadence
dump.shm/         # Formas de onda SHM
cov_work/         # Base de datos de cobertura
coverage_report.txt
*.log  *.key  *.diag
```

---

## Flujo rápido

### Simulación estándar

```bash
make
```

Ejecuta el flujo completo en cuatro pasos:

1. **setup** — genera `cds.lib`, `hdl.var` y el directorio `worklib/`
2. **compile\_vhdl** — compila el DUT VHDL con `xmvhdl -v93`
3. **compile\_sv** — compila el testbench SystemVerilog con `xmvlog -sv`
4. **elab** — elabora el diseño con `xmelab`
5. **sim** — simula con `xmsim`; al terminar imprime el resumen PASS/FAIL

Resultado esperado al final de la simulación:

```
>>> Scoreboard: 100 PASS, 0 FAIL
>>> Tester: estimulos completados.
```

---

### Simulación con cobertura funcional

```bash
make sim_cov
```

Igual que `make` pero añade:

- Elaboración con `-coverage all`
- Colección de datos en `cov_work/scope/test/`
- Generación automática de `coverage_report.txt`

El reporte lo produce `xcrg` (Xcelium ≥ 23) o `imc` como fallback (Xcelium ≤ 22).  
Un aviso `REPDEP` de `imc` es solo informativo; el reporte se genera igualmente.

---

### Flujo todo-en-uno con xrun

```bash
make xrun
```

Usa el compilador integrado `xrun`. Más rápido para desarrollo iterativo porque no requiere el paso de setup manual. La biblioteca se almacena en `xrun_work/` (separada de `worklib/`).

---

## Targets disponibles

| Target | Descripción |
|---|---|
| `make` | Flujo completo: setup → VHDL → SV → elab → sim |
| `make sim_cov` | Ídem + elaboración con cobertura + reporte |
| `make cov` | Regenera `coverage_report.txt` desde `cov_work/` existente |
| `make xrun` | Flujo todo-en-uno con `xrun` |
| `make waves` | Abre SimVision con las formas de onda (`dump.shm`) |
| `make clean` | Elimina todos los artefactos generados |
| `make help` | Lista los targets con descripción breve |

---

## Ver formas de onda

La simulación siempre graba todas las señales en `dump.shm`.  
Para abrir SimVision:

```bash
make waves
# equivalente a: simvision dump.shm &
```

En SimVision se puede explorar la jerarquía `top → dut / t / sb / cov` y agregar señales al waveform viewer.

---

## Reporte de cobertura

Tras ejecutar `make sim_cov`, el archivo `coverage_report.txt` contiene:

- Cobertura por operación (`add_op`, `and_op`, `xor_op`, `mul_op`)
- Cobertura de valores en entradas A y B (`zero`, `max_val`, `mid`)
- Cross coverage entre operación y valor de A (`cx_op_A`)

Para regenerar el reporte sin volver a simular (si `cov_work/` ya existe):

```bash
make cov
```

---

## Limpieza

```bash
make clean
```

Elimina: `worklib/`, `xrun_work/`, `cov_work/`, `dump.shm/`, `cds.lib`, `hdl.var`, `*.log`, `*.key`, `coverage_report.txt` y demás artefactos.

---

## Notas de diseño

- `coverage` es palabra reservada en SystemVerilog; el módulo se llama **`alu_coverage`** en `coverage.sv` y `top.sv`.
- `run.do` usa `run` (sin `-all`); en Xcelium el comando de simulación es `run`, no `run -all` (sintaxis de Questa).
- El Makefile aplica `$(strip)` al nombre de la biblioteca para evitar espacios accidentales que causan el error `TOOMNS`.
- El target `xrun` usa `-clean -xmlibdirname xrun_work` para evitar conflictos de paquete `MULPAK` con `worklib/`.
