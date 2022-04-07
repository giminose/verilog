module	multiplier(A, B, C);
  output signed [7:0] C;
  input	signed [3:0] A, B;
  
  assign C = A * B;

endmodule