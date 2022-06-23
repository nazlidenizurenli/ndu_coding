`timescale 1ns / 1ps

module fifo_tb();

 // Inputs

 reg clk;
 reg [31:0] enq_data;
 reg enq_val;
 reg deq_rdy;
 reg reset;

 // Outputs
 wire [31:0] deq_data;
 wire deq_val;
 wire enq_rdy;

 // Instantiate the Unit Under Test (DUT)
fifo dut (
                  .clk(clk),
                  .reset(reset), 
                  .enq_val(enq_val), 
                  .enq_data(enq_data), 
                  .enq_rdy(enq_rdy), 
                  .deq_val(deq_val), 
                  .deq_data(deq_data), 
                  .deq_rdy(deq_rdy) 
                  );
 
always @(posedge clk) begin
    $display("At **  time: %d clk %d, datain %d, enq_rdy %d, enq_val %d, deq_rdy %d, deq_data %d Reset %d",
       $time, clk, enq_data, enq_rdy, enq_val, deq_rdy, deq_data, reset);
 end
                 
 initial begin
  // Initialize Inputs
    clk  = 1'b0;
    enq_data  = 32'd0;
    enq_val  = 1'b0;
    deq_rdy  = 1'b0;
    reset  = 1'b1;
  // Wait 100 ns for global reset to finish
    #20; 
       
  // Add stimulus here (write)
    enq_val  = 1'b1;
    deq_rdy  = 1'b1;
    reset  = 1'b0;

    enq_data  = 32'd25;    
    #20;
    enq_data  = 32'd35;
    #20;
    enq_data  = 32'd45;
    #20;
    enq_data  = 32'd55;
    #20;
    enq_data  = 32'd65;
    #20;
    enq_data  = 32'd75; 
    #20;
    enq_data  = 32'd85; 
    #20;
    enq_data  = 32'd95;     
    #30;
  /**  
    enq_val  = 1'b0;
    deq_rdy  = 1'b1;
    #180;

  // Initialize Inputs
    clk  = 1'b0;
    enq_data  = 32'h0;
    enq_val  = 1'b0;
    deq_rdy  = 1'b0;
    reset  = 1'b1;
  // Wait 100 ns for global reset to finish
    #20;        
  // Add stimulus here
    enq_val  = 1'b1;
    deq_rdy  = 1'b0;
    reset  = 1'b0;

    enq_data  = 32'h96; 
    #20;
    enq_data  = 32'h97; 
    #20;
    enq_data  = 32'h98; 
    #40;
    
    enq_val  = 1'b0;
    deq_rdy  = 1'b1;
    #100;
*/
    $finish();
  
 end 

   always #10 clk = ~clk;    

endmodule