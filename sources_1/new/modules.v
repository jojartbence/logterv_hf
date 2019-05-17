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
   output [6:0] out_exp,
   output out_underflow,
   output out_overflow
);
    reg [7:0] out;
    reg underflow;
    reg overflow;
    reg [6:0] exp_a_local;      //TODO test if it is necessary
    reg [6:0] exp_b_local;
    
    always @ (posedge clk)
    begin
        exp_a_local <= in_exp_a;
        exp_b_local <= in_exp_b;
    end
    always @ (posedge clk)
    begin
        if(rst)
            out <= 0;
        else
        begin
            out <= exp_a_local + exp_b_local - 63;    //Substract the offset once because we added it two times
            underflow <= (exp_a_local + exp_b_local) < 63;
            overflow <= (exp_a_local + exp_b_local) > 190;
        end
    end
    assign out_exp = out [6:0];             //8th bit-> overflow?
    assign out_underflow = underflow;
    assign out_overflow = overflow;
endmodule



module multiplier
(
   input             clk,
   input             rst,
   input [15:0]  in_mantissa_a,
   input [15:0]  in_mantissa_b,
   output [17:0] out_mantissa
);

    reg [33:0] out;
    reg [15:0] mantissa_a_local;    //TODO test if it is necessary
    reg [15:0] mantissa_b_local;
    always @ (posedge clk)
    begin
        mantissa_a_local  <= in_mantissa_a;
        mantissa_b_local <= in_mantissa_b;
    end
    always @ (posedge clk)
    begin
        if(rst)
            out <= 0;
        else
            out <= {1'b1,mantissa_a_local} * {1'b1,mantissa_b_local};       //the fraction part doesnt contain the hidden 1
    end
    assign out_mantissa = out[33:16];       //Underflow detection?
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
    reg sign_a_local;       //TODO test if it is necessary (definitely not)
    reg sign_b_local;
    always @ (posedge clk)
    begin
        sign_a_local  <= in_sign_a;
        sign_b_local <= in_sign_b;
    end
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
   input [17:0]     in_mantissa,
   output [6:0]     out_exp_normalised,
   output [15:0]    out_mantissa_normalised,
   output out_overflow
);
    reg [6:0] exp;
    reg [15:0] mantissa;
    reg overflow;
    always @ (posedge clk)
    begin
        if(rst)
        begin
            mantissa <= 0;
            exp <= 0;
        end
        else
        begin
            if(in_mantissa[17] == 1)                
            begin
                overflow <= (in_exp == 127);
                exp <= in_exp + 1;
                mantissa <= in_mantissa[16:1];
            end
            else
            begin
                overflow <= 0;
                exp <= in_exp;
                mantissa <= in_mantissa[15:0];
            end
        end
    end
    assign out_exp_normalised = exp;
    assign out_mantissa_normalised = mantissa;
    assign out_overflow = overflow;
endmodule

