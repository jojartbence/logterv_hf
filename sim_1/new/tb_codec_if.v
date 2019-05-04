`timescale 1ns / 1ps

module tb_codec_if();

reg clk = 1;
reg rst = 0;

reg [23:0] test_float_a;
reg [23:0] test_float_b;
wire [23:0] test_float_out;
wire test_float_out_underflow;
wire test_float_out_overflow;


top_level tl_uut
(
   .clk           (clk),
   .rst           (rst),
   .float_a       (test_float_a),
   .float_b       (test_float_b),
   .float_out     (test_float_out),
   .float_out_underflow (test_float_out_underflow),
   .float_out_overflow (test_float_out_overflow)
);


always #1
   clk <= ~clk;

initial
begin
    #0 assign test_float_a = 24'b010000010100000000000000; //200,125
    #0 assign test_float_b = 24'b001111101000000000000000; //0,375
    #30 assign rst = 1;
    #5 assign rst = 0;
    #15 assign test_float_a = 24'b001101110101010011001001; //0,0051999688148498535
    #0  assign test_float_b = 24'b010001110000000000000000; //256
    
    #15 assign test_float_a = 24'b011111110000000000000000; 
    #0  assign test_float_b = 24'b010000000000000000000000; 
    
    #15 assign test_float_a = 24'b000000000000000000000000; 
    #0  assign test_float_b = 24'b001111100000000000000000;     
    


end


endmodule
