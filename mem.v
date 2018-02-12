    //Assumes that any instruction that writes to a mem addr. must have read
    //one of uts operands from that addr. Not true in the case of jump, TODO
    //fix later.
    module mem_stage(
    input clk,
    input rst,
    input [31:0] i_reg_sr1_val,
    input [31:0] i_reg_sr2_val,
    input [2:0] i_sr1,
    input [0:0] i_isMemRd,
    input [0:0] i_isMemwb,
    input [1:0] i_immSize,
    input [1:0] i_op,
    input [47:0] i_imm,
    input [31:0] i_addr,
    input [0:0] i_far_jmp,
    
    input [47:0] i_mem_data,
    //Outputs to memory.
    output [31:0] o_rdaddr,
    output [0:0] o_rdvld,
    
    //Outputs.
    output [63:0] o_reg1,
        //Contains:
        /*output [31:0] o_op1_val,
        output [31:0] o_op2_val,*/
    output [63:0] o_reg2,
        //Contains:
        /*output [0:0] o_far_jmp,
        output [2:0] o_sr1,
        output [0:0] o_isMemRd,
        output [0:0] o_isMemwb,
        output [1:0] o_immSize,
        output [1:0] o_op,
        output [47:0] o_imm,*/
    output [63:0] o_reg3
        //Contains:
        /*output [15:0] o_memoverflow,
        output [31:0] o_addr*/
    );
    wire sel1,sel2,nwb;
    wire [63:0] reg1_in,reg2_in,reg3_in;
    
    assign o_rdaddr = i_addr;
    assign o_rdvld = i_isMemRd;
    
    assign reg2_in[47:0] = i_imm;
    assign reg2_in[49:48] = i_op;
    assign reg2_in[51:50] = i_immSize;
    assign reg2_in[52] = i_isMemwb;
    assign reg2_in[53] = i_isMemRd;
    assign reg2_in[56:54] = i_sr1;
    assign reg2_in[57] = i_far_jmp;
    assign reg2_in[63:58] = 6'b0;
    
    assign reg3_in[31:0] = i_addr;
    assign reg3_in[47:32] = i_mem_data[47:32];
    
    inv1$    i1(nwb,i_isMemwb);
    and2$    and1(sel1,i_isMemRd,i_isMemwb),
            and2(sel2,nwb,i_isMemRd);
    
    mux2_16$    m1(reg1_in[63:48],i_reg_sr1_val[31:16],i_mem_data[31:16],sel1),
                m2(reg1_in[47:32],i_reg_sr1_val[15:0],i_mem_data[15:0],sel1);
                   
    mux2_16$    m3(reg1_in[31:16],i_reg_sr2_val[31:16],i_mem_data[31:16],sel2),
                m4(reg1_in[15:0],i_reg_sr2_val[15:0],i_mem_data[15:0],sel2);
                
    //Pipeline registers.
    reg64e$ reg1(clk,reg1_in,o_reg1,,1'b1,1'b1,1'b1),
            reg2(clk,reg2_in,o_reg2,,1'b1,1'b1,1'b1),
            reg3(clk,reg3_in,o_reg3,,1'b1,1'b1,1'b1);
            
endmodule
