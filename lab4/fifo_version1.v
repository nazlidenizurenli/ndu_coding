//=========================================================================
// FIFO Template
//-------------------------------------------------------------------------
//
//`include "EECS151.v"

module fifo #(parameter WIDTH = 8, parameter LOGDEPTH = 3) (
    input clk,
    input reset,

    input enq_val,
    input [WIDTH-1:0] enq_data,
    output enq_rdy,

    output deq_val,
    output [WIDTH-1:0] deq_data,
    input deq_rdy

);

localparam DEPTH = (1 << LOGDEPTH);

// the buffer itself. Take note of the 2D syntax.
reg [WIDTH-1:0] buffer [DEPTH-1:0];
// read pointer
wire [LOGDEPTH-1:0] rptr;
// write pointer
wire [LOGDEPTH-1:0] wptr;
// is the buffer full? This is needed for when rptr == wptr
wire full;

// Define any additional regs or wires you need (if any) here

// use "fire" to indicate when a valid transaction has been made
// enq_rdy, deq_val
reg enq_rdy_reg;
assign enq_rdy = enq_rdy_reg;

reg full_reg;
assign full = full_reg;

reg [LOGDEPTH-1:0] wptr_reg;
assign wptr = wptr_reg;

reg [LOGDEPTH-1:0] rptr_reg;
assign rptr = rptr_reg;

wire enq_fire;
wire deq_fire;

assign enq_fire = enq_val & enq_rdy;
assign deq_fire = deq_val & deq_rdy;

assign deq_val = (wptr > rptr) || full;
assign deq_data = buffer[rptr];

always @(posedge clk) begin
    if (reset) begin
        enq_rdy_reg <= 1;
        full_reg <= 0;
        wptr_reg <= 0;
        rptr_reg <= 0;
    end else begin 
        if (enq_fire) begin
            buffer[wptr] <= enq_data;
            wptr_reg <= wptr + 1; 
                if (wptr + 1 == rptr) begin
                    full_reg <= 1;
                    enq_rdy_reg <= 0;
                end
        end 
        if (deq_fire) begin
            rptr_reg <= rptr + 1;
            enq_rdy_reg <= 1;
            full_reg <= 0;
        end 
    end
end
endmodule