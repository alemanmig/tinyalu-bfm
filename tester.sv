// tester.sv — Generador de estímulos del TinyALU
// Basado en el proyecto de Ray Salemi (Apache 2.0)

module tester (tinyalu_bfm bfm);
  import tinyalu_pkg::*;

  // Variables declaradas a nivel de módulo para compatibilidad con Xcelium
  logic [15:0] result;
  logic [7:0]  rA, rB;
  operation_t  op;
  int          i;

  // -----------------------------------------------------------------------
  // Función auxiliar: operación aleatoria (excluye no_op y rst_op)
  // -----------------------------------------------------------------------
  function operation_t get_op();
    logic [2:0] op_choice;
    op_choice = $urandom_range(1, 4);
    return operation_t'(op_choice);
  endfunction : get_op

  // -----------------------------------------------------------------------
  // Estímulo principal
  // -----------------------------------------------------------------------
  initial begin
    // Reset inicial
    bfm.reset_alu();

    // Casos de esquina
    bfm.send_op(8'hFF, 8'hFF, add_op, result);
    bfm.send_op(8'h00, 8'h00, mul_op, result);
    bfm.send_op(8'hFF, 8'hFF, mul_op, result);

    // Estímulos aleatorios
    for (i = 0; i < 100; i++) begin
      op = get_op();
      rA = $urandom_range(0, 255);
      rB = $urandom_range(0, 255);
      bfm.send_op(rA, rB, op, result);
    end

    $display(">>> Tester: estimulos completados.");
    $finish;
  end

endmodule : tester
