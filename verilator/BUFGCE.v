module BUFGCE (
  output O,
  input CE,
  input I
);
  assign O = CE ? I : 1'b0;
endmodule