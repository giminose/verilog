`timescale 1ns/10ps

module counterTest;
reg clk;
reg rst;
wire [2:0] q;

counter DUT (.clk(clk), .rst(rst), .q(q));

initial
begin
  clk = 0;
  rst = 1;
end

initial #100 rst = 0;

always #50 clk=clk+1;

endmodule