//`include "/home/ff/eecs151/verilog_lib/EECS151.v"
module divider #(
    parameter WIDTH = 4
) (
  input clk,

  input start,
  output done,

  input [WIDTH-1:0] dividend,
  input [WIDTH-1:0] divisor, 
  output [WIDTH-1:0] quotient,
  output [WIDTH-1:0] remainder
);

  // Feel free to change the code as long as your final code implements a divider
  // Check the algorithm described in the slides (URL in the spec)
  // Pay attention to the block diagram(s)
  reg[6:0] counter;
  reg done_reg;
  reg [2*WIDTH-1:0] ext_remainder;
  reg [WIDTH-1:0] quotient_reg;
  wire [2*WIDTH-1:0] ext_remainder_next;
  wire [2*WIDTH-1:0] ext_remainder_2;
  wire [WIDTH-1:0] quotient_next;
  wire [2*WIDTH-1:0] ext_remainder_3b;
  wire [WIDTH-1:0] quotient_3a;
  wire [WIDTH-1:0] quotient_3b;


  assign quotient_next
    = ext_remainder_2[2*WIDTH-1] == 0 && done != 1 ? quotient_3a
    : done != 1 ? quotient_3b
    : quotient_reg;

  assign ext_remainder_next
    = ext_remainder_2[2*WIDTH-1] == 1 && done != 1 ? ext_remainder_3b
    : done != 1 ? ext_remainder_2
    : ext_remainder;

  assign ext_remainder_2 = {(ext_remainder[2*WIDTH-1:WIDTH] - divisor), ext_remainder[WIDTH-1:0]};
  assign ext_remainder_3b = {ext_remainder_2[2*WIDTH-1:WIDTH] + divisor, ext_remainder_2[WIDTH-1:0]};
  assign quotient_3a = (quotient_reg << 1) + 1;
  assign quotient_3b = {(quotient_reg << 1), 1'b0};

  assign remainder = ext_remainder[WIDTH-1:0];
  assign quotient = quotient_next;
  assign done = done_reg;


  always @(posedge clk) begin
    if (start) begin 
      counter <= 0;
      ext_remainder <= {4'b0000, dividend};
      quotient_reg <= 0;
      done_reg <= 0;
    end else begin
      if (counter == 4) begin
        done_reg <= 1;
      end
      counter <= counter + 1;
      ext_remainder <= ext_remainder_next << 1;
      quotient_reg <= quotient_next;
      //$display("ext_remainder_reg: %b ext_remainder_2: %b ext_remainder_3b: %b quotient_3a: %b quotient_3b: %b remainder: %b", ext_remainder_reg, ext_remainder_2, ext_remainder_3b, quotient_3a, quotient_3b, remainder);
    end 

  end

endmodule














