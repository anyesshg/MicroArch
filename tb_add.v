module tb_add;
    reg clk,rst,o1m,abs,o2m,fjmp,ds_ch;
    reg [2:0] sr1,sr2,i;
    reg [1:0] immSize,disp_size,op;
    reg [47:0] imm;
    reg [31:0] disp,eip_set;
    reg [15:0] ds_in;
    
    datapath inst(
    .clk    (clk),
    .rst    (rst),
    .i_sr1    (sr1),
    .i_sr2    (sr2),
    .i_isAddrbd    (abs),
    .i_isO1Mem    (o1m),
    .i_isO2Mem    (o2m),
    .i_immSize    (immSize),    
    .i_imm    (imm),
    .i_disp    (disp),
    .i_disp_size(disp_size),
    .i_op    (op),
    .i_far_jmp    (fjmp),
    .ds_in    (ds_in),
    .ds_ch    (ds_ch),
    .eip_set   (eip_set));

    always #10 clk = ~clk;
    initial begin
    $vcdplusfile("pipe_add.dump.vpd");
    $vcdpluson(0,tb_add);
    end

    initial begin
      rst = 1'b0;
      clk = 1'b0;
      i = 3'd0;
      ds_ch = 1'b0;
      #90
          rst = 1'b1;
    #60
    ds_in = 16'hf88f;
    ds_ch = 1'b1;
    @(posedge clk);
    #20;
    @(negedge clk);
    abs = 1'b0;
    o1m = 1'b0;
    o2m = 1'b0;
    immSize = 2'd2;
    disp = 32'd10;
    disp_size = 2'b0;
    op = 2'd2;
    fjmp = 1'd0;

    //r <- imm32 for all r.
    repeat(8) begin
    sr1 = i;
    sr2 = i;
    imm = {29'h1FFF_FFFF,i};
    @(posedge clk);
    i = i + 1;
    end
    
    //r <- SEXT(imm8) for all r.
    immSize = 2'd1;
    i = 3'd0;
    repeat(8) begin
    sr1 = i;
    sr2 = i;
    if(i < 4) begin
        imm = {24'b0,4'ha,1'b1,i};
    end else begin
        imm = {24'b0,4'h3,1'b1,i};
    end
    @(posedge clk);
    i = i + 1;
    end
   
    #120;   //Let everything finish writing. 
    
    //M[...] <- M[...] + imm32; M[...] <- M[...] + imm8.
	@(negedge clk);
	op = 2'd0;
    	abs = 1'b1;
    	o1m = 1'b1;
    	immSize = 2'h2;
    
    	//disp32,imm32.
    	disp = 32'h89ab_0020;
    	disp_size = 2'b1;
    	fjmp = 1'd0;
    	imm = 32'hf88f_00a0;
    
    	@(posedge clk);
    	//disp32,imm8;
    	immSize = 2'd1;

    	@(posedge clk);
    	//disp8,imm8.
    	disp_size = 2'b0;
    
    	@(posedge clk);
    	disp = 32'h89ab_0080;

    	//disp8,imm32.
    	@(posedge clk);
    	immSize = 2'h2;
    //---------END OF VARIANT.----------//
    
    //M[...] <- M[...] + r32.
    	//disp32,r32
	@(posedge clk);
    	sr1 = 3'd4;
    	sr2 = 3'd1;
    	immSize = 2'h0;
    	disp = 32'h89ab_0020;
    	disp_size = 2'b1;
    	
	@(posedge clk);
    	//disp8,r32.
    	disp_size = 2'b0;
    
    	@(posedge clk);
    	disp = 32'h89ab_0080;
    //----------END OF VARIANT.----------//

    //M[r..] <- M[r..] + imm32, M[r..] <- M[r...] + SEXT(imm8).
	@(posedge clk);
    	abs = 1'b0;
    	o1m = 1'b1;
    	immSize = 2'h2;
    
    	//disp32,imm32.
    	disp = 32'h89ab_0020;
    	disp_size = 2'b1;
    	
	@(posedge clk);
    	//disp32,imm8;
    	immSize = 2'd1;
    
	@(posedge clk);
    	//disp8,imm8.
    	disp_size = 2'b0;

    	@(posedge clk);
    	disp = 32'h89ab_0080;

    	//disp8,imm32.
    	@(posedge clk);
    	immSize = 2'h2;

	//no disp,imm32.
	@(posedge clk);
	disp_size = 2'b10;

	//no disp, imm8
	@(posedge clk);
	immSize = 2'h1;
    //---------END OF VARIANT.----------//
    	
    //M[r..] <- M[r..] + r32.
    	//disp32,r32
	@(posedge clk);
    	immSize = 2'h0;
    	disp = 32'h89ab_0020;
    	disp_size = 2'b1;
    
    	@(posedge clk);
    	//disp8,r32.
    	disp_size = 2'b0;
    
    	@(posedge clk);
    	disp = 32'h89ab_0080;

	@(posedge clk);
	//no disp, r32
	disp_size = 2'b10;
    //----------END OF VARIANT.----------//
       
    //r <- r + M[...]
    	@(posedge clk);
    	abs = 1'b1;
    	o1m = 1'b0;
	o2m = 1'b1;
	sr1 = 3'd7;
	sr2 = 3'd4;
    	immSize = 2'h0;
    
    	//disp32.
    	disp = 32'h89ab_0020;
    	disp_size = 2'b1;

    	@(posedge clk);
    	//disp8.
    	disp_size = 2'b0;
    
    	@(posedge clk);
    	disp = 32'h89ab_0080;
    //------------END OF VARIANT.----------//
  
    //r <- r + M[r..]
    	@(posedge clk);
    	abs = 1'b0;
    
    	//disp32.
    	disp = 32'h89ab_0020;
    	disp_size = 2'b1;

    	@(posedge clk);
    	//disp8.
    	disp_size = 2'b0;
    
    	@(posedge clk);
    	disp = 32'h89ab_0080;
 
	@(posedge clk);	
	//no disp.
	disp_size = 2'b10;
    //-------------END OF VARIANT.------------//
    
    //r <- r + r1.
    	@(posedge clk);
	o2m = 1'b0;
	sr1 = 3'd7;
	sr2 = 3'd2;
    	immSize = 2'h0;
    //--------------END OF VARIANT.-----------//
	@(posedge clk);
	immSize = 2'h2;
	@(posedge clk);
	immSize = 2'h1;
	#100 $finish;
    end
endmodule
