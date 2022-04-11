`timescale 1ns/10ps
module traffic_light (clk, rst, pass, R, G, Y);
  input  clk, rst, pass;
  output R, G, Y;
  wire recount;
  wire [2:0] cs;

  control ctl (.clk(clk),.rst(rst),.pass(pass),.recount(recount),.cs(cs),.R(R),.G(G),.Y(Y));

  datapath data (.clk(clk), .rst(rst), .pass(pass), .status(cs), .recount(recount));

endmodule

module datapath(clk, rst, pass, status, recount);
  input clk, rst, pass;
  input [2:0] status; 
  output recount; 
  wire [11:0] cout;

  compare com (.current(cout), .pass(pass), .status(status), .recount(recount));
  counter cnt (.clk(clk),.rst(rst), .recount(recount), .cout(cout));

endmodule

module counter(clk, rst, recount, cout);
  input clk, rst, recount;
  output [11:0] cout;
  reg [11:0] cout;
  
  always@(posedge clk or negedge rst) begin
    if(rst) 
      cout=0;
    else begin
      if(recount) cout=1;
      else cout=cout+1;
    end 
  end

endmodule

module compare(current, pass, status, recount);
  input [2:0] status;
  input [11:0] current;
  input pass;
  output recount;
  reg recount;

  parameter G0_times = 1024;
  parameter N0_times = 128;
  parameter G1_times = 128;
  parameter N1_times = 128;
  parameter G2_times = 128;
  parameter Y0_times = 512;
  parameter R0_times = 1024;
  
  always@(*) begin
    case(status)
      3'b000: begin
        if(current == G0_times) 
          recount=1;
        else 
          recount=0;
      end
      3'b001: begin
        if(pass)
          recount=1;
        else if(current == N0_times) 
          recount=1; 
        else 
          recount=0; 
      end
      3'b010: begin
        if(pass)
          recount=1;
        else if(current == G1_times) 
          recount=1; 
        else
          recount=0; 
      end
      3'b011: begin
        if(pass)
          recount=1;
        else if(current == N1_times) 
          recount=1; 
        else
          recount=0; 
      end
      3'b100: begin
        if(pass)
          recount=1;
        else if(current == G2_times) 
          recount=1; 
        else
          recount=0; 
      end
      3'b101: begin
        if(pass)
          recount=1;
        else if(current == Y0_times) 
          recount=1; 
        else
          recount=0; 
      end
      3'b110: begin
        if(pass)
          recount=1;
        else if(current == R0_times) 
          recount=1; 
        else
          recount=0; 
      end
      default: recount = 1;
    endcase
  end
endmodule

module control(clk, rst, pass, recount, cs, R, G, Y);
  input clk, rst, pass, recount; 
  output [2:0] cs;
  output R, G, Y;
  reg R, G, Y;
  reg [2:0] cs, ns;
  parameter [2:0] G0 = 3'b000;
  parameter [2:0] N0 = 3'b001;
  parameter [2:0] G1 = 3'b010;
  parameter [2:0] N1 = 3'b011;
  parameter [2:0] G2 = 3'b100;
  parameter [2:0] Y0 = 3'b101;
  parameter [2:0] R0 = 3'b110;
  
  always@(posedge clk or negedge rst) begin
    if(rst)
      cs = G0;
    else
      cs = ns;
  end
  
  always@(recount, cs, pass) begin
    case(cs) 
      G0: begin
        if(recount)
          ns=N0;
        else
          ns=G0; 
      end
      N0: begin 
        if(pass)
          ns=G0;
        else if(recount)
          ns=G1; 
        else
          ns=N0; 
      end 
      G1: begin
        if(pass)
          ns=G0;
        else if(recount) 
          ns=N1;
        else
          ns=G1; 
      end
      N1: begin
        if(pass)
          ns=G0;
        else if(recount) 
          ns=G2;
        else
          ns=N1; 
      end
      G2: begin
        if(pass)
          ns=G0;
        else if(recount) 
          ns=Y0;
        else
          ns=G2; 
      end
      Y0: begin
        if(pass)
          ns=G0;
        else if(recount) 
          ns=R0;
        else
          ns=Y0; 
      end
      R0: begin
        if(pass)
          ns=G0;
        else if(recount) 
          ns=G0;
        else
          ns=R0; 
      end
      default: ns=G0;
    endcase
  end
  
  always @(cs) begin
    case(cs) 
      G0: begin
        R=1'b0; 
        G=1'b1; 
        Y=1'b0;
      end
      G1: begin
        R=1'b0; 
        G=1'b1; 
        Y=1'b0;
      end
      G2: begin
        R=1'b0; 
        G=1'b1; 
        Y=1'b0;
      end
      N0: begin
        R=1'b0; 
        G=1'b0;
        Y=1'b0;
      end
      N1: begin
        R=1'b0; 
        G=1'b0;
        Y=1'b0;
      end
      Y0: begin
        R=1'b0; 
        G=1'b0;
        Y=1'b1;
      end
      R0: begin
        R=1'b1; 
        G=1'b0;
        Y=1'b0;
      end
      default: begin
        R=1'b0; 
        G=1'b0;
        Y=1'b0;
      end
    endcase 
  end 
endmodule
