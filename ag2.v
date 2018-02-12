
module addrGen_stage2(
    //AG2 interfaces.
    input clk,
    input rst,
    
    input [2:0] i_sr1,
    input [31:0] i_reg_sr1_val,
    input [31:0] i_reg_sr2_val,
    input i_isAddrbd,
    input i_isO1Mem,
    input i_isO2Mem,
    input [31:0] i_addr_temp,
    input [1:0] i_immSize,
    input [47:0] i_imm,
    input [1:0] i_op,
    input i_far_jmp,
    //Outputs.
    output [63:0] o_reg1,
        //Contains:
        /*output [31:0] o_reg_sr1_val,
        output [31:0] o_reg_sr2_val,*/
    output [63:0] o_reg2,
        //Contains:
        /*output [0:0] o_far_jmp,
        output [2:0] o_sr1,
        output [0:0] o_isMemRd,
        output [0:0] o_isMemwb,
        output [1:0] o_immSize,
        output [1:0] o_op,
        output [47:0] o_imm,*/
    output [31:0] o_reg3
        //Contains:
        /*output [31:0] o_addr,*/
);
        
    wire [31:0] sr1_temp,sr2_temp,o_mux1,o_mux2,reg3_in;
    wire [63:0] reg1_in,reg2_in;
    wire c0,c1,c2,c3,wb,mr,mr_temp;
    
    assign reg1_in[31:0] = i_reg_sr1_val;
    assign reg1_in[63:32] = i_reg_sr2_val;
    
    assign reg2_in[47:0] = i_imm;
    assign reg2_in[49:48] = i_op;
    assign reg2_in[51:50] = i_immSize;
    assign reg2_in[52] = i_isO1Mem;
    assign reg2_in[53] = mr;
    assign reg2_in[56:54] = i_sr1;
    assign reg2_in[57] = i_far_jmp;
    assign reg2_in[63:58] = 6'b0;
    
    or2$    or1(mr_temp,i_isAddrbd,i_isO1Mem),
            or2(mr,mr_temp,i_isO2Mem);
    
    add_16b add1(i_addr_temp[15:0],i_reg_sr1_val[15:0],1'b0,sr1_temp[15:0],c0),
            add2(i_addr_temp[31:16],i_reg_sr1_val[31:16],c0,sr1_temp[31:16],c1);
            
    add_16b add3(i_addr_temp[15:0],i_reg_sr2_val[15:0],1'b0,sr2_temp[15:0],c2),
            add4(i_addr_temp[31:16],i_reg_sr2_val[31:16],c2,sr2_temp[31:16],c3);
    
    mux2_16$  mux2(o_mux1[31:16],sr1_temp[31:16],i_addr_temp[31:16],i_isAddrbd),
              mux1(o_mux1[15:0],sr1_temp[15:0],i_addr_temp[15:0],i_isAddrbd);
    
    mux2_16$  mux4(o_mux2[31:16],sr2_temp[31:16],i_addr_temp[31:16],i_isAddrbd),
              mux3(o_mux2[15:0],sr2_temp[15:0],i_addr_temp[15:0],i_isAddrbd);
    
    mux3_16$ mux6(reg3_in[31:16],o_mux1[31:16],o_mux1[31:16],o_mux2[31:16],i_isO1Mem,i_isO2Mem),
             mux5(reg3_in[15:0],o_mux1[15:0],o_mux1[15:0],o_mux2[15:0],i_isO1Mem,i_isO2Mem);
             
    //Pipeline registers.
    reg64e$ reg1(clk,reg1_in,o_reg1,,1'b1,1'b1,1'b1),
            reg2(clk,reg2_in,o_reg2,,1'b1,1'b1,1'b1);
    reg32e$ reg3(clk,reg3_in,o_reg3,,1'b1,1'b1,1'b1);
    
endmodule
