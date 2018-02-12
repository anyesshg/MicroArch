module writeback(
    input clk,
    input rst,
    input [31:0] i_wb_data,
    input [31:0] i_wb_addr,
    input [2:0] i_wb_sr1,
    input i_wb_isMemwb,
    input [1:0] i_wb_op,
    input of,
    input af,
    input cf,
    //Outputs.
    output [2:0] o_dr,
    output o_reg_write,
    output [31:0] o_dr_data,
    output [31:0] o_mem_addr,
    output o_mem_wr,
    output [31:0] o_mem_data,
    output [31:0] o_flags,
    output [31:0] o_flags_mask
);
    wire f1;

    assign o_flags[31:12] = 20'b0;
    assign o_flags[10:8] = 4'b0;
    assign o_flags[5] = 1'b0;
    assign o_flags[3] = 1'b0;
    assign o_flags[1] = 1'b0;
    assign o_flags[7] = i_wb_data[31];
    assign o_flags_mask[31:16] = 16'h0;
    
    nor2$  o1(f1,i_wb_op[0],i_wb_op[1]);
    and2$  o2(o_flags[0],f1,cf);
    and2$  o3(o_flags[4],f1,af);
    and2$  o4(o_flags[11],f1,of);
    xor_tree xinst(i_wb_data,o_flags[2]);
    or_tree oinst(i_wb_data,o_flags[6]);

    mux2_16$	m1(o_flags_mask[15:0],16'h08d5,16'h0,i_wb_op[1]);
		
    wire w1;
    //TODO Add logic for flags.
    assign o_mem_wr = i_wb_isMemwb;
    assign o_mem_data = i_wb_data;
    assign o_mem_addr = i_wb_addr;
    assign o_dr = i_wb_sr1;
    assign o_dr_data = i_wb_data;
    
    and2$    a(w1,i_wb_op[0],i_wb_op[1]);
    nor2$    n(o_reg_write,w1,i_wb_isMemwb);
    
endmodule
