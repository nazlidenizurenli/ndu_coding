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

// Keep track of which GCD unit you will dequeue from next


// Define our "fire" wires
wire operands_fire, request0_fire, request1_fire, result_fire, response0_fire, response1_fire;

// Wires and assignments go here
// Hint: Most of your code will be assignments

// OPERANDS_FIRE
reg unit_0_full;
reg unit_1_full;

reg unit_0_respond;
reg unit_1_respond;

assign operands_rdy = (unit_1_full && unit_0_full) ? 0 : 1;
assign operands_fire = operands_rdy && operands_val;


//REQUEST_O_FIRE
assign request0_val = (operands_fire && !unit_0_full) ? 1 : 0; 
assign request0_fire = request0_rdy && request0_val;

assign request0_operands_bits_A = (request0_fire == 1) ? operands_bits_A : request0_operands_bits_A; 
assign request0_operands_bits_B = (request0_fire == 1) ? operands_bits_B : request0_operands_bits_A; 


//REQUEST_1_FIRE
assign request1_val = (operands_fire && !unit_1_full && !request0_val) ? 1 : 0; 
assign request1_fire = request1_rdy && request1_val;


assign request1_operands_bits_A = (request1_fire == 1) ? operands_bits_A : request1_operands_bits_A; 
assign request1_operands_bits_B = (request1_fire == 1) ? operands_bits_B : request1_operands_bits_A; 

//RESPONSE_O_FIRE
assign response0_rdy = (unit_0_full && unit_0_respond);
assign response0_fire = response0_rdy && response0_val;

//RESPONSE_1_FIRE
assign response1_rdy = (unit_1_full && unit_1_respond);
assign response1_fire = response1_rdy && response1_val;

//RESULT_FIRE
assign result_val = (response0_fire || response1_fire) ? 1 : 0;
assign result_fire = result_rdy && result_val;
assign result_bits_data = (result_fire && response0_fire) ? response0_result_bits_data
                        : (result_fire && response1_fire) ? response1_result_bits_data
                        : result_bits_data;


// Sequential logic goes here
// Be sure to implement reset! Look at fifo.v for an example

always @(posedge clk) begin
  //$display("unit_0_full: %d unit_1_full: %d unit_0_respond: %d unit_1_respond: %d", unit_0_full, unit_1_full, unit_0_respond, unit_1_respond);
  //$display("unit_1_full: %d unit_0_full: %d request0_fire: %d request0_val: %d request1_fire: %d request1_val: %d",unit_1_full, unit_0_full, request0_fire, request0_val, request1_fire, request1_val);
  if (reset) begin
    // clear everything
    unit_0_full <= 0;
    unit_1_full <= 0;
    unit_0_respond <= 1;
    unit_1_respond <= 0;

  end else begin
    if (unit_0_full && response0_fire && result_fire) begin
      unit_0_full <= 0;
      unit_0_respond <= 0;
      unit_1_respond <= 1;
    end
    if (unit_1_full && response1_fire && result_fire) begin
      unit_1_full <= 0;
      unit_0_respond <= 1;
      unit_1_respond <= 0;
    end
    if (!unit_0_full && request0_fire) begin
      unit_0_full <= 1;
    end
    if (!unit_1_full && request1_fire) begin
      unit_1_full <= 1;
    end

  end
end 

endmodule