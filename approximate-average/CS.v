`timescale 1ns/10ps
module CS(Y, X, reset, clk);

input clk, reset; 
input 	[7:0] X;
output 	[9:0] Y;

reg     [71:0] data;
wire    [11:0] sum;
reg     [11:0] r_sum;
wire    [11:0] avg;
wire    [8:0]  flag;
reg     [8:0]  r_flag;
wire           oi_11, oi_12, oi_13, oi_14, oi_21, oi_22, oi_31, oi_41;
wire    [7:0]  ov_11, ov_12, ov_13, ov_14, ov_21, ov_22, ov_31, xappr;
wire    [12:0] out;

always @(posedge clk or posedge reset) begin
    if(reset) begin
        data <= 72'b0;
        r_sum <= 0;
        r_flag <= 8'b0;
    end
    else begin
        data <= {data[63:0], X};
        r_sum <= sum;
        r_flag <= flag;
    end
end

//------------------------- Calculate the summation of x0 ~ x8 -------------------------
assign sum = r_sum - {4'b0, data[71:64]} + {4'b0, X};
//--------------------------------------------------------------------------------------

//--------------------------- Calculate xavg by sum divide 9 ---------------------------
division #(12) d9(.A(sum), .B({8'b0, 4'b1001}), .Res(avg));
//--------------------------------------------------------------------------------------

//-------------------------------- Check x0 ~ x8 > xavg --------------------------------
assign flag[0] = data[63:56] > avg[7:0];
assign flag[1] = data[55:48] > avg[7:0];
assign flag[2] = data[47:40] > avg[7:0];
assign flag[3] = data[39:32] > avg[7:0];
assign flag[4] = data[31:24] > avg[7:0];
assign flag[5] = data[23:16] > avg[7:0];
assign flag[6] = data[15:8] > avg[7:0];
assign flag[7] = data[7:0] > avg[7:0];
assign flag[8] = X > avg[7:0];
//--------------------------------------------------------------------------------------

// Find the number which is larger in x0 ~ x8, and the number is less than equal to xavg
Comparison c11(r_flag[0], r_flag[1], data[71:64], data[63:56], oi_11, ov_11);
Comparison c12(r_flag[2], r_flag[3], data[55:48], data[47:40], oi_12, ov_12);
Comparison c13(r_flag[4], r_flag[5], data[39:32], data[31:24], oi_13, ov_13);
Comparison c14(r_flag[6], r_flag[7], data[23:16], data[15:8], oi_14, ov_14);
Comparison c21(oi_11, oi_12, ov_11, ov_12, oi_21, ov_21);
Comparison c22(oi_13, oi_14, ov_13, ov_14, oi_22, ov_22);
Comparison c23(oi_21, oi_22, ov_21, ov_22, oi_31, ov_31);
Comparison c24(oi_31, r_flag[8], ov_31, data[7:0], oi_41, xappr);
//--------------------------------------------------------------------------------------

//--------------- ov_41 is xavg, and we need to calculte "sum + xavg * 9" --------------
assign out = {1'b0, r_sum} + {1'b0, {1'b0, xappr, 3'b0} + {4'b0, xappr}};
assign Y = out[12:3];
//--------------------------------------------------------------------------------------

endmodule

module division(A,B,Res);

//the size of input and output ports of the division module is generic.
parameter WIDTH = 8;
//input and output ports.
input [WIDTH-1:0] A;
input [WIDTH-1:0] B;
output [WIDTH-1:0] Res;
//internal variables
reg [WIDTH-1:0] Res = 0;
reg [WIDTH-1:0] a1,b1;
reg [WIDTH:0] p1;   
integer i;

always@ (A or B)
begin
    //initialize the variables.
    a1 = A;
    b1 = B;
    p1= 0;
    for(i=0;i < WIDTH;i=i+1) 
    begin //start the for loop
        p1 = {p1[WIDTH-2:0],a1[WIDTH-1]};
        a1[WIDTH-1:1] = a1[WIDTH-2:0];
        p1 = p1-b1;
        if(p1[WIDTH-1] == 1) 
        begin
            a1[0] = 0;
            p1 = p1 + b1; 
        end
        else
            a1[0] = 1;
    end
    Res <= a1;
end 

endmodule

module Comparison(invalid1, invalid2, value1, value2, o_invalid, o_value);

input           invalid1;
input           invalid2;
input   [7:0]   value1;
input   [7:0]   value2;
output          o_invalid;
output  [7:0]   o_value;
reg             o_invalid;
reg     [7:0]   o_value; 
wire            flag;

assign flag = value1 > value2;

always @(*) begin
    case({invalid1, invalid2})
        2'b00: begin
            o_invalid <= 0;
            if(flag) o_value <= value1;
            else o_value <= value2;
        end
        2'b01: begin
            o_invalid <= 0;
            o_value <= value1;
        end
        2'b10: begin
            o_invalid <= 0;
            o_value <= value2;
        end
        default: begin
            o_invalid <= 1;
            o_value <= 8'bx;
        end
    endcase
end
endmodule