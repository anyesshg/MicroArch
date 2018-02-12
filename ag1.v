//CHANGE ADD LIBRARY TO ADD INPUT CARRY FOR CHAINING ADDS.
module addrGen_stage1(
    //AG1 interfaces.
    input  clk,
    input  rst,
    input [2:0] i_sr1,
    input [2:0] i_sr2,
    input i_isAddrbd,
    input i_isO1Mem,
    input i_isO2Mem,
    input [1:0] i_immSize,    //00:0b/Not Valid;01:48b;10:8b;11:32b
    input [47:0] i_imm,
    input [31:0] i_disp,
    input [1:0] i_disp_size,    //0:8b;1:32b,2:no disp
    input [1:0] i_op,
    input i_far_jmp,
    //Arch register values.
    input [31:0] i_reg_sr1_val,
    input [31:0] i_reg_sr2_val,
    input [15:0] i_ds_val,
    //Wires bypassed through unit.
    output [2:0] sr1_byp,
    output [2:0] sr2_byp,
    //Output values.
    output [63:0] o_reg1,
        //Contains:
        /*output [31:0] o_reg_sr1_val,
        output [31:0] o_reg_sr2_val,*/
    output [63:0] o_reg2,
        //Contains:
        /*output [0:0] o_far_jmp,
        output [2:0] o_sr1,
        output [0:0] o_isAddrbd,
        output [0:0] o_isO1Mem,
        output [0:0] o_isO2Mem,
        output [1:0] o_immSize,
        output [1:0] o_op,
        output [47:0] o_imm,*/
    output [31:0] o_reg3
        //Contains:
        /*output [31:0] o_addr_temp,*/
);
    wire [63:0] reg1_in,reg2_in;
    wire [31:0] reg3_in,disp;
    wire [23:0] o_sext;
    wire c,w1,n_disp_sel;
    
    //Read register file.
    assign sr1_byp = i_sr1;
    assign sr2_byp = i_sr2;
    
    //Construct input for pipeline latches.
    assign reg1_in[31:0] = i_reg_sr1_val;
    assign reg1_in[63:32] = i_reg_sr2_val;
    
    assign reg2_in[47:0] = i_imm;
    assign reg2_in[49:48] = i_op;
    assign reg2_in[51:50] = i_immSize;
    assign reg2_in[52] = i_isO2Mem;
    assign reg2_in[53] = i_isO1Mem;
    assign reg2_in[54] = i_isAddrbd;
    assign reg2_in[57:55] = i_sr1;
    assign reg2_in[58] = i_far_jmp;
    assign reg2_in[63:59] = 5'b0;

    inv1$     iv1(w1,i_disp_size[0]);    
    and2$    a1(n_disp_sel,i_disp_size[1],w1);

    mux2_8$	m(disp[7:0],i_disp[7:0],8'b0,n_disp_sel);

    assign reg3_in[15:0] = disp[15:0];
    
    //Generating upper bits for sign extension of disp.
    mux2_8$  mux2(o_sext[23:16],8'h0,8'hFF,i_disp[7]);
    mux2_16$ mux1(o_sext[15:0],16'h0,16'hFFFF,i_disp[7]);
    
    //Selecting correct upper bits based on disp size.
    mux3_8$  mux4(disp[31:24],o_sext[23:16],i_disp[31:24],8'b0,i_disp_size[0],i_disp_size[1]);
    mux3_16$ mux3(disp[23:8],o_sext[15:0],i_disp[23:8],16'b0,i_disp_size[0],i_disp_size[1]);
    
    //16-bit add: (DS << 16 + disp).
    add_16b    add1(disp[31:16],i_ds_val,1'b0,reg3_in[31:16],c);
    
    //Pipeline registers.
    reg64e$ reg1(clk,reg1_in,o_reg1,,1'b1,1'b1,1'b1),
            reg2(clk,reg2_in,o_reg2,,1'b1,1'b1,1'b1);
    reg32e$ reg3(clk,reg3_in,o_reg3,,1'b1,1'b1,1'b1);
endmodule
