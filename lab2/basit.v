module basit3;

wire a;
reg b = 0;

assign a = 1;

always @(*) begin
    //a = 1;
    b = 1;
    $display("aaaaaaaa:%d %d\n", a, b);
    
end

endmodule