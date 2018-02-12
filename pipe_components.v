//Pointers and PC are not in a register file for the time being. They are just individual registers.
module arch_regfile(
    input [31:0] in0,
    input [2:0] r0,
    input [2:0] r1,
    input    re0,
    input     re1,
    input [2:0] wr,
    input wen,
    output [31:0] out0,
    output [31:0] out1,
    input clk);

regfile8x8$    reg0(in0[7:0],r0,r1,re0,re1,wr,wen,out0[7:0],out1[7:0],clk),
            reg1(in0[15:8],r0,r1,re0,re1,wr,wen,out0[15:8],out1[15:8],clk),
            reg2(in0[23:16],r0,r1,re0,re1,wr,wen,out0[23:16],out1[23:16],clk),
            reg3(in0[31:24],r0,r1,re0,re1,wr,wen,out0[31:24],out1[31:24],clk);    
endmodule

module or_32b(
    input [31:0] a,b,
    output [31:0] o);
	or2$	o1(o[0],a[0],b[0]),
			o2(o[1],a[1],b[1]),
	        o3(o[2],a[2],b[2]),
	        o4(o[3],a[3],b[3]),
	        o5(o[4],a[4],b[4]),
	        o6(o[5],a[5],b[5]),
	        o7(o[6],a[6],b[6]),
	        o8(o[7],a[7],b[7]),
	        o9(o[8],a[8],b[8]),
	        o10(o[9],a[9],b[9]),
	        o11(o[10],a[10],b[10]),
	        o12(o[11],a[11],b[11]),
	        o13(o[12],a[12],b[12]),
	        o14(o[13],a[13],b[13]),
	        o15(o[14],a[14],b[14]),
	        o16(o[15],a[15],b[15]),
	        o17(o[16],a[16],b[16]),
	        o18(o[17],a[17],b[17]),
	        o19(o[18],a[18],b[18]),
	        o20(o[19],a[19],b[19]),
	        o21(o[20],a[20],b[20]),
	        o22(o[21],a[21],b[21]),
	        o23(o[22],a[22],b[22]),
	        o24(o[23],a[23],b[23]),
	        o25(o[24],a[24],b[24]),
	        o26(o[25],a[25],b[25]),
	        o27(o[26],a[26],b[26]),
	        o28(o[27],a[27],b[27]),
			o29(o[28],a[28],b[28]),
			o30(o[29],a[29],b[29]),
			o31(o[30],a[30],b[30]),
			o32(o[31],a[31],b[31]);			
endmodule     

module add_16b(
    input [15:0] a,b,
    input cin,
    output [15:0] sum,
    output carry);
    fa_1b   s1(a[0],b[0],cin,c1,sum[0]),
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

module xor_tree(
	input [31:0] in,
	output parity);
	wire w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17,w18,w19,w20,w21,w22,w23,w24,w25,w26,w27,w28,w29;
	//----------STAGE 1 wires-----------
	xor2$ 	x0 (w0 ,in[0] ,in[1]),
			x1 (w1 ,in[2] ,in[3]),
			x2 (w2 ,in[4] ,in[5]),
			x3 (w3 ,in[6] ,in[7]),
			x4 (w4 ,in[8] ,in[9]),
			x5 (w5 ,in[10],in[11]),
			x6 (w6 ,in[12],in[13]),
			x7 (w7 ,in[14],in[15]),
			x8 (w8 ,in[16],in[17]),
			x9 (w9 ,in[18],in[19]),
			x10(w10,in[20],in[21]),
			x11(w11,in[22],in[23]),
			x12(w12,in[24],in[25]),
			x13(w13,in[26],in[27]),
			x14(w14,in[28],in[29]),
			x15(w15,in[30],in[31]);
	
	//-----------STAGE 2 wires------------
	xor2$ 	x16 (w16 ,w0 ,w1),
			x17 (w17 ,w2 ,w3),
			x18 (w18 ,w4 ,w5),
			x19 (w19 ,w6 ,w7),
			x20 (w20 ,w8 ,w9),
			x21 (w21 ,w10,w11),
			x22 (w22 ,w12,w13),
			x23 (w23 ,w14,w15);
	//-----------STAGE 3 wires------------
	xor2$ 	x24 (w24 ,w16 ,w17),
			x25 (w25 ,w18 ,w19),
			x26 (w26 ,w20 ,w21),
			x27 (w27 ,w22 ,w23);
	//-----------STAGE 4 wires------------
	xor2$	x28 (w28,w24,w25),
			x29 (w29,w26,w27);
	//-----------STAGE 5 wires------------
	xor2$	x30(parity,w28,w29);
endmodule

module or_tree(
	input [31:0] in,
	output zero);
	wire w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17,w18,w19,w20,w21,w22,w23,w24,w25,w26,w27,w28,w29;
	//----------STAGE 1 wires-----------
	or2$ 	x0 (w0 ,in[0] ,in[1]),
			x1 (w1 ,in[2] ,in[3]),
			x2 (w2 ,in[4] ,in[5]),
			x3 (w3 ,in[6] ,in[7]),
			x4 (w4 ,in[8] ,in[9]),
			x5 (w5 ,in[10],in[11]),
			x6 (w6 ,in[12],in[13]),
			x7 (w7 ,in[14],in[15]),
			x8 (w8 ,in[16],in[17]),
			x9 (w9 ,in[18],in[19]),
			x10(w10,in[20],in[21]),
			x11(w11,in[22],in[23]),
			x12(w12,in[24],in[25]),
			x13(w13,in[26],in[27]),
			x14(w14,in[28],in[29]),
			x15(w15,in[30],in[31]);
	
	//-----------STAGE 2 wires------------
	or2$ 	x16 (w16 ,w0 ,w1),
			x17 (w17 ,w2 ,w3),
			x18 (w18 ,w4 ,w5),
			x19 (w19 ,w6 ,w7),
			x20 (w20 ,w8 ,w9),
			x21 (w21 ,w10,w11),
			x22 (w22 ,w12,w13),
			x23 (w23 ,w14,w15);
	//-----------STAGE 3 wires------------
	or2$ 	x24 (w24 ,w16 ,w17),
			x25 (w25 ,w18 ,w19),
			x26 (w26 ,w20 ,w21),
			x27 (w27 ,w22 ,w23);
	//-----------STAGE 4 wires------------
	or2$	x28 (w28,w24,w25),
			x29 (w29,w26,w27);
	//-----------STAGE 5 wires------------
	or2$	x30(n_zero,w28,w29);
	inv1$	i(zero,n_zero);
endmodule

module bb_mem(
    input clk,
    input [31:0] rdaddr,
    input [31:0] wraddr,
    input rdvld,
    input wrvld,
    input [31:0] wrdata,
    output [47:0] rddata);
    //Very simple Memory black box model. Generates random output data, so can't be used to verify loads & stores.
    reg [63:0] random_data;
    assign rddata = random_data[47:0];
    initial begin
	random_data = 64'hf0f0_f0f0_f0f0_f0f0;
       //random_data = {$random,$random};
    end
	//Use random otherwise, fixed output to check ADD & OR operations.
    always @(posedge clk) begin
	if(rdvld) begin
        #1 if(random_data == 64'hf0f0_f0f0_f0f0_f0f0) begin
		random_data = 64'b0;
	   end else begin
		random_data = 64'hf0f0_f0f0_f0f0_f0f0;
	   end
	end
    end
    
endmodule


module _32bmaskedreg(
    input [31:0] in,
    input [31:0] mask,
    input clk,
    input rst,
    output [31:0] reg_val);
    wire [31:0] d;
    mux2$    m0(d[0],mask[0],reg_val[0],in[0]),
            m1(d[1],mask[1],reg_val[1],in[1]),
            m2(d[2],mask[2],reg_val[2],in[2]),
            m3(d[3],mask[3],reg_val[3],in[3]),
            m4(d[4],mask[4],reg_val[4],in[4]),
            m5(d[5],mask[5],reg_val[5],in[5]),
            m6(d[6],mask[6],reg_val[6],in[6]),
            m7(d[7],mask[7],reg_val[7],in[7]),
            m8(d[8],mask[8],reg_val[8],in[8]),
            m9(d[9],mask[9],reg_val[9],in[9]),
            m10(d[10],mask[10],reg_val[10],in[10]),
            m11(d[11],mask[11],reg_val[11],in[11]),
            m12(d[12],mask[12],reg_val[12],in[12]),
            m13(d[13],mask[13],reg_val[13],in[13]),
            m14(d[14],mask[14],reg_val[14],in[14]),
            m15(d[15],mask[15],reg_val[15],in[15]),
            m16(d[16],mask[16],reg_val[16],in[16]),
            m17(d[17],mask[17],reg_val[17],in[17]),
            m18(d[18],mask[18],reg_val[18],in[18]),
            m19(d[19],mask[19],reg_val[19],in[19]),
            m20(d[20],mask[20],reg_val[20],in[20]),
            m21(d[21],mask[21],reg_val[21],in[21]),
            m22(d[22],mask[22],reg_val[22],in[22]),
            m23(d[23],mask[23],reg_val[23],in[23]),
            m24(d[24],mask[24],reg_val[24],in[24]),
            m25(d[25],mask[25],reg_val[25],in[25]),
            m26(d[26],mask[26],reg_val[26],in[26]),
            m27(d[27],mask[27],reg_val[27],in[27]),
            m28(d[28],mask[28],reg_val[28],in[28]),
            m29(d[29],mask[29],reg_val[29],in[29]),
            m30(d[30],mask[30],reg_val[30],in[30]),
            m31(d[31],mask[31],reg_val[31],in[31]);
            
    dff$    dff0(clk,d[0],reg_val[0],,rst,1'b1),
            dff1(clk,d[1],reg_val[1],,rst,1'b1),
            dff2(clk,d[2],reg_val[2],,rst,1'b1),
            dff3(clk,d[3],reg_val[3],,rst,1'b1),
            dff4(clk,d[4],reg_val[4],,rst,1'b1),
            dff5(clk,d[5],reg_val[5],,rst,1'b1),
            dff6(clk,d[6],reg_val[6],,rst,1'b1),
            dff7(clk,d[7],reg_val[7],,rst,1'b1),
            dff8(clk,d[8],reg_val[8],,rst,1'b1),
            dff9(clk,d[9],reg_val[9],,rst,1'b1),
            dff10(clk,d[10],reg_val[10],,rst,1'b1),
            dff11(clk,d[11],reg_val[11],,rst,1'b1),
            dff12(clk,d[12],reg_val[12],,rst,1'b1),
            dff13(clk,d[13],reg_val[13],,rst,1'b1),
            dff14(clk,d[14],reg_val[14],,rst,1'b1),
            dff15(clk,d[15],reg_val[15],,rst,1'b1),
            dff16(clk,d[16],reg_val[16],,rst,1'b1),
            dff17(clk,d[17],reg_val[17],,rst,1'b1),
            dff18(clk,d[18],reg_val[18],,rst,1'b1),
            dff19(clk,d[19],reg_val[19],,rst,1'b1),
            dff20(clk,d[20],reg_val[20],,rst,1'b1),
            dff21(clk,d[21],reg_val[21],,rst,1'b1),
            dff22(clk,d[22],reg_val[22],,rst,1'b1),
            dff23(clk,d[23],reg_val[23],,rst,1'b1),
            dff24(clk,d[24],reg_val[24],,rst,1'b1),
            dff25(clk,d[25],reg_val[25],,rst,1'b1),
            dff26(clk,d[26],reg_val[26],,rst,1'b1),
            dff27(clk,d[27],reg_val[27],,rst,1'b1),
            dff28(clk,d[28],reg_val[28],,rst,1'b1),
            dff29(clk,d[29],reg_val[29],,rst,1'b1),
            dff30(clk,d[30],reg_val[30],,rst,1'b1),
            dff31(clk,d[31],reg_val[31],,rst,1'b1);
endmodule
