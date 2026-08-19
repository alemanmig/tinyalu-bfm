// top.sv — Módulo top del testbench TinyALU BFM
// Basado en el proyecto de Ray Salemi (Apache 2.0)

module top;
  import tinyalu_pkg::*;

  // -----------------------------------------------------------------------
  // Instancia del BFM (interface)
  // -----------------------------------------------------------------------
  tinyalu_bfm bfm();

  // -----------------------------------------------------------------------
  // Instancia del DUT (VHDL)
  // -----------------------------------------------------------------------
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

  // -----------------------------------------------------------------------
  // Instancias del testbench
  // -----------------------------------------------------------------------
  tester     t   (bfm);
  scoreboard sb  (bfm);
  coverage   cov (bfm);

endmodule : top
