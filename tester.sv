// tester.sv — Generador de estímulos del TinyALU
// Basado en el proyecto de Ray Salemi (Apache 2.0)

module tester (tinyalu_bfm bfm);
  import tinyalu_pkg::*;

  // -----------------------------------------------------------------------
  // Función auxiliar para obtener operación aleatoria (excluye no_op)
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
    logic [15:0] result;
    operation_t  op;

    // Reset inicial
    bfm.reset_alu();

    // Casos de esquina
    bfm.send_op(8'hFF, 8'hFF, add_op, result);
    bfm.send_op(8'h00, 8'h00, mul_op, result);
    bfm.send_op(8'hFF, 8'hFF, mul_op, result);

    // Estímulos aleatorios
    repeat (100) begin
      op = get_op();
      if (op == rst_op) begin
        bfm.reset_alu();
      end else begin
        bfm.send_op($urandom_range(0, 255),
                    $urandom_range(0, 255),
                    op,
                    result);
      end
    end

    $display(">>> Tester: estimulos completados.");
    $finish;
  end

endmodule : tester
