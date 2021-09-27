module BSCANE2 (
  output CAPTURE,
  output DRCK,
  output RESET,
  output RUNTEST,
  output SEL,
  output SHIFT,
  output TCK,
  output TDI,
  output TMS,
  output UPDATE,

  input TDO
);

  parameter integer JTAG_CHAIN = 1;

  assign CAPTURE = 0;
  assign DRCK = 0;
  assign RESET = 0;
  assign RUNTEST = 1;
  assign SEL = 0;
  assign SHIFT = 0;
  assign TCK = 0;
  assign TDI = 0;
  assign TMS = 0;
  assign UPDATE = 0;
endmodule
