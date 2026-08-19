// scoreboard.sv — Verificador de resultados del TinyALU
// Basado en el proyecto de Ray Salemi (Apache 2.0)

module scoreboard (tinyalu_bfm bfm);
  import tinyalu_pkg::*;

  // Contadores de test
  int pass_count = 0;
  int fail_count = 0;

  // -----------------------------------------------------------------------
  // Función de predicción (modelo de referencia)
  // -----------------------------------------------------------------------
  function logic [15:0] predict_result(
    input logic [7:0]   A, B,
    input operation_t   op
  );
    case (op)
      add_op : return {8'h00, A} + {8'h00, B};
      and_op : return {8'h00, A} & {8'h00, B};
      xor_op : return {8'h00, A} ^ {8'h00, B};
      mul_op : return A * B;
      default: return 16'hX;
    endcase
  endfunction : predict_result

  // -----------------------------------------------------------------------
  // Monitor: detecta done y verifica resultado
  // -----------------------------------------------------------------------
  always @(posedge bfm.clk) begin
    if (bfm.done && bfm.reset_n) begin
      logic [15:0] exp;
      exp = predict_result(bfm.A, bfm.B, operation_t'(bfm.op));

      if (bfm.result !== exp) begin
        $error("[FAIL] op=%0s A=0x%02h B=0x%02h | got=0x%04h exp=0x%04h",
               operation_t'(bfm.op).name(), bfm.A, bfm.B, bfm.result, exp);
        fail_count++;
      end else begin
        $display("[PASS] op=%0s A=0x%02h B=0x%02h | result=0x%04h",
                 operation_t'(bfm.op).name(), bfm.A, bfm.B, bfm.result);
        pass_count++;
      end
    end
  end

  // -----------------------------------------------------------------------
  // Reporte final
  // -----------------------------------------------------------------------
  final begin
    $display("=== Scoreboard: PASS=%0d  FAIL=%0d ===", pass_count, fail_count);
    if (fail_count > 0)
      $display(">>> RESULTADO: FAILED <<<");
    else
      $display(">>> RESULTADO: PASSED <<<");
  end

endmodule : scoreboard
