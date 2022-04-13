module	t_multiplier;
  reg signed	[3:0] A, B;
  wire signed [10:0]	C;

  multiplier M1(A, B, C);

  //apply inputs one at a time
  initial	begin
    $dumpfile("multiplier.vcd");
    $dumpvars;
    A=4'b0; B=4'b0;
    #100 A=4'b0111; B=4'b0111;
  end

  initial #200 $finish;
endmodule