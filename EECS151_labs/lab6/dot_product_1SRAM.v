/// MODIFY THIS IMPLEMENTATION
// Modify the dot product design to use only one instantiation of a dual-port, 5-bit address width, and 16-bit data width SRAM.
// In this SRAM, you want to store vector a to the first 16 entries of the SRAM, and store vector b to the remaining entries of the SRAM.

// This module receives input vector a and b through Ready/Valid interface
// When it receives enough input items ( == vector_size), the module starts
// the dot product computation
// When the dot product result is available, it asserts the c_valid signal
// Here is the software description of the problem:
//
//  // Store input vectors to internal SRAM memories
//  for (int i = 0; i < vector_size; i++) {
//    sram_a[i] = a_data[i];
//  }
//
//  for (int i = 0; i < vector_size; i++) {
//    sram_b[i] = b_data[i];
//  }
//
//  c_data = 0;
//  for (int i = 0; i < vector_size; i++) {
//    c_data = c_data + sram_a[i] * sram_b[i];
// Implement a vector dot product of a and b
// using a single-port SRAM of 5-bit address width, 16-bit data width

module dot_product_1SRAM #(
  parameter WIDTH = 16
) (
  input clk,
  input rst,

  input [31:0]      vector_size,

  // input vector a
  input [WIDTH-1:0] a_data,
  input             a_valid,
  output            a_ready,

  // input vector b
  input [WIDTH-1:0] b_data,
  input             b_valid,
  output            b_ready,

  // dot product result c
  output [WIDTH-1:0] c_data,
  output             c_valid,
  input              c_ready
);

//endmodule

wire a_fire = a_valid && a_ready; // enqueue a
wire b_fire = b_valid && b_ready; // enqueue b
wire c_fire = c_valid && c_ready; // dequeue c (result)

// Define state values
localparam STATE_A_IDLE  = 2'b00;
localparam STATE_A_WRITE = 2'b01;
localparam STATE_A_DONE  = 2'b10;

localparam STATE_B_IDLE  = 2'b00;
localparam STATE_B_WRITE = 2'b01;
localparam STATE_B_DONE  = 2'b10;

localparam STATE_C_IDLE    = 2'b00;
localparam STATE_C_COMPUTE = 2'b01;
localparam STATE_C_DONE    = 2'b10;

// Define state registers
wire [1:0] state_a_val;
reg [1:0]  state_a_next;
REGISTER_R #(.N(2), .INIT(STATE_A_IDLE)) state_a (
    .q(state_a_val),
    .d(state_a_next),
    .rst(rst),
    .clk(clk));

wire [1:0] state_b_val;
reg [1:0]  state_b_next;
REGISTER_R #(.N(2), .INIT(STATE_B_IDLE)) state_b (
    .q(state_b_val),
    .d(state_b_next),
    .rst(rst),
    .clk(clk));

wire [1:0] state_c_val;
reg [1:0]  state_c_next;
REGISTER_R #(.N(2), .INIT(STATE_C_IDLE)) state_c (
    .q(state_c_val),
    .d(state_c_next),
    .rst(rst),
    .clk(clk));

  // This register keeps track of writing vector a to sram_a
  wire [31:0] a_idx_val, a_idx_next;
  wire a_idx_ce, a_idx_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) a_idx (
    .q(a_idx_val),
    .d(a_idx_next),
    .ce(a_idx_ce),
    .rst(a_idx_rst),
    .clk(clk));

  // This register keeps track of writing vector b to sram_b
  wire [31:0] b_idx_val, b_idx_next;
  wire b_idx_ce, b_idx_rst;
  REGISTER_R_CE #(.N(32), .INIT(16)) b_idx (
    .q(b_idx_val),
    .d(b_idx_next),
    .ce(b_idx_ce),
    .rst(b_idx_rst),
    .clk(clk));

  // This register keeps track of reading vector data from sram_a and sram_b
  wire [31:0] c_a_idx_val, c_a_idx_next;
  wire c_a_idx_ce, c_a_idx_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) c_a_idx (
    .q(c_a_idx_val), // Acaba direk +1 yapmak daha mi dogru
    .d(c_a_idx_next),
    .ce(c_a_idx_ce),
    .rst(c_a_idx_rst),
    .clk(clk));

  wire [31:0] c_b_idx_val, c_b_idx_next;
  wire c_b_idx_ce, c_b_idx_rst;
  REGISTER_R_CE #(.N(32), .INIT(16)) c_b_idx (
    .q(c_b_idx_val),
    .d(c_b_idx_next),
    .ce(c_b_idx_ce),
    .rst(c_b_idx_rst),
    .clk(clk));

  // Define a register for storing dot product result
  wire [WIDTH-1:0] result_val, result_next;
  wire result_ce, result_rst;
  REGISTER_R_CE #(.N(WIDTH), .INIT(0)) result (
    .q(result_val),
    .d(result_next),
    .ce(state_c_val), // degisti
    .rst(result_rst),
    .clk(clk));


  wire [WIDTH-1:0] sram_a_rdata, sram_b_rdata;
  // Note: write to SRAM is ACTIVE LOW
  wire sram_a_write = ~(a_fire && (state_a_val == STATE_A_IDLE || state_a_val == STATE_A_WRITE)); 
  wire sram_b_write = ~(b_fire && (state_b_val == STATE_B_IDLE || state_b_val == STATE_B_WRITE)); 
  wire sram_a_read = 1'b1;

SRAM2RW32x16 sram_a_b(
    .CE1(clk),
    .CE2(clk),
    .WEB1(sram_a_write),
    .WEB2(sram_b_write),
    .OEB1(1'b0),
    .OEB2(1'b0),
    .CSB1(1'b0),
    .CSB2(1'b0),

    .A1(a_idx_val),
    .A2(b_idx_val),
    .I1(a_data),
    .I2(b_data),
    .O1(sram_a_rdata),
    .O2(sram_b_rdata)
);

// FSM for writing vector a 
  always @(*) begin
    state_a_next = state_a_val;
    case (state_a_val)
      STATE_A_IDLE: begin
        // Wait until state_c not busy
        if (a_fire && state_c_val == STATE_C_IDLE)
          state_a_next = STATE_A_WRITE;
      end
      STATE_A_WRITE: begin
        // If we receive the final vector element, move to the done state
        if (a_fire && a_idx_val == 15)
          state_a_next = STATE_A_DONE;
      end
      STATE_A_DONE: begin
        if (state_c_val == STATE_C_DONE)
          state_a_next = STATE_A_IDLE;
      end
    endcase
  end

//   initial begin
//     $monitor("state_a_val: %d state_b_val: %d state_c_val: %d a_idx_val: %d b_idx_val: %d c_a_idx_val: %d c_a_idx_next: %d c_a_idx_ce: %d c_b_idx_val: %d", state_a_val, state_b_val, state_c_val, a_idx_val, b_idx_val, c_a_idx_val, c_a_idx_next,c_a_idx_ce, c_b_idx_val);
//   end
  initial begin
    $monitor("sram_a_rdata: %d sram_b_rdata: %d result_val: %d c_data: %d", sram_a_rdata, sram_b_rdata, result_val, c_data);
  end

  // FSM for writing vector b 
  always @(*) begin
    state_b_next = state_b_val;
    case (state_b_val)
      STATE_B_IDLE: begin
        // Wait until state_c not busy
        if (b_fire && state_c_val == STATE_C_IDLE)
          state_b_next = STATE_B_WRITE;
      end
      STATE_B_WRITE: begin
        // If we receive the final vector element, move to the done state
        if (b_fire && b_idx_val == 31)
          state_b_next = STATE_B_DONE;
      end
      STATE_B_DONE: begin
        if (state_c_val == STATE_C_DONE)
          state_b_next = STATE_B_IDLE;
      end
    endcase
  end

  // FSM for dot product computation
  always @(*) begin
    state_c_next = state_c_val;
    case (state_c_val)
      STATE_C_IDLE: begin
        // Only start the computation when we receive all vector elements
        if (state_a_val == STATE_A_DONE && state_b_val == STATE_B_DONE) begin
          state_c_next = STATE_C_COMPUTE;
        end
      end
      STATE_C_COMPUTE: begin
        if (c_a_idx_val == 15)
          state_c_next = STATE_C_DONE;
      end
      STATE_C_DONE: begin
        // When the result is transferred via R/V interface, time to reset
        // for the next computation
        if (c_fire)
          state_c_next = STATE_C_IDLE;
      end
    endcase
  end

  assign a_ready = (state_a_val == STATE_A_IDLE || state_a_val == STATE_A_WRITE);
  assign b_ready = (state_b_val == STATE_B_IDLE || state_b_val == STATE_B_WRITE);


  assign a_idx_ce   = a_fire && (a_idx_val < 15); //((a_fire && b_fire) || state_c_val) 
  assign a_idx_next = a_idx_val + 1; // bunlarin yonleri ters mi
  assign a_idx_rst  = (state_a_val == STATE_A_DONE) | rst;


  assign b_idx_ce   = b_fire && (b_idx_val < 31); //((a_fire && b_fire) || state_c_val) 
  assign b_idx_next = b_idx_val + 1;
  assign b_idx_rst  = (state_b_val == STATE_B_DONE) | rst;

  assign c_a_idx_ce = state_c_val == STATE_C_COMPUTE && (c_a_idx_val < 15); //((a_fire && b_fire) || state_c_val) 
  assign c_a_idx_rst = state_c_val == STATE_C_DONE || rst;
  assign c_a_idx_next = c_a_idx_val + 1;

  assign c_b_idx_ce = state_c_val == STATE_C_COMPUTE && (c_b_idx_val < 31); //((a_fire && b_fire) || state_c_val)  // yoksa 36 mi 
  assign c_b_idx_rst = state_c_val == STATE_C_DONE || rst;
  assign c_b_idx_next = c_b_idx_val + 1;

  // Delay state_c by one cycle since reading from SRAM takes one cycle
  wire [1:0] state_c_delay_val;
  REGISTER #(.N(2)) state_c_delay (.q(state_c_delay_val), .d(state_c_val), .clk(clk));


  // Dot product computation
  assign result_next = result_val + sram_a_rdata * sram_b_rdata;
  //assign result_ce   = (state_c_delay_val == STATE_C_COMPUTE);
  assign result_rst  = (state_c_delay_val == STATE_C_IDLE);

  assign c_data  = result_val;
  assign c_valid = (state_c_delay_val == STATE_C_DONE);

endmodule


