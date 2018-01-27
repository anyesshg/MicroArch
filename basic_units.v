module not_1b(
	input a,
	output abar);
	nand2$ g1(abar,a,1'b1);
endmodule

module and_1b(
	input a,b,
	output ab);
	wire i;
	nand2$ g1(i,a,b),
		   g2(ab,i,1'b1);
endmodule

module xor_1b(
	input a,b,
	output xab);
	wire w1,w2,w3,w4;
	nand2$  g1(w1,a,1'b1),
			g2(w2,b,1'b1),
			g3(w3,w1,b),
			g4(w4,w2,a),
			g5(xab,w3,w4);
endmodule

module fa_1b(
	input a,b,c_in,
	output c_out,s);
	wire w1,w2,w3;
	xor_1b  x1(a,b,w1),
			x2(c_in,w1,s);
	nand2$  g1(w2,a,b),
			g2(w3,w1,c_in),
			g3(c_out,w3,w2);
endmodule

module overflowChk(
	input a,b,o,
	output overflow);
	wire w1,w2,w3,w4;
	xor_1b	x1(a,b,w1),
			x2(a,o,w2);
	nand2$	g1(w3,w1,w2),
			g2(w4,w3,1'b1),
			g3(overflow,w4,1'b1);
endmodule

module _21mux_1b(
	input s,x,y,
	output o);
	wire sbar,w1,w2;
	not_1b  n1(s,sbar);
	nand2$  g1(w1,sbar,x),
			g2(w2,s,y),
			g3(o,w1,w2);
endmodule

module_41mux_1b(
	input [1:0]s,
	input a0,a1,a2,a3,
	output o);
	wire w1,w2;
	_21mux_1b	m1(s[0],a0,a1,w1),
				m2(s[1],a2,a3,w2),
				m3(s[1],w1,w2,o);
endmodule