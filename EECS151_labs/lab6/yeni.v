// Implement a vector dot product of a and b
// using a single-port SRAM of 5-bit address width, 16-bit data width

module dot_product_1SRAM #(parameter WIDTH = 16) 
(
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

  // There are a few state machines that accomplish the following things
  // - Enqueue a_data to sram_a via R/V interface
  // - Enqueue b_data to sram_b via R/V interface
  // - Start the dot product computation
  // - Dequeue the dot product result via R/V

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

  initial begin
    //$monitor("Product: %d %d %d %d %d %d %d %d %d %d\n", $time, sram_a_write, sram_a_read, a_idx_val, b_idx_val, c_idx_val, a_data, sram_a_rdata,c_data, result_next);
    //$monitor("Result %d %d %d %d %d\n", $time, result_next, result_val, sram_a_rdata, sram_b_rdata);
    //$monitor("monitor %d %d %d %d\n", $time, a_idx_val,b_idx_val,c_idx_val);

  end
    //$display("state ler: %d %d %d\n", state_a_next, state_b_next, state_c_next);

  // Define state registers
  reg [1:0] state_a_val;
  reg [1:0]  state_a_next;
  /*
  REGISTER_R #(.N(2), .INIT(STATE_A_IDLE)) state_a (
    .q(state_a_val),
    .d(state_a_next),
    .rst(rst),
    .clk(clk));
  */
  reg [1:0] state_b_val;
  reg [1:0]  state_b_next;
  /*
  REGISTER_R #(.N(2), .INIT(STATE_B_IDLE)) state_b (
    .q(state_b_val),
    .d(state_b_next),
    .rst(rst),
    .clk(clk));
  */
  reg [1:0] state_c_val;
  reg [1:0] state_c_next;
  /*
  REGISTER_R #(.N(2), .INIT(STATE_C_IDLE)) state_c (
    .q(state_c_val),
    .d(state_c_next),
    .rst(rst),
    .clk(clk));
  */
  // Define address registers (or loop index registers)

  // This register keeps track of writing vector a to sram_a
  reg [31:0] a_idx_val;
  wire a_idx_next;
  wire a_idx_ce, a_idx_rst;
  //assign a_idx_next = a_idx_val;

  /*
  REGISTER_R_CE #(.N(32), .INIT(0)) a_idx (
    .q(a_idx_val),
    .d(a_idx_next),
    .ce(a_idx_ce),
    .rst(a_idx_rst),
    .clk(clk));
  */
  // This register keeps track of writing vector b to sram_b
  reg [31:0] b_idx_val;
  wire b_idx_next;
  wire b_idx_ce, b_idx_rst;
  //assign b_idx_next = b_idx_val;
  /*
  REGISTER_R_CE #(.N(32), .INIT(0)) b_idx (
    .q(b_idx_val),
    .d(b_idx_next),
    .ce(b_idx_ce),
    .rst(b_idx_rst),
    .clk(clk));
  */
  // This register keeps track of reading vector data from sram_a and sram_b
  reg [31:0] ca_idx_val;
  reg [31:0] cb_idx_val;

  wire c_idx_next;
  wire c_idx_ce, c_idx_rst;
  //assign c_idx_next =c_idx_val;
  /*
  REGISTER_R_CE #(.N(32), .INIT(0)) c_idx (
    .q(c_idx_val),
    .d(c_idx_next),
    .ce(c_idx_ce),
    .rst(c_idx_rst),
    .clk(clk));
  */
  // Define a register for storing dot product result
  reg [WIDTH-1:0] result_val;
  wire result_next;
  wire result_ce, result_rst;
  //assign result_next = result_val;
  /*
  REGISTER_R_CE #(.N(WIDTH), .INIT(0)) result (
    .q(result_val),
    .d(result_next),
    .ce(result_ce),
    .rst(result_rst),
    .clk(clk));
  */
  // How to deal with SRAM interfaces
  // - CEi: clock signal
  // - WEBi: write enable bar  (HIGH: read, LOW: write)
  // - OEBi: output enable bar (always tie to LOW)
  // - CSBi: chip select bar   (always tie to LOW)
  // - Ai: address pin (input)
  // - Ii: write data (input)
  // - Oi: output/read data (output)
  // Note that: the SRAMs are synchronus-read, synchronous-write
  // It takes one-cycle read, and one-cycle write

  wire [WIDTH-1:0] sram_a_rdata, sram_b_rdata;
  // Note: write to SRAM is ACTIVE LOW
  wire sram_write = ~(a_fire && (state_a_val == STATE_A_IDLE || state_a_val == STATE_A_WRITE));
  //wire sram_b_write = ~(b_fire && (state_b_val == STATE_B_IDLE || state_b_val == STATE_B_WRITE));
  wire sram_read = 1'b1;
  //wire sram_b_read = 1'b1;

  // 16 x 16-bit SRAM (16 entries with 16-bit each)
  // Used for storing and reading vector a
  SRAM2RW32x16 sram_a (
    .CE1(clk),
    .CE2(clk),
    .WEB1(sram_write), // write
    .WEB2(sram_write),  // read
    .OEB1(1'b0),         // always tie to LOW
    .OEB2(1'b0),         // always tie to LOW
    .CSB1(1'b0),         // always tie to LOW
    .CSB2(1'b0),         // always tie to LOW

    .A1(a_idx_val),      // input
    .A2(b_idx_val),      // input
    .I1(a_data),         // input
    .I2(b_data),         // input
    .O1(sram_a_rdata),   // output
    .O2(sram_b_rdata)    // output
  );

  // 16 x 16-bit SRAM (16 entries with 16-bit each)
  // Used for storing and reading vector b

  // FSM for writing vector a to sram_a
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

        if (a_fire && a_idx_val == vector_size - 1)
          state_a_next = STATE_A_DONE;
  
      end
      STATE_A_DONE: begin
        if (state_c_val == STATE_C_DONE)
          state_a_next = STATE_A_IDLE;
      end
    endcase
  end

  // FSM for writing vector b to sram_b
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

        if (b_fire && b_idx_val == (2*vector_size) - 1)
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
          a_idx_val = 0; b_idx_val = 16; ca_idx_val = 0; cb_idx_val = 16;
        end  
      end
      STATE_C_COMPUTE: begin
        if (ca_idx_val == vector_size - 1)
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

  //assign a_idx_next = (a_fire && b_fire) ? a_idx_val + 1 : 0;
  assign a_idx_ce   = (a_fire);
  assign a_idx_rst  = (state_a_val == STATE_A_DONE) | rst;

  //assign b_idx_next = (a_fire && b_fire) ? b_idx_val + 1 : 0;
  assign b_idx_ce   = (b_fire);
  assign b_idx_rst  = (state_b_val == STATE_B_DONE) | rst;

  //assign c_idx_next = (a_fire && b_fire) ? c_idx_val + 1 : 0;
  assign c_idx_ce   = (state_c_val == STATE_C_COMPUTE);
  assign c_idx_rst  = (state_c_val == STATE_C_DONE) | rst;

  // Delay state_c by one cycle since reading from SRAM takes one cycle
  wire [1:0] state_c_delay_val;
  //REGISTER #(.N(2)) state_c_delay (.q(state_c_delay_val), .d(state_c_val), .clk(clk));

  // Dot product computation
  //assign result_next = (state_c_val) ? result_val + sram_a_rdata * sram_b_rdata : result_next;
  assign result_ce   = (state_c_delay_val == STATE_C_COMPUTE);
  assign result_rst  = (state_c_delay_val == STATE_C_IDLE);

  assign c_data  = result_val;
  assign c_valid = (state_c_val == STATE_C_DONE);

  always @ (posedge clk) begin

	  if(rst) begin
		  result_val <= 0;
      a_idx_val <= 0;
      b_idx_val <= 16;
      ca_idx_val <= 0;
      cb_idx_val <= 16;

      state_a_val <= STATE_A_IDLE;
      state_b_val <= STATE_B_IDLE;
      state_c_val <= STATE_C_IDLE;
      //$display("Reset: %d %d %d %d %d\n",$time,a_idx_val,b_idx_val,ca_idx_val, result_val);

	  end else begin
      state_a_val <= state_a_next;
      state_b_val <= state_b_next;
      state_c_val <= state_c_next;
      a_idx_val <= (((a_fire && b_fire) || state_c_val) && a_idx_val < vector_size - 1) ? a_idx_val + 1 : a_idx_val;
      b_idx_val <= (((a_fire && b_fire) || state_c_val) && b_idx_val < (2*vector_size) - 1) ? b_idx_val + 1 : b_idx_val;
      ca_idx_val <= (((a_fire && b_fire) || state_c_val) && ca_idx_val < vector_size - 1) ? ca_idx_val + 1 : ca_idx_val;
      cb_idx_val <= (((a_fire && b_fire) || state_c_val) && cb_idx_val < (2*vector_size) - 1) ? cb_idx_val + 1 : cb_idx_val;

      result_val <= (state_c_val) ? result_val + sram_a_rdata * sram_b_rdata: result_val;
      //$display("Bak: %d %d %d %d %d %d %d %d %d %d\n",$time,a_fire,b_fire, a_idx_val,b_idx_val,c_idx_val, result_next, result_val,sram_a_rdata, sram_b_rdata);
      //$display("Bak.....: %d (%d %d %d) (%d %d %d) (%d %d %d %d) (%d %d) (%d %d) (%d %d)\n",$time,state_a_val,state_b_val,state_c_val, a_fire,b_fire,c_fire, a_idx_val,b_idx_val,ca_idx_val,cb_idx_val, sram_a_rdata, sram_b_rdata, sram_write, sram_read, result_next,result_val);


	end

end

endmodule