module mac (instruction, multiplier, multiplicand, stall, clk, reset_n, result, protect);
input signed [15:0] multiplier;
input signed [15:0] multiplicand; 
input  clk;
input  reset_n;
input  stall;
input  [2:0] instruction;
output reg [31:0] result;
output reg [7:0] protect;

reg [2:0] curIns;
reg [2:0] preIns;

reg [39:0] pipe1 = 40'b0;
reg [39:0] pipe2 = 40'b0;

reg [39:0] zero = 40'b0;

  always@(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
      result <= 32'b0;
      protect <= 8'b0;
    end else if (~stall) begin
      curIns <= instruction;
      if (instruction[2] == 0)
        pipe1 <= multiplier * multiplicand;
      else begin
        {pipe1[35:32],pipe1[15:0]} <= $signed(multiplier[7:0]) * $signed(multiplicand[7:0]);
        {pipe1[39:36],pipe1[31:16]} <= $signed(multiplier[15:8]) * $signed(multiplicand[15:8]);
      end
    end else begin
      curIns <= curIns;
      pipe1 <= pipe1;
    end
  end

  always@(posedge clk) begin
    preIns = curIns;
    if (~stall)
      {protect, result} <= pipe2;
    else begin
      {protect, result} <= {protect, result};
      pipe2 <= pipe2;
    end
    case(preIns)
      3'b000: begin
        pipe2 = zero;
      end
      3'b001: begin
        pipe2 = pipe1;
      end
      3'b010: begin
        pipe2 = pipe2 + pipe1;
      end
      3'b011: begin
        if ($signed(pipe2) > $signed(40'h007FFFFFFF))
          pipe2 = {protect,32'h7FFFFFFF};
        else if ($signed(pipe2) < $signed(40'hFF80000000))
          pipe2 = {protect,32'h80000000};
        else
          pipe2 = pipe2;
      end
      3'b100: begin
        pipe2 = zero;
      end
      3'b101: begin
        {pipe2[35:32],pipe2[15:0]} = {pipe1[35:32],pipe1[15:0]};
        {pipe2[39:36],pipe2[31:16]} = {pipe1[39:36],pipe1[31:16]};
      end
      3'b110: begin
        {pipe2[35:32],pipe2[15:0]} = $signed({pipe2[35:32],pipe2[15:0]}) + $signed({pipe1[35:32],pipe1[15:0]});
        {pipe2[39:36],pipe2[31:16]} = $signed({pipe2[39:36],pipe2[31:16]}) + $signed({pipe1[39:36],pipe1[31:16]});
      end
      3'b111: begin
        if ($signed({pipe2[35:32],pipe2[15:0]}) > $signed(20'h07FFF))
          {pipe2[35:32],pipe2[15:0]} = {protect[3:0],16'h7FFF};
        else if ($signed({pipe2[35:32],pipe2[15:0]}) < $signed(20'hF8000))
          {pipe2[35:32],pipe2[15:0]} = {protect[3:0],16'h8000};
        else
          {pipe2[35:32],pipe2[15:0]} = {pipe2[35:32],pipe2[15:0]};

        if ($signed({pipe2[39:36],pipe2[31:16]}) > $signed(20'h07FFF))
          {pipe2[39:36],pipe2[31:16]} = {protect[7:4],16'h7FFF};
        else if ($signed({pipe2[39:36],pipe2[31:16]}) < $signed(20'hF8000))
          {pipe2[39:36],pipe2[31:16]} = {protect[7:4],16'h8000};
        else
          {pipe2[39:36],pipe2[31:16]} = {pipe2[39:36],pipe2[31:16]};
      end
    endcase
  end

endmodule
