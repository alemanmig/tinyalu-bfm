// top.sv — Módulo top del testbench TinyALU BFM
// Basado en el proyecto de Ray Salemi (Apache 2.0)

module top;
  import tinyalu_pkg::*;

  // BFM (interface)
  tinyalu_bfm bfm();

  // DUT VHDL
  tinyalu dut (
    .clk     (bfm.clk),
    .reset_n (bfm.reset_n),
    .A       (bfm.A),
    .B       (bfm.B),
    .op      (bfm.op),
    .start   (bfm.start),
    .done    (bfm.done),
    .result  (bfm.result)
  );

  // Testbench
  tester      t    (bfm);
  scoreboard  sb   (bfm);
  alu_coverage cov (bfm);   // renombrado: "coverage" es palabra reservada en SV

endmodule : top
