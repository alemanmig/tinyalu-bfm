// coverage.sv — Cobertura funcional del TinyALU
// Basado en el proyecto de Ray Salemi (Apache 2.0)
// NOTA: el módulo se llama "alu_coverage" porque "coverage" es
//       palabra reservada en SystemVerilog.
//
// IMPORTANTE: get_coverage() solo funciona cuando xmsim/xmelab se lanza
// con -coverage all. Para el reporte usa: make sim_cov

module alu_coverage (tinyalu_bfm bfm);
  import tinyalu_pkg::*;

  // -----------------------------------------------------------------------
  // Covergroup: operaciones y valores de entrada
  // -----------------------------------------------------------------------
  covergroup alu_cg @(posedge bfm.clk);

    cp_op : coverpoint operation_t'(bfm.op) iff (bfm.done && bfm.reset_n) {
      bins add   = {add_op};
      bins and_b = {and_op};
      bins xor_b = {xor_op};
      bins mul   = {mul_op};
    }

    cp_A : coverpoint bfm.A iff (bfm.done && bfm.reset_n) {
      bins zero    = {8'h00};
      bins max_val = {8'hFF};
      bins mid     = {[8'h01 : 8'hFE]};
    }

    cp_B : coverpoint bfm.B iff (bfm.done && bfm.reset_n) {
      bins zero    = {8'h00};
      bins max_val = {8'hFF};
      bins mid     = {[8'h01 : 8'hFE]};
    }

    cx_op_A : cross cp_op, cp_A;

  endgroup : alu_cg

  alu_cg cov_inst = new();

  // El reporte de get_coverage() solo es válido con -coverage all (make sim_cov)
  // En simulación normal simplemente no se imprime para evitar el warning COVNSM
  final begin
    $display("=== Coverage: usa 'make sim_cov' para reporte de cobertura ===");
  end

endmodule : alu_coverage
