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

reg signed [39:0] product16;
reg signed [19:0] product81;
reg signed [19:0] product82;
reg [2:0] curIns;
reg [2:0] preIns;

reg [39:0] pipe1;
reg [39:0] pipe2;

  always@(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
      product16 <= 40'b0;
      product81 <= 20'b0;
      product82 <= 20'b0;
      pipe1 <= 40'b0;
      pipe2 <= 40'b0;
      result <= 32'b0;
      protect <= 8'b0;
    end else begin
      product16 <= multiplier * multiplicand;
      product81 <= $signed(multiplier[7:0]) * $signed(multiplicand[7:0]);
      product82 <= $signed(multiplier[15:8]) * $signed(multiplicand[15:8]);
      curIns <= instruction;
      preIns <= curIns;
      {protect,result} <= pipe2;
    end
  end

  always@(*) begin
    if (preIns[2] == 0)
      pipe1 <= product16;
    else begin
      pipe1 <= {product81[19:16], product82[19:16], product81[15:0], product82[15:0]};
    end;
  end

  always@(*) begin
    case(preIns[1:0])
      2'b00: begin
        pipe2 = 40'b0;
      end
      2'b01: begin
        pipe2 = pipe1;
      end
      2'b10: begin
        pipe2 = pipe2 + pipe1;
      end
      2'b11: begin
        if (pipe2 > $signed(40'h007FFFFFFF))
          pipe2 = {protect,32'h7FFFFFFF};
        else if (pipe2 < $signed(40'hFF80000000))
          pipe2 = {protect,32'h80000000};
        else
          pipe2 = pipe2;
      end
    endcase
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
