module alu_top(
	input [15:0] a,b,
	input [1:0] sel,
	output [15:0] out);
	wire [15:0] o_1,o_2,o_3,o_4;
	wire carry_out;
	
	not_16b 	not1(b,o_1);
	and_16b 	and1(a,b,o_2);
	add_16b 	add1(a,b,o_3,carry_out);
	satadd_16b	satadd1(a,b,o_4);
	_41mux_16b	mux(sel,o_1,o_2,o_3,o_4,out);
endmodule