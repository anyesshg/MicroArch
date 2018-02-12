module exec_stage(
    input clk,
    input rst,
    input [31:0] i_op1_val,
    input [31:0] i_op2_val,
    input [2:0] i_sr1,
    input  i_isMemRd,
    input  i_isMemwb,
    input [1:0] i_immSize,
    input [1:0] i_op,
    input [47:0] i_imm,
    input [15:0] i_memoverflow,
    input [31:0] i_addr,
    input [31:0] i_eip,
    input i_far_jmp,
    
    //Outputs.
    output [31:0] o_eip,
    output [0:0] o_eip_vld,
    output [15:0] o_cs,
    output [0:0] o_cs_vld,
   
    output of,
    output af,
    output cf,
    output [63:0] o_reg1,
        //Contains:
        /*output [31:0] o_ex_data,
        output [31:0] o_addr,*/
    output [31:0] o_reg2
        //Contains:
        /*output [2:0] o_sr1,
        output [0:0] o_isMemwb,
        output [1:0] o_op */
);
    wire [63:0] reg1_in;
    wire [31:0] reg2_in;
    wire immVld,jmp,add_ctrl,c0,c1,n_far,eip_ctrl,imm_sel;
    wire [31:0] op1,op2,add_out,or_out,imm_sext,imm_f;
    
    assign reg1_in[31:0] = i_addr;
    
    assign reg2_in[1:0] = i_op;
    assign reg2_in[2] = i_isMemwb;
    assign reg2_in [5:3] = i_sr1;
    assign reg2_in[31:6] = 27'b0;
    
    assign o_cs_vld = i_far_jmp;
    assign o_eip_vld = jmp;
    
    
    or2$    o1(immVld,i_immSize[0],i_immSize[1]);
    and2$    a1(jmp,i_op[0],i_op[1]),
            a2(eip_ctrl,immVld,n_far);
    inv1$    i1(n_far,i_far_jmp);
    
    mux2_16$    m1(o_cs,i_memoverflow,i_imm[47:32],immVld);
    
    //Selection b/n src1 & eip for adder input.
    mux2_16$    m2(op1[31:16],i_op1_val[31:16],i_eip[31:16],jmp),
                m3(op1[15:0],i_op1_val[15:0],i_eip[15:0],jmp);
                
    //Generating upper bits for sign extension of imm8.
    assign imm_sext[7:0] = i_imm[7:0];
    mux2_8$  ms2(imm_sext[31:24],8'h0,8'hFF,i_imm[7]);
    mux2_16$ ms1(imm_sext[23:8],16'h0,16'hFFFF,i_imm[7]);

    //Somewhat hacky :) - Don't change till you know exactly what to do.
    mux2_16$  ms4(imm_f[31:16],imm_sext[31:16],i_imm[31:16],i_immSize[1]),
    	     ms3(imm_f[15:0],imm_sext[15:0],i_imm[15:0],i_immSize[1]);

    //Selection b/n src2 & imm32 for adder input.
    mux2_16$    m4(op2[31:16],i_op2_val[31:16],imm_f[31:16],immVld),
                m5(op2[15:0],i_op2_val[15:0],imm_f[15:0],immVld);
                
    add_16b     add1(op1[15:0],op2[15:0],1'b0,add_out[15:0],c0),
                add2(op1[31:16],op2[31:16],c0,add_out[31:16],c1);
    
    //Set OF, CF, AF.
    assign cf = c1;
    assign af = add1.c4;
    wire ow1,ow2,ow3;

    xor2$	ox1(ow1,op1[31],op2[31]),
		ox2(ow2,op1[31],add_out[31]);
    inv1$	oi(ow3,ow2);
    and2$	oa1(of,ow3,ow1);

    //Create the 32-bit OR component.
    or_32b	orb(op1,op2,or_out);
 
    //EIP update selector.
    mux2_16$    me1(o_eip[31:16],op2[31:16],add_out[31:16],eip_ctrl),
                me2(o_eip[15:0],op2[15:0],add_out[15:0],eip_ctrl);
    
    //ALU Output selector.
    mux3_16$    malu1(reg1_in[63:48],add_out[31:16],or_out[31:16],op2[31:16],i_op[0],i_op[1]),
                malu2(reg1_in[47:32],add_out[15:0],or_out[15:0],op2[15:0],i_op[0],i_op[1]);
                
    //Pipeline registers.
    reg64e$ reg1(clk,reg1_in,o_reg1,,1'b1,1'b1,1'b1);
    reg32e$ reg2(clk,reg2_in,o_reg2,,1'b1,1'b1,1'b1);
                
endmodule
        
        
