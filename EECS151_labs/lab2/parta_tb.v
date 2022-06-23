`timescale 1 ns /  1 ps

module parta_tb();

    reg clk, A, B;
    wire X, Z;
    initial clk = 0;
    initial A = 0;
    initial B = 0;

    always #(5) clk <= ~clk;

parta dut (
    .clk(clk),
    .A(A),
    .B(B),
    .X(X), 
    .Z(Z)         
); 
    initial begin
        // $vcdpluson;
        @(posedge clk)
            #(0.25) B <= 0;
            #(0.75) A <= 1;
        @(posedge clk)
            #(0.25) A <= 0;
            #(0.50) B <= 1;
        @(posedge clk)
            #(0.50) B <= 0;
        // $vcdplusoff;
        $finish;
    end

    initial begin
       $monitor("time: %d, A: %d, B: %d, X: %d, Z: %d, clk: %d", $time, A, B, X, Z, clk);
    end


endmodule