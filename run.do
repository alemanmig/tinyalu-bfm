# run.do — Script TCL para Xcelium xmsim

# Abrir base de datos de formas de onda SHM
database -open dump -into dump.shm -default -shm

# Probar todas las señales de todos los niveles de jerarquía
probe -create -all -depth all -database dump

# Correr hasta $finish
run

exit
