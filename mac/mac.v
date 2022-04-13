module mac (instruction, multiplier, multiplicand, stall, clk, reset_n, result, protect);
input signed [15:0] multiplier;
input signed [15:0] multiplicand; 
input  clk;
input  reset_n;
input  stall;
input  [2:0] instruction;
output reg [31:0] result;
output reg [7:0] protect;
reg signed [39:0] reg_result_tmp_1;
reg signed [39:0] reg_result_tmp_2;
reg [7:0] reg_protect;

  always@(negedge clk or negedge reset_n) begin
    if(~reset_n) begin
      reg_result_tmp_1 <= 39'b0;
      reg_result_tmp_2 <= 39'b0;
      result <= 32'b0;
      protect <= 8'b0;
    end else begin
      reg_result_tmp_2 <= reg_result_tmp_1;
      {protect,result} <= reg_result_tmp_2;
    end
  end

  always@(*) begin
    case(instruction)
      3'b000: begin
        reg_result_tmp_1 = 39'b0;
      end
      3'b001: begin
        reg_result_tmp_1 = multiplier * multiplicand;
      end
      3'b010: begin
        reg_result_tmp_1 = reg_result_tmp_2 + (multiplier * multiplicand);
      end
      3'b011: begin
        if (reg_result_tmp_2 > 40'h007FFFFFFF)
          reg_result_tmp_1 = {protect,32'h7FFFFFFF};
        else if (reg_result_tmp_2 < 40'hFF80000000)
          reg_result_tmp_1 = {protect,32'h80000000};
        else
          reg_result_tmp_1 = reg_result_tmp_2;
      end
      3'b100: begin
        reg_result_tmp_1 = 39'b0;
      end
      3'b101: begin
         reg_result_tmp_1 = multiplier * multiplicand;
      end
      3'b110: begin
         reg_result_tmp_1 = multiplier * multiplicand;
      end
      3'b111: begin
         reg_result_tmp_1 = multiplier * multiplicand;
      end
    endcase
  end

endmodule
