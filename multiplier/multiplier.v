module	multiplier(A, B, C);
  output signed [10:0] C;
  input	signed [3:0] A, B;
  
  assign C = A * B;

endmodule