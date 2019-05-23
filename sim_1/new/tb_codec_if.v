`timescale 1ns / 1ps

module tb_codec_if();

reg clk = 0;
reg rst = 0;

reg [23:0] test_float_a;
reg [23:0] test_float_b;

reg [23:0] input_float_a;
reg [23:0] input_float_b;
wire [23:0] test_float_out;

wire test_float_out_underflow;
wire test_float_out_overflow;


top_level tl_uut
(
   .clk           (clk),
   .rst           (rst),
   .float_a       (input_float_a),
   .float_b       (input_float_b),
   .float_out     (test_float_out),
   .float_out_underflow (test_float_out_underflow),
   .float_out_overflow (test_float_out_overflow)
);

//Generate the clock
always #1.031
   clk <= ~clk;

//Set the starting and ending point of the test interval
real starting = -30;
real ending = 30;
real step_size = 0.1;   //Granularity of the intervall
real offset_between_inputs = 8;     //The difference between the 2 input float

reg [63:0] input_temp_f64_a;
reg [63:0] input_temp_f64_b;
real a;
initial
begin
    for(a = starting; a < ending; a = a + step_size)
    begin
        input_temp_f64_a <= $realtobits(a);     //Convert real number to double float
        input_temp_f64_b <= $realtobits(a + offset_between_inputs);     //Convert real number to double float
        #2.062                           //Wait 1 clock period and set the input of the 
        //Convert double to single
        input_float_a [22:16] <= input_temp_f64_a[62:52] + 1023 - 63;   //modify the offset, and truncate the exponent
        input_float_a[15:0] <= input_temp_f64_a[51:36];                 //truncate the fraction
        input_float_a[23] <= input_temp_f64_a[63];                      //copy the sign bit
        
        input_float_b [22:16] <= input_temp_f64_b[62:52] + 1023 - 63;   //modify the offset, and truncate the exponent
        input_float_b[15:0] <= input_temp_f64_b[51:36];                 //truncate the fraction
        input_float_b[23] <= input_temp_f64_b[63];                      //copy the sign bit
    end
end


reg [63:0] trunced_f64_a;
reg [63:0] trunced_f64_b;
reg [23:0] output_check;
reg [63:0] output_temp_f64;

real rounded_real_a;
real rounded_real_b;
real b;
initial
begin
    #11.341; //The input-output delay, in ns
    for(b = starting; b < ending; b = b + step_size)
    begin
        //First, we have to truncate the float64, because the resolution difference will cause a difference
        //in the multiplication
        trunced_f64_a <= $realtobits(b);  
        trunced_f64_b <= $realtobits(b + offset_between_inputs);  
        #0.1 
        trunced_f64_a[35:0] <= 35'b0; //Cut of the extra part
        trunced_f64_b[35:0] <= 35'b0; //Cut of the extra part
        #0.1
        rounded_real_a <= $bitstoreal(trunced_f64_a);  //Then convert it back to real decimal number
        rounded_real_b <= $bitstoreal(trunced_f64_b);  //Then convert it back to real decimal number
        #0.1
        output_temp_f64 <= $realtobits(rounded_real_a * rounded_real_b);  //Do the multiplication with the rounded numbers
        #1.762
        //And do the same conversiona as the input part
        output_check [22:16] <= output_temp_f64[62:52] + 1023 - 63;
        output_check[15:0] <= output_temp_f64[51:36];
        output_check[23] <= output_temp_f64[63];       
    end
end

real c; //We dont use this variable, just for the iterating purpose
integer mismatch = 0;
integer correct = 0;
initial
begin
    #11.441; //The input-output delay + 0.1ns, in ns
    for(c = starting; c < ending; c = c + step_size)
    begin
    #2.062
        if(output_check == test_float_out)
            correct <= correct + 1;        
        else
            mismatch <= mismatch +1;
    end
end


endmodule
