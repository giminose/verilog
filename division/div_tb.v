module tb_division;
    parameter WIDTH = 8;
    // Inputs
    reg [WIDTH-1:0] A;
    reg [WIDTH-1:0] B;
    // Outputs
    wire [WIDTH-1:0] Res;

    // Instantiate the division module (UUT)
    division #(WIDTH) uut (
        .A(A), 
        .B(B), 
        .Res(Res)
    );

    initial begin
        $dumpfile("division.vcd");
        $dumpvars;
        // Initialize Inputs and wait for 100 ns
        A = 0;  B = 0;  #100;  //Undefined inputs
        //Apply each set of inputs and wait for 100 ns.
        A = 100;    B = 10; #100;
        A = 200;    B = 40; #100;
        A = 90; B = 9;  #100;
        A = 70; B = 10; #100;
        A = 16; B = 3;  #100;
        A = 255;    B = 5;  #100;
    end
      
endmodule