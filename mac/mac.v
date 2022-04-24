module mac (instruction, multiplier, multiplicand, stall, clk, reset_n, result, protect);
input signed [15:0] multiplier;
input signed [15:0] multiplicand; 
input  clk;
input  reset_n;
input  stall;
input  [2:0] instruction;
output reg [31:0] result;
output reg [7:0] protect;
// reg signed [39:0] reg_result_tmp_1;
// reg signed [39:0] reg_result_tmp_2;
// reg signed [39:0] reg_stall;

reg signed [39:0] product_16;
reg signed [19:0] product_8_1;
reg signed [19:0] product_8_2;
reg [2:0] pre_ins;

reg [39:0] pipe_1;
reg [39:0] pipe_2;

  always@(negedge clk or negedge reset_n) begin
    if(~reset_n) begin
      product_16 <= 39'b0;
      product_8_1 <= 19'b0;
      product_8_2 <= 19'b0;
      pipe_1 <= 42'b0;
      pipe_2 <= 42'b0;
      result <= 32'b0;
      protect <= 8'b0;
    end else begin
      pipe_2 <= pipe_1;
      {protect,result} <= pipe_2[39:0];
    end
  end

  always@(posedge clk) begin
    pre_ins <= instruction;
  end

  always@(pre_ins) begin
    product_16 <= multiplier * multiplicand;
    product_8_1 <= $signed(multiplier[7:0]) * $signed(multiplicand[7:0]);
    product_8_2 <= $signed(multiplier[15:8]) * $signed(multiplicand[15:8]);
    if (pre_ins[2] == 0)
      pipe_1 <= {product_16};
    else begin
      pipe_1 <= {product_8_1[19:16], product_8_2[19:16], product_8_1[15:0], product_8_2[15:0]};
    end; 
  end


  // always@(negedge clk or negedge reset_n) begin
  //   if(~reset_n) begin
  //     reg_result_tmp_1 <= 39'b0;
  //     reg_result_tmp_2 <= 39'b0;
  //     reg_stall <= 39'b0;
  //     result <= 32'b0;
  //     protect <= 8'b0;
  //   end else begin
  //     reg_result_tmp_2 <= reg_result_tmp_1;
  //     {protect,result} <= reg_result_tmp_2;
  //     reg_stall <= {protect,result};
  //   end
  // end

  // always@(*) begin
  //   if (~stall) begin
  //     case(instruction)
  //       3'b000: begin
  //         reg_result_tmp_1 = 39'b0;
  //       end
  //       3'b001: begin
  //         reg_result_tmp_1 = multiplier * multiplicand;
  //       end
  //       3'b010: begin
  //         reg_result_tmp_1 = reg_result_tmp_2 + (multiplier * multiplicand);
  //       end
  //       3'b011: begin
  //         if (reg_result_tmp_2 > $signed(40'h007FFFFFFF))
  //           reg_result_tmp_1 = {protect,32'h7FFFFFFF};
  //         else if (reg_result_tmp_2 < $signed(40'hFF80000000))
  //           reg_result_tmp_1 = {protect,32'h80000000};
  //         else
  //           reg_result_tmp_1 = reg_result_tmp_2;
  //       end
  //       3'b100: begin
  //         reg_result_tmp_1 = 39'b0;
  //       end
  //       3'b101: begin
  //         {reg_result_tmp_1[35:32],reg_result_tmp_1[15:0]} = $signed(multiplier[7:0]) * $signed(multiplicand[7:0]);
  //         {reg_result_tmp_1[39:36],reg_result_tmp_1[31:16]} = $signed(multiplier[15:8]) * $signed(multiplicand[15:8]);
  //       end
  //       3'b110: begin
  //         {reg_result_tmp_1[35:32],reg_result_tmp_1[15:0]} = $signed({reg_result_tmp_2[35:32],reg_result_tmp_2[15:0]}) + ($signed(multiplier[7:0]) * $signed(multiplicand[7:0]));
  //         {reg_result_tmp_1[39:36],reg_result_tmp_1[31:16]} = $signed({reg_result_tmp_2[39:36],reg_result_tmp_2[31:16]}) + ($signed(multiplier[15:8]) * $signed(multiplicand[15:8]));
  //       end
  //       3'b111: begin
  //         if ($signed({reg_result_tmp_2[35:32],reg_result_tmp_2[15:0]}) > $signed(20'h07FFF))
  //           {reg_result_tmp_1[35:32],reg_result_tmp_1[15:0]} = {protect[3:0],16'h7FFF};
  //         else if ($signed({reg_result_tmp_2[35:32],reg_result_tmp_2[15:0]}) < $signed(20'hF8000))
  //           {reg_result_tmp_1[35:32],reg_result_tmp_1[15:0]} = {protect[3:0],16'h8000};
  //         else
  //           {reg_result_tmp_1[35:32],reg_result_tmp_1[15:0]} = {reg_result_tmp_2[35:32],reg_result_tmp_2[15:0]};

  //         if ($signed({reg_result_tmp_2[39:36],reg_result_tmp_2[31:16]}) > $signed(20'h07FFF))
  //           {reg_result_tmp_1[39:36],reg_result_tmp_1[31:16]} = {protect[7:4],16'h7FFF};
  //         else if ($signed({reg_result_tmp_2[39:36],reg_result_tmp_2[31:16]}) < $signed(20'hF8000))
  //           {reg_result_tmp_1[39:36],reg_result_tmp_1[31:16]} = {protect[7:4],16'h8000};
  //         else
  //           {reg_result_tmp_1[39:36],reg_result_tmp_1[31:16]} = {reg_result_tmp_2[39:36],reg_result_tmp_2[31:16]};
  //       end
  //     endcase
  //   end else begin
  //     reg_result_tmp_1 = reg_result_tmp_2;
  //     reg_result_tmp_2 = {protect,result};
  //     {protect,result} = reg_stall;
  //   end
  // end

endmodule
