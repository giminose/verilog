module mac (instruction, multiplier, multiplicand, stall, clk, reset_n, result, protect);
input signed [15:0] multiplier;
input signed [15:0] multiplicand; 
input  clk;
input  reset_n;
input  stall;
input  [2:0] instruction;
output reg [31:0] result;
output reg [7:0] protect;
reg signed [31:0] reg_result_tmp;
reg signed [31:0] reg_result;
reg [7:0] reg_protect;

  always@(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
      reg_result <= reg_result_tmp;
      result <= reg_result;
      protect <= reg_protect;
    end else begin
      protect = 8'b0;
      result = 32'b0;
    end
  end

  always@(*) begin
    reg_protect = protect;
    case(instruction)
      3'b000: begin
        reg_result_tmp = 32'b0;
        reg_protect = 8'b0;
      end
      3'b001: begin
         reg_result_tmp = multiplier * multiplicand;
      end
      3'b010: begin
         reg_result_tmp = multiplier * multiplicand;
      end
      3'b011: begin
         reg_result_tmp = multiplier * multiplicand;
      end
      3'b100: begin
        reg_result_tmp = 32'b0;
        reg_protect = 8'b0;
      end
      3'b101: begin
         reg_result_tmp = multiplier * multiplicand;
      end
      3'b110: begin
         reg_result_tmp = multiplier * multiplicand;
      end
      3'b111: begin
         reg_result_tmp = multiplier * multiplicand;
      end
    endcase
  end

endmodule
