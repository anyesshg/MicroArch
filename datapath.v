module datapath(
    //AG1 interfaces.
    input [0:0] clk,
    input [0:0] rst,
    input [2:0] i_sr1,
    input [2:0] i_sr2,
    input [0:0] i_isAddrbd,
    input [0:0] i_isO1Mem,
    input [0:0] i_isO2Mem,
    input [1:0] i_immSize,    
    input [47:0] i_imm,
    input [31:0] i_disp,
    input [1:0] i_disp_size,
    input [1:0] i_op,
    input [0:0] i_far_jmp,
    input [0:0] ds_ch,
    input [15:0] ds_in,
    input [31:0] eip_set
);
    //Architectural register file.
    wire [31:0] regin,i_sr1_val,i_sr2_val;
    wire [2:0] wr,sr1,sr2;
    wire wen;
    arch_regfile    regfile(
        .in0            (regin),
        .r0             (sr1),
        .r1             (sr2),
        .re0            (1'b1),         //TODO Change later.
        .re1            (1'b1),         //TODO Change later.
        .wr             (wr),
        .wen            (wen),
        .out0           (i_sr1_val),
        .out1           (i_sr2_val),
        .clk            (clk));
        
    //EIP instantiation.
    wire [31:0] eip_in,eip_out,eip_data;
    wire eip_ch;
    mux2_16$     em1(eip_data[15:0],eip_set[15:0],eip_in[15:0],rst),
        em2(eip_data[31:16],eip_set[31:16],eip_in[31:16],rst);
    reg32e$    EIP(clk,eip_data,eip_out,,1'b1,1'b1,eip_ch);
    
    //CS instantiation.    
    wire [15:0] cs_in,cs_out;
    wire cs_ch;
    wire [31:0] cs_regout;
    assign cs_out = cs_regout[15:0];
    reg32e$    CS(clk,{16'b0,cs_in},cs_regout,,1'b1,1'b1,cs_ch);
    
    //DS instantiation.
    wire [15:0] ds_out;
    wire [31:0] ds_regout;
    assign ds_out = ds_regout[15:0];
    reg32e$    DS(clk,{16'b0,ds_in},ds_regout,,1'b1,1'b1,ds_ch);
    
    //Memory instatiation.
    wire [31:0] rdaddr,wraddr,wrdata;
    wire rdvld,wrvld;
    wire [47:0] rddata;
    bb_mem    mem_model(
    .clk           (clk),
    .rdaddr        (rdaddr),
    .wraddr        (wraddr),
    .rdvld         (rdvld),
    .wrvld         (wrvld),
    .wrdata        (wrdata),
    .rddata        (rddata)
    );
    
    //EFLAGS instantiation.
    wire [31:0] flags_in,mask_in,reg_val,flags_wb,mask_wb;
    mux2_16$     fm1(flags_in[15:0],16'h2,flags_wb[15:0],rst),
                 fm2(flags_in[31:16],16'b0,flags_wb[31:16],rst),

                 fm3(mask_in[15:0],16'hffff,mask_wb[15:0],rst),
                 fm4(mask_in[31:16],16'hffff,mask_wb[31:16],rst);
    _32bmaskedreg    EFLAGS(flags_in,mask_in,clk,rst,reg_val);

    //RR + AG stage1.
    wire [63:0] o_reg1_ag1,o_reg2_ag1;
    wire [31:0] o_reg3_ag1;
    addrGen_stage1    ag1(
        .clk            (clk),
        .rst            (rst),
        .i_sr1          (i_sr1),
        .i_sr2          (i_sr2),
        .i_isAddrbd     (i_isAddrbd),    //Is Mem address mode base+disp? (i.e. do we add RR values?)
        .i_isO1Mem      (i_isO1Mem),    //O1=src1=dst (always). Denotes whether that is a mem access.
        .i_isO2Mem      (i_isO2Mem),    //O2=src2=imm(when it exists). Denotes whether that is mem access.
        .i_immSize      (i_immSize),    //00:Not Valid,01:imm8,10:imm32,11:imm48
        .i_imm          (i_imm),        //48b immediate value.
        .i_disp         (i_disp),
        .i_disp_size    (i_disp_size),    //00:No displacement, 01:8b, 10:32b (Mod bits of ModRM).
        .i_op           (i_op),            //TODO
        .i_far_jmp      (i_far_jmp),    //Is the jump a far jump?
        //Arch register values.
        .i_reg_sr1_val  (i_sr1_val),    
        .i_reg_sr2_val  (i_sr2_val),
        .i_ds_val       (ds_out),
        //Wires bypassed through unit.
        .sr1_byp        (sr1),
        .sr2_byp        (sr2),
        //Output values.
        .o_reg1         (o_reg1_ag1),
        .o_reg2         (o_reg2_ag1),
        .o_reg3         (o_reg3_ag1)
    );

    //AG stage 2.
    //AG2 Interface Value assignment.
    wire [31:0] i_ag2_sr2_val, i_ag2_sr1_val,o_reg3_ag2;
    wire [47:0] i_ag2_imm;
    wire [1:0] i_ag2_op,i_ag2_immSize;
    wire i_ag2_isO2mem,i_ag2_isO1mem,i_ag2_isAddrbd,i_ag2_far_jmp;
    wire [2:0] i_ag2_sr1;
    wire [63:0] o_reg1_ag2,o_reg2_ag2;
    
    assign i_ag2_sr2_val = o_reg1_ag1[63:32];
    assign i_ag2_sr1_val = o_reg1_ag1[31:0];

    assign i_ag2_imm = o_reg2_ag1[47:0];
    assign i_ag2_op = o_reg2_ag1[49:48];
    assign i_ag2_immSize = o_reg2_ag1[51:50];
    assign i_ag2_isO2mem = o_reg2_ag1[52];
    assign i_ag2_isO1mem = o_reg2_ag1[53];
    assign i_ag2_isAddrbd = o_reg2_ag1[54];
    assign i_ag2_sr1 = o_reg2_ag1[57:55];
    assign i_ag2_far_jmp = o_reg2_ag1[58];

    addrGen_stage2    ag2(
        .clk            (clk),
        .rst            (rst),
        .i_sr1          (i_ag2_sr1),
        .i_reg_sr1_val  (i_ag2_sr1_val),
        .i_reg_sr2_val  (i_ag2_sr2_val),
        .i_isAddrbd     (i_ag2_isAddrbd),
        .i_isO1Mem      (i_ag2_isO1mem),
        .i_isO2Mem      (i_ag2_isO2mem),
        .i_addr_temp    (o_reg3_ag1),
        .i_immSize      (i_ag2_immSize),
        .i_imm          (i_ag2_imm),
        .i_op           (i_ag2_op),
        .i_far_jmp      (i_ag2_far_jmp),
        //Outputs.
        .o_reg1         (o_reg1_ag2),
        .o_reg2         (o_reg2_ag2),
        .o_reg3         (o_reg3_ag2)
    );

    //MEM stage.
    //MEM stage interface value assignment.
    wire [31:0] i_mem_sr1_val,i_mem_sr2_val; 
    wire [47:0] i_mem_imm;
    wire [1:0] i_mem_op,i_mem_immSize; 
    wire i_mem_isO1Mem,i_mem_mr,i_mem_far_jmp;
    wire [2:0] i_mem_sr1;
    wire [63:0] o_reg1_mem,o_reg2_mem,o_reg3_mem;
    
    assign i_mem_sr1_val = o_reg1_ag2[31:0];
    assign i_mem_sr2_val = o_reg1_ag2[63:32];

    assign i_mem_imm = o_reg2_ag2[47:0];
    assign i_mem_op = o_reg2_ag2[49:48];
    assign i_mem_immSize = o_reg2_ag2[51:50];
    assign i_mem_isO1Mem = o_reg2_ag2[52];
    assign i_mem_mr = o_reg2_ag2[53];
    assign i_mem_sr1 = o_reg2_ag2[56:54];
    assign i_mem_far_jmp = o_reg2_ag2[57];

    mem_stage    mem(
        .clk          (clk),
    .rst              (rst),
    .i_reg_sr1_val    (i_mem_sr1_val),
        .i_reg_sr2_val(i_mem_sr2_val),
        .i_sr1        (i_mem_sr1),
        .i_isMemRd    (i_mem_mr),
        .i_isMemwb    (i_mem_isO1Mem),
        .i_immSize    (i_mem_immSize),
        .i_op         (i_mem_op),
        .i_imm        (i_mem_imm),
        .i_addr       (o_reg3_ag2),
        .i_far_jmp    (i_mem_far_jmp),
        .i_mem_data   (rddata),
        //Outputs to memory.
        .o_rdaddr     (rdaddr),
        .o_rdvld      (rdvld),
        .o_reg1       (o_reg1_mem),
        .o_reg2       (o_reg2_mem),
        .o_reg3       (o_reg3_mem)
    );  
        
    //EXEC stage.
    //EXEC stage interface value assignment.
    wire [31:0] i_op1_val,i_op2_val,i_ex_addr,o_reg2_ex;
    wire [47:0] i_ex_imm;
    wire [1:0] i_ex_op,i_ex_immSize; 
    wire i_ex_Memwb,i_ex_Memrd,i_ex_far_jmp; 
    wire [2:0] i_ex_sr1;
    wire [15:0] i_memoverflow;
    wire [63:0] o_reg1_ex;
    
    assign i_op1_val = o_reg1_mem[63:32];
    assign i_op2_val = o_reg1_mem[31:0];

    assign i_ex_imm = o_reg2_mem[47:0];
    assign i_ex_op = o_reg2_mem[49:48];
    assign i_ex_immSize = o_reg2_mem[51:50];
    assign i_ex_Memwb = o_reg2_mem[52];
    assign i_ex_Memrd = o_reg2_mem[53];
    assign i_ex_sr1 = o_reg2_mem[56:54];
    assign i_ex_far_jmp = o_reg2_mem[57];

    assign i_ex_addr =  o_reg3_mem[31:0];
    assign i_memoverflow = o_reg3_mem[47:32];

    wire of,af,cf;
    exec_stage    exec(
    .clk          (clk),
    .rst          (rst),
        .i_op1_val        (i_op1_val),
        .i_op2_val        (i_op2_val),
        .i_sr1            (i_ex_sr1),
        .i_isMemRd        (i_ex_Memrd),
        .i_isMemwb        (i_ex_Memwb),
        .i_immSize        (i_ex_immSize),
        .i_op             (i_ex_op),
        .i_imm            (i_ex_imm),
        .i_memoverflow    (i_memoverflow),
        .i_addr           (i_ex_addr),
        .i_eip            (eip_in),
        .i_far_jmp        (i_ex_far_jmp),
        //Outputs.  
        .of               (of),
        .af               (af),
        .cf               (cf),
        .o_eip            (eip_out),
        .o_eip_vld        (eip_ch),
        .o_cs             (cs_in),
        .o_cs_vld         (cs_ch),
        .o_reg1           (o_reg1_ex),
        .o_reg2           (o_reg2_ex)
    );


    //WB stage.
    //WB stage interface value assignment.
    wire [31:0] i_wb_data,i_wb_addr;        
    wire [2:0] i_wb_sr1;        
    wire i_wb_isMemwb;    
    wire [1:0] i_wb_op;        
    
    
    
    assign i_wb_data = o_reg1_ex[63:32];
    assign i_wb_addr = o_reg1_ex[31:0];
    
    assign i_wb_op = o_reg2_ex[1:0] ;
    assign i_wb_isMemwb = o_reg2_ex[2];
    assign i_wb_sr1 = o_reg2_ex[5:3];
    
    writeback wb(
        .clk          (clk),
        .rst          (rst),
        .i_wb_data    (i_wb_data),
        .i_wb_addr    (i_wb_addr),
        .i_wb_sr1     (i_wb_sr1),
        .i_wb_isMemwb (i_wb_isMemwb),
        .i_wb_op      (i_wb_op),
        .of           (of),
        .af           (af),
        .cf           (cf),
        //Outputs.        
        .o_dr         (wr),
        .o_reg_write  (wen),
        .o_dr_data    (regin),
        .o_mem_addr   (wraddr),
        .o_mem_wr     (wrvld),
        .o_mem_data   (wrdata),
        .o_flags      (flags_wb),
        .o_flags_mask (mask_wb)
    );
    
endmodule
