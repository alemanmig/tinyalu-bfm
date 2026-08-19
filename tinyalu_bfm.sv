// tinyalu_bfm.sv — Bus Functional Model del TinyALU
// Basado en el proyecto de Ray Salemi (Apache 2.0)

interface tinyalu_bfm;
  import tinyalu_pkg::*;

  // Señales del DUT
  logic        clk;
  logic        reset_n;
  logic  [7:0] A;
  logic  [7:0] B;
  logic  [2:0] op;
  logic        start;
  logic        done;
  logic [15:0] result;

  // Señales internas de control
  logic        result_check;

  // -----------------------------------------------------------------------
  // Generación de reloj
  // -----------------------------------------------------------------------
  initial clk = 0;
  always #5 clk = ~clk;   // 100 MHz

  // -----------------------------------------------------------------------
  // Tareas del BFM
  // -----------------------------------------------------------------------

  // Enviar una operación y esperar done
  task send_op(input logic [7:0] iA, iB,
               input operation_t iop,
               output logic [15:0] oresult);
    if (iop == rst_op) begin
      reset_n = 1'b0;
      @(posedge clk);
      #1;
      reset_n = 1'b1;
    end else begin
      @(negedge clk);
      A     = iA;
      B     = iB;
      op    = iop;
      start = 1'b1;
      @(posedge done);
      @(negedge clk);
      oresult = result;
      start   = 1'b0;
    end
  endtask : send_op

  // Reset inicial del DUT
  task reset_alu();
    reset_n = 1'b0;
    start   = 1'b0;
    @(negedge clk);
    @(negedge clk);
    reset_n = 1'b1;
  endtask : reset_alu

endinterface : tinyalu_bfm
