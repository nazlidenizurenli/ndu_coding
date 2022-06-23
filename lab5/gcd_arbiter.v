module gcd_arbiter #(parameter W = 32) (
  input clk,
  input reset,

  // this will be connected to the input FIFO
  input operands_val,
  input [W-1:0] operands_bits_A,
  input [W-1:0] operands_bits_B,
  output operands_rdy,

  output request0_val,
  output [W-1:0] request0_operands_bits_A,
  output [W-1:0] request0_operands_bits_B,
  input request0_rdy,

  output request1_val,
  output [W-1:0] request1_operands_bits_A,
  output [W-1:0] request1_operands_bits_B,
  input request1_rdy,

  // This will be connected to the output FIFO
  output result_val,
  output [W-1:0] result_bits_data,
  input result_rdy,

  input response0_val,
  input [W-1:0] response0_result_bits_data,
  output response0_rdy,

  input response1_val,
  input [W-1:0] response1_result_bits_data,
  output response1_rdy
);

// Keep track of which GCD unit you will enqueue to next
reg unit0_reg;
reg unit1_reg;

// Keep track of which GCD unit you will dequeue from next
reg dequeue_unit0;
reg dequeue_unit1;

// Define our "fire" wires
// Wires and assignments go here
// Hint: Most of your code will be assignments

wire operands_fire, request0_fire, request1_fire, result_fire, response0_fire, response1_fire;

assign operands_rdy = unit0_reg && unit1_reg ? 0 : 1;
assign operands_fire = operands_rdy & operands_val;

assign request0_val = operands_fire & !unit0_reg ? 1 : 0;
assign request0_fire = request0_rdy & request0_val;

assign request1_val = operands_fire & !unit1_reg & !request0_val ? 1 : 0;
assign request1_fire = request1_rdy & request1_val;

assign response0_rdy = dequeue_unit0 & unit0_reg; 
assign response0_fire = response0_rdy & response0_val;

assign response1_rdy = dequeue_unit1 & unit1_reg; 
assign response1_fire = response1_rdy & response1_val;

assign result_val = response0_fire || response1_fire ? 1 : 0;
//assign result_fire = result_rdy & result_val;

assign request0_operands_bits_A = !unit0_reg ? operands_bits_A : request0_operands_bits_A;
assign request0_operands_bits_B = !unit0_reg ? operands_bits_B : request0_operands_bits_B;

assign request1_operands_bits_A = !unit1_reg ? operands_bits_A : request0_operands_bits_A;
assign request1_operands_bits_B = !unit1_reg ? operands_bits_B : request0_operands_bits_B;

assign result_bits_data = (response0_fire) ? response0_result_bits_data
                        : (response1_fire) ? response1_result_bits_data
                        : result_bits_data;


// Sequential logic goes here
// Be sure to implement reset! Look at fifo.v for an example

always @(posedge clk) begin
  if (reset) begin
    // Initialize all registers 
    unit0_reg <= 0;
    unit1_reg <= 0;
    dequeue_unit0 <= 1;
    dequeue_unit1 <= 0;
  end else begin 
    // Manipulate the signals 
    //$display("unit0_reg: %d unit1_reg: %d dequeue_unit0: %d dequeue_unit1: %d operands_rdy: %d request0_val: %d", unit0_reg, unit1_reg, dequeue_unit0, dequeue_unit1, operands_rdy,request0_val);
    if (unit0_reg & response0_fire ) begin
      dequeue_unit1 <= 1;
      dequeue_unit0 <= 0;
      unit0_reg <= 0;
    end
    if (unit1_reg & response1_fire) begin
      dequeue_unit0 <= 1;
      dequeue_unit1 <= 0;
      unit1_reg <= 0;
    end
    if (!unit0_reg & request0_fire) begin
      unit0_reg <= 1;
    end 
    if (!unit1_reg & request1_fire) begin
      unit1_reg <= 1;
    end 
  end
end

endmodule