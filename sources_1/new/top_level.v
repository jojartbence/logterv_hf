`timescale 1ns / 1ps


module top_level(  
    input             clk,
    input             rst,
    
    input [23:0]    float_a,
    input [23:0]    float_b,
    output [23:0]   float_out,
    output float_out_overflow,
    output float_out_underflow
);


wire [6:0] out_exp;
wire [6:0] normalised_exp;
wire [17:0] out_mantissa;
wire [15:0] normalised_mantissa;
reg out_sign_delayer;
wire out_sign;
reg [23:0] out;

wire adder_underflow;
wire adder_overflow;
wire normalizer_overflow;
wire normalizer_underflow;

reg overflow;
reg underflow;

adder uut_adder
(
    .clk    (clk),
    .rst    (rst),
    .in_exp_a (float_a[22:16]),
    .in_exp_b (float_b[22:16]),
    .out_exp (out_exp),
    .out_underflow (adder_underflow),
    .out_overflow (adder_overflow)
);

multiplier uut_multiplier
(
    .clk    (clk),
    .rst    (rst),
    .in_mantissa_a (float_a[15:0]),
    .in_mantissa_b (float_b[15:0]),
    .out_mantissa (out_mantissa)
);

normaliser uut_normaliser
(
    .clk    (clk),
    .rst    (rst),
    .in_exp (out_exp),
    .in_mantissa (out_mantissa),
    .in_adder_underflow (adder_underflow),
    .in_adder_overflow (adder_overflow),
    .out_exp_normalised (normalised_exp),
    .out_mantissa_normalised (normalised_mantissa),
    .out_overflow (normalizer_overflow),
    .out_underflow (normalizer_underflow)
);

signbit uut_signbit
(
    .clk (clk),
    .rst (rst),
    .in_sign_a (float_a[23]),
    .in_sign_b (float_b[23]),
    .out_sign (out_sign)
);
    
always @ (posedge clk)
begin
    out_sign_delayer <= out_sign;
end

always @ (posedge clk)
begin
    out[23] <= out_sign_delayer;
    out[22:16] <= normalised_exp;
    out[15:0] <= normalised_mantissa;
    overflow <= normalizer_overflow;
    underflow <= normalizer_underflow;
end
assign float_out = out;
assign float_out_overflow = overflow;
assign float_out_underflow = underflow;

endmodule
