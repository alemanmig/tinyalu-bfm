// scoreboard.sv — Verificador de resultados del TinyALU
// Basado en el proyecto de Ray Salemi (Apache 2.0)

module scoreboard (tinyalu_bfm bfm);
  import tinyalu_pkg::*;

  int pass_count = 0;
  int fail_count = 0;

  // -----------------------------------------------------------------------
  // Función de predicción (modelo de referencia)
  // -----------------------------------------------------------------------
  function logic [15:0] predict_result(
    input logic [7:0]  iA, iB,
    input operation_t  iop
  );
    case (iop)
      add_op : return {8'h00, iA} + {8'h00, iB};
      and_op : return {8'h00, iA} & {8'h00, iB};
      xor_op : return {8'h00, iA} ^ {8'h00, iB};
      mul_op : return iA * iB;
      default: return 16'hX;
    endcase
  endfunction : predict_result

  // -----------------------------------------------------------------------
  // Monitor: detecta done y verifica resultado
  // -----------------------------------------------------------------------
  always @(posedge bfm.clk) begin
    if (bfm.done && bfm.reset_n) begin
      logic [15:0]  exp;
      operation_t   op_enum;      // variable local para poder llamar .name()
      op_enum = operation_t'(bfm.op);
      exp     = predict_result(bfm.A, bfm.B, op_enum);

      if (bfm.result !== exp) begin
        $error("[FAIL] op=%0s A=0x%02h B=0x%02h | got=0x%04h exp=0x%04h",
               op_enum.name(), bfm.A, bfm.B, bfm.result, exp);
        fail_count++;
      end else begin
        $display("[PASS] op=%0s A=0x%02h B=0x%02h | result=0x%04h",
                 op_enum.name(), bfm.A, bfm.B, bfm.result);
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
