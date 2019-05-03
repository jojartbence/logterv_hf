`timescale 1ns / 1ps
//16 bit frac
//1 sign
//7 exp

module adder
(
   input             clk,
   input             rst,
   input [6:0]  in_exp_a,
   input [6:0]  in_exp_b,
   output [6:0] out_exp
);
    reg [7:0] out;
    always @ (posedge clk)
    begin
        if(rst)
            out <= 0;
        else
            out <= in_exp_a + in_exp_b - 63;    //Substract the offset once because we added it two times
    end
    assign out_exp = out [6:0];             //8th bit-> overflow?
endmodule



module multiplier
(
   input             clk,
   input             rst,
   input [15:0]  in_mantissa_a,
   input [15:0]  in_mantissa_b,
   output [33:0] out_mantissa
);

    reg [33:0] out;
    always @ (posedge clk)
    begin
        if(rst)
            out <= 0;
        else
            out <= {1'b1,in_mantissa_a} * {1'b1,in_mantissa_b};       //the fraction part doesn't contain the hidden 1
    end
    assign out_mantissa = out[33:0];       //Underflow detection?
endmodule


module signbit
(
    input clk,
    input rst,
    input in_sign_a,
    input in_sign_b,
    output out_sign
);
    reg out;
    always @ (posedge clk)
    begin
        if(rst)
            out <= 0;
        else
            out <= in_sign_a ^ in_sign_b;
    end
    assign out_sign = out;
    
endmodule


module normaliser
(
   input            clk,
   input            rst,
   input [6:0]      in_exp,
   input [33:0]     in_mantissa,
   output [6:0]     out_exp_normalised,
   output [15:0]    out_mantissa_normalised
);
    reg [6:0] exp;
    reg [15:0] mantissa;
    always @ (posedge clk)
    begin
        if(rst)
        begin
            mantissa <= 0;
            exp <= 0;
        end
        else
        begin
            if(in_mantissa[33] == 1)                
            begin
                exp <= in_exp + 1;
                mantissa <= in_mantissa[32:17];
            end
            else
            begin
                exp <= in_exp;
                mantissa <= in_mantissa[31:16];
            end
        end
    end
    assign out_exp_normalised = exp;
    assign out_mantissa_normalised = mantissa;
endmodule


