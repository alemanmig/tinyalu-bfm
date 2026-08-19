// tinyalu_pkg.sv — Tipos y definiciones del TinyALU BFM
// Basado en el proyecto de Ray Salemi (Apache 2.0)

package tinyalu_pkg;

  typedef enum logic [2:0] {
    no_op  = 3'b000,
    add_op = 3'b001,
    and_op = 3'b010,
    xor_op = 3'b011,
    mul_op = 3'b100,
    rst_op = 3'b111   // operación de reset
  } operation_t;

endpackage : tinyalu_pkg
