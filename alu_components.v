module not_16b(
	input [15:0] a,
	output [15:0] abar);
	not_1b n1(a[0],abar[0]),
			n2(a[1],abar[1]),
			n3(a[2],abar[2]),
			n4(a[3],abar[3]),
			n5(a[4],abar[4]),
			n6(a[5],abar[5]),
			n7(a[6],abar[6]),
			n8(a[7],abar[7]),
			n9(a[8],abar[8]),
			n10(a[9],abar[9]),
			n11(a[10],abar[10]),
			n12(a[11],abar[11]),
			n13(a[12],abar[12]),
			n14(a[13],abar[13]),
			n15(a[14],abar[14]),
			n16(a[15],abar[15]);
endmodule


module and_16b(
	input [15:0] a,b,
	output [15:0] ab);
	and_1b a1(a[0],b[0],ab[0]),
			a2(a[1],b[1],ab[1]),
			a3(a[2],b[2],ab[2]),
			a4(a[3],b[3],ab[3]),
			a5(a[4],b[4],ab[4]),
			a6(a[5],b[5],ab[5]),
			a7(a[6],b[6],ab[6]),
			a8(a[7],b[7],ab[7]),
			a9(a[8],b[8],ab[8]),
			a10(a[9],b[9],ab[9]),
			a11(a[10],b[10],ab[10]),
			a12(a[11],b[11],ab[11]),
			a13(a[12],b[12],ab[12]),
			a14(a[13],b[13],ab[13]),
			a15(a[14],b[14],ab[14]),
			a16(a[15],b[15],ab[15]);
endmodule

module add_8b(
	input [7:0] a,b,
	output [7:0] sum,
	output carry);
	fa_1b   s1(a[0],b[0],1'b0,c1,sum[0]),
			s2(a[1],b[1],c1,c2,sum[1]),
			s3(a[2],b[2],c2,c3,sum[2]),
			s4(a[3],b[3],c3,c4,sum[3]),
			s5(a[4],b[4],c4,c5,sum[4]),
			s6(a[5],b[5],c5,c6,sum[5]),
			s7(a[6],b[6],c6,c7,sum[6]),
			s8(a[7],b[7],c7,c8,sum[7]);
endmodule

module add_16b(
	input [15:0] a,b,
	output [15:0] sum,
	output carry);
	fa_1b   s1(a[0],b[0],1'b0,c1,sum[0]),
			s2(a[1],b[1],c1,c2,sum[1]),
			s3(a[2],b[2],c2,c3,sum[2]),
			s4(a[3],b[3],c3,c4,sum[3]),
			s5(a[4],b[4],c4,c5,sum[4]),
			s6(a[5],b[5],c5,c6,sum[5]),
			s7(a[6],b[6],c6,c7,sum[6]),
			s8(a[7],b[7],c7,c8,sum[7]),
			s9(a[8],b[8],c8,c9,sum[8]),
			s10(a[9],b[9],c9,c10,sum[9]),
			s11(a[10],b[10],c10,c11,sum[10]),
			s12(a[11],b[11],c11,c12,sum[11]),
			s13(a[12],b[12],c12,c13,sum[12]),
			s14(a[13],b[13],c13,c14,sum[13]),
			s15(a[14],b[14],c14,c15,sum[14]),
			s16(a[15],b[15],c15,carry,sum[15]);
endmodule

module _21mux_8b(
	input s,
	input [7:0] a,b,
	output [7:0] out);
	_21mux_1b   m1(s,a[0],b[0],out[0]),
				m2(s,a[1],b[1],out[1]),
				m3(s,a[2],b[2],out[2]),
				m4(s,a[3],b[3],out[3]),
				m5(s,a[4],b[4],out[4]),
				m6(s,a[5],b[5],out[5]),
				m7(s,a[6],b[6],out[6]),
				m8(s,a[7],b[7],out[7]);
endmodule

module _41mux_16b(
	input [1:0] sel,
	input [15:0] a0,a1,a2,a3,
	output [15:0] o);
	_41mux_1b   m1(sel,a0[0],a1[0],a2[0],a3[0],o[0]),
				m2(sel,a0[1],a1[1],a2[1],a3[1],o[1]),
				m3(sel,a0[2],a1[2],a2[2],a3[2],o[2]),
				m4(sel,a0[3],a1[3],a2[3],a3[3],o[3]),
				m5(sel,a0[4],a1[4],a2[4],a3[4],o[4]),
				m6(sel,a0[5],a1[5],a2[5],a3[5],o[5]),
				m7(sel,a0[6],a1[6],a2[6],a3[6],o[6]),
				m8(sel,a0[7],a1[7],a2[7],a3[7],o[7]),
				m9(sel,a0[8],a1[8],a2[8],a3[8],o[8]),
				m10(sel,a0[9],a1[9],a2[9],a3[9],o[9]),
				m11(sel,a0[10],a1[10],a2[10],a3[10],o[10]),
				m12(sel,a0[11],a1[11],a2[11],a3[11],o[11]),
				m13(sel,a0[12],a1[12],a2[12],a3[12],o[12]),
				m14(sel,a0[13],a1[13],a2[13],a3[13],o[13]),
				m15(sel,a0[14],a1[14],a2[14],a3[14],o[14]),
				m16(sel,a0[15],a1[15],a2[15],a3[15],o[15]);
endmodule


module satadd_16b(
	input [15:0] a,b,
	output [15:0] sat);
	wire [7:0] satval0,satval1,sum0,sum1;
	wire c0,c1,overflow0,overflow1;
	
	assign satval0 = {a[7],~{7{a[7]}}};
	assign satval1 = {a[15],~{7{a[15]}}};
	
	add_8b  		a1(a[7:0],b[7:0],sum0,c0),
					a2(a[15:8],b[15:8],sum1,c1);
	overflowChk		oc1(a[7],b[7],sum0[7],overflow0),
					oc2(a[15],b[15],sum1[7],overflow1);
	_21mux_1b		mux1(overflow0,sum0,satval0,sat[7:0]),
					mux2(overflow1,sum1,satval1,sat[15:8]);
	
endmodule