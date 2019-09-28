////////////////////////////////////////////////////////////
// File Description: 
// This file decoder top file
//
// 
// Date:   2019.09.18
///////////////////////////////////////////////////////////

module peak_dpu_de
(

);

input        clk;
input        rst_n;

input[1:0]   ifu_dpu_instr_vld;
input        ifu_dpu_instr0_rvc;
input[31:0]  ifu_dpu_instr;
output       dpu_ifu_rdy;


//from current RV standard instruction set,
//compressed instruction always has 1 source
//non-compressed instruction always has 2 source
//so for current design, 2 read ports are enough
//we can just have extra ports dangling for further
//development if we want to have customed isa, such
//as madd
output[4:0]  regbank_rd_addr0;
output[4:0]  regbank_rd_addr1;
output[4:0]  regbank_rd_addr2;
input[31:0]  regbank_rdata0;
input[31:0]  regbank_rdata1;
input[31:0]  regbank_rdata2;

output[31:0] instr0_op0;
output[31:0] instr0_op1;
output[31:0] instr0_op2;
output[31:0] instr1_op0;
output[31:0] instr1_op1;
output[31:0] instr1_op2;


//forwarding bus
input        alu0_wr_vld_ex;
input[4:0]   alu0_wr_addr_ex; //assume mul/div/csr can share same addr bus
input[31:0]  alu0_wr_data_ex; //assume mul/div/csr can share same data bus
input        alu1_wr_vld_ex;
input[4:0]   alu1_wr_addr_ex;
input[31:0]  alu1_wr_data_ex;
input        mul_wr_vld_ex;
input        mul_busy;
input        div_wr_vld_ex;
input        div_busy;
input        lsu_wr_vld_ex;
input[4:0]   lsu_wr_addr_ex;
input        lsu_wr_vld_ret;
input[4:0]   lsu_wr_addr_ret;
input[31:0]  lsu_wr_data_ret;
input        csr_wr_vld_ex;
input        fp_busy;
input[4:0]   fp_wr_addr;
input[31:0]  fp_wr_data;


output       instr0_wr_vld;
output[4:0]  instr0_wr_addr;
output[31:0] instr0_imm;
output       instr0_use_imm;

output       instr1_wr_vld;
output[4:0]  instr1_wr_addr;
output[31:0] instr1_imm;
output       instr1_use_imm;

output       instr0_is_ls;
output       instr0_is_alu;
output       instr0_is_mul;
output       instr0_is_div;
output       instr0_is_br;
output       instr0_is_fp;
output       instr0_is_csr;
output       instr1_is_ls;
output       instr1_is_alu;
output       instr1_is_mul;
output       instr1_is_div;
output       instr1_is_br;
output       instr1_is_fp;
output       instr1_is_csr;

output[2:0]  instr0_ls_op;
output[3:0]  instr0_alu_op;
output[1:0]  instr0_mul_op;
output[1:0]  instr0_div_op;
output[2:0]  instr0_br_op;

output[2:0]  instr1_ls_op;
output[3:0]  instr1_alu_op;
output[1:0]  instr1_mul_op;
output[1:0]  instr1_div_op;
output[2:0]  instr1_br_op;

wire       instr0_rd_r0_vld_nq;
wire[4:0]  instr0_rd_r0_addr_nq;
wire       instr0_rd_r1_vld_nq;
wire[4:0]  instr0_rd_r1_addr_nq;
wire       instr0_rd_r2_vld_nq;
wire[4:0]  instr0_rd_r2_addr_nq;
wire       instr0_wr_vld_nq;
wire[4:0]  instr0_wr_addr_nq;
wire[31:0] instr0_imm_nq;
wire       instr0_use_imm_nq;
wire       instr0_is_ls_nq;
wire       instr0_is_alu_nq;
wire       instr0_is_mul_nq;
wire       instr0_is_div_nq;
wire       instr0_is_br_nq;
wire       instr0_is_fp_nq;
wire       instr0_is_csr_nq;
wire[2:0]  instr0_ls_op_nq;
wire[3:0]  instr0_alu_op_nq;
wire[1:0]  instr0_mul_op_nq;
wire[1:0]  instr0_div_op_nq;
wire[2:0]  instr0_br_op_nq;

wire instr0_is_compressed = ifu_dpu_instr0_rvc;
wire instr0_vld = ifu_dpu_instr_vld[0];
wire[31:0] instr0_op = ifu_dpu_instr;

peak_dpu_de0 u_de0(
                   .instr0_is_compressed(instr0_is_compressed   ),
                   .instr0_vld          (instr0_vld             ),
                   .instr0_op           (instr0_op              ),
                   .instr0_rd_r0_vld    (instr0_rd_r0_vld_nq    ),
                   .instr0_rd_r0_addr   (instr0_rd_r0_addr_nq   ),
                   .instr0_rd_r1_vld    (instr0_rd_r1_vld_nq    ),
                   .instr0_rd_r1_addr   (instr0_rd_r1_addr_nq   ),
                   .instr0_rd_r2_vld    (instr0_rd_r2_vld_nq    ),
                   .instr0_rd_r2_addr   (instr0_rd_r2_addr_nq   ),
                   .instr0_wr_vld       (instr0_wr_vld_nq       ),
                   .instr0_wr_addr      (instr0_wr_addr_nq      ),
                   .instr0_imm          (instr0_imm_nq          ),
                   .instr0_use_imm      (instr0_use_imm_nq      ),
                   .instr0_is_ls        (instr0_is_ls_nq        ),
                   .instr0_is_alu       (instr0_is_alu_nq       ),
                   .instr0_is_mul       (instr0_is_mul_nq       ),
                   .instr0_is_div       (instr0_is_div_nq       ),
                   .instr0_is_br        (instr0_is_br_nq        ),
                   .instr0_is_fp        (instr0_is_fp_nq        ),
                   .instr0_is_csr       (instr0_is_csr_nq       ),
                   .instr0_ls_op        (instr0_ls_op_nq        ),
                   .instr0_alu_op       (instr0_alu_op_nq       ),
                   .instr0_mul_op       (instr0_mul_op_nq       ),
                   .instr0_div_op       (instr0_div_op_nq       ),
                   .instr0_br_op        (instr0_br_op_nq        )        
                   );

wire       instr1_rd_r0_vld_nq;
wire[4:0]  instr1_rd_r0_addr_nq;
wire       instr1_rd_r1_vld_nq;
wire[4:0]  instr1_rd_r1_addr_nq;
wire       instr1_rd_r2_vld_nq;
wire[4:0]  instr1_rd_r2_addr_nq;
wire       instr1_wr_vld_nq;
wire[4:0]  instr1_wr_addr_nq;
wire[31:0] instr1_imm_nq;
wire       instr1_use_imm_nq;
wire       instr1_is_ls_nq;
wire       instr1_is_alu_nq;
wire       instr1_is_mul_nq;
wire       instr1_is_div_nq;
wire       instr1_is_br_nq;
wire       instr1_is_fp_nq;
wire       instr1_is_csr_nq;
wire[2:0]  instr1_ls_op_nq;
wire[3:0]  instr1_alu_op_nq;
wire[1:0]  instr1_mul_op_nq;
wire[1:0]  instr1_div_op_nq;
wire[2:0]  instr1_br_op_nq;

wire instr1_is_compressed = ifu_dpu_instr_vld[1];
wire instr1_vld = ifu_dpu_instr_vld[1];
wire[31:0] instr1_op = ifu_dpu_instr[31:16];

peak_dpu_de1 u_de1(
                   .instr1_is_compressed(instr1_is_compressed   ),
                   .instr1_vld          (instr1_vld             ),
                   .instr1_op           (instr1_op              ),
                   .instr1_rd_r0_vld    (instr1_rd_r0_vld_nq    ),
                   .instr1_rd_r0_addr   (instr1_rd_r0_addr_nq   ),
                   .instr1_rd_r1_vld    (instr1_rd_r1_vld_nq    ),
                   .instr1_rd_r1_addr   (instr1_rd_r1_addr_nq   ),
                   .instr1_rd_r2_vld    (instr1_rd_r2_vld_nq    ),
                   .instr1_rd_r2_addr   (instr1_rd_r2_addr_nq   ),
                   .instr1_wr_vld       (instr1_wr_vld_nq       ),
                   .instr1_wr_addr      (instr1_wr_addr_nq      ),
                   .instr1_imm          (instr1_imm_nq          ),
                   .instr1_use_imm      (instr1_use_imm_nq      ),
                   .instr1_is_ls        (instr1_is_ls_nq        ),
                   .instr1_is_alu       (instr1_is_alu_nq       ),
                   .instr1_is_mul       (instr1_is_mul_nq       ),
                   .instr1_is_div       (instr1_is_div_nq       ),
                   .instr1_is_br        (instr1_is_br_nq        ),
                   .instr1_is_fp        (instr1_is_fp_nq        ),
                   .instr1_is_csr       (instr1_is_csr_nq       ),
                   .instr1_ls_op        (instr1_ls_op_nq        ),
                   .instr1_alu_op       (instr1_alu_op_nq       ),
                   .instr1_mul_op       (instr1_mul_op_nq       ),
                   .instr1_div_op       (instr1_div_op_nq       ),
                   .instr1_br_op        (instr1_br_op_nq        )        
                   );

wire      instr0_cannot_iss;
wire      instr1_cannot_iss;
wire[6:0] instr0_r0_fwd_sel;
wire[6:0] instr0_r1_fwd_sel;
wire[6:0] instr1_r0_fwd_sel;
wire[6:0] instr1_r1_fwd_sel;

peak_dpu_dsp_ctl u_dsp_ctl(
                           .instr0_vld        (instr0_vld            ),
                           .instr0_rd_r0_vld  (instr0_rd_r0_vld_nq   ),
                           .instr0_rd_r0_addr (instr0_rd_r0_addr_nq  ),
                           .instr0_rd_r1_vld  (instr0_rd_r1_vld_nq   ),
                           .instr0_rd_r1_addr (instr0_rd_r1_addr_nq  ),
                           .instr0_rd_r2_vld  (instr0_rd_r2_vld_nq   ),
                           .instr0_rd_r2_addr (instr0_rd_r2_addr_nq  ),
                           .instr0_wr_vld     (instr0_wr_vld_nq      ),
                           .instr0_wr_addr    (instr0_wr_addr_nq     ),
                           .instr0_is_alu     (instr0_is_alu_nq      ),
                           .instr0_is_mul     (instr0_is_mul_nq      ),
                           .instr0_is_div     (instr0_is_div_nq      ),
                           .instr0_is_ld      (instr0_is_ld_nq       ),
                           .instr0_is_jal     (instr0_is_jal_nq      ),
                           .instr0_is_ls      (instr0_is_ls_nq       ),
                           .instr0_is_br      (instr0_is_br_nq       ),
                           .instr0_is_csr     (instr0_is_csr_nq      ),
                           .instr0_is_fp      (instr0_is_fp_nq       ),
                           .instr1_vld        (instr1_vld_nq         ),
                           .instr1_rd_r0_vld  (instr1_rd_r0_vld_nq   ),
                           .instr1_rd_r0_addr (instr1_rd_r0_addr_nq  ),
                           .instr1_rd_r1_vld  (instr1_rd_r1_vld_nq   ),
                           .instr1_rd_r1_addr (instr1_rd_r1_addr_nq  ),
                           .instr1_rd_r2_vld  (instr1_rd_r2_vld_nq   ),
                           .instr1_rd_r2_addr (instr1_rd_r2_addr_nq  ),
                           .instr1_wr_vld     (instr1_wr_vld_nq      ),
                           .instr1_wr_addr    (instr1_wr_addr_nq     ),
                           .instr1_is_alu     (instr1_is_alu_nq      ),
                           .instr1_is_mul     (instr1_is_mul_nq      ),
                           .instr1_is_div     (instr1_is_div_nq      ),
                           .instr1_is_ld      (instr1_is_ld_nq       ),
                           .instr1_is_jal     (instr1_is_jal_nq      ),
                           .instr1_is_ls      (instr1_is_ls_nq       ),
                           .instr1_is_br      (instr1_is_br_nq       ),
                           .instr1_is_csr     (instr1_is_csr_nq      ),
                           .instr1_is_fp      (instr1_is_fp_nq       ),
                           .alu0_wr_vld_ex    (alu0_wr_vld_ex        ),
                           .alu0_wr_addr_ex   (alu0_wr_addr_ex       ),
                           .alu1_wr_vld_ex    (alu1_wr_vld_ex        ),
                           .alu1_wr_addr_ex   (alu1_wr_addr_ex       ),
                           .mul_wr_vld_ex     (mul_wr_vld_ex         ),
                           .mul_busy          (mul_busy              ),
                           .mul_wr_addr_ex    (mul_wr_addr_ex        ),
                           .div_wr_vld_ex     (div_wr_vld_ex         ),
                           .div_busy          (div_busy              ),
                           .div_wr_addr_ex    (div_wr_addr_ex        ),
                           .lsu_wr_vld_ex     (lsu_wr_vld_ex         ),
                           .lsu_wr_addr_ex    (lsu_wr_addr_ex        ),
                           .lsu_wr_vld_ret    (lsu_wr_vld_ret        ),
                           .lsu_wr_addr_ret   (lsu_wr_addr_ret       ),
                           .csr_wr_vld_ex     (csr_wr_vld_ex         ),
                           .csr_wr_addr_ex    (csr_wr_addr_ex        ),
                           .fp_wr_vld         (fp_wr_vld             ),
                           .fp_busy           (fp_busy               ),
                           .fp_wr_addr        (fp_wr_addr            ),
			   .instr0_need_rd_eq0 (instr0_need_rd_eq0   ),
			   .instr1_need_rd_eq0 (instr1_need_rd_eq0   ),
                           .instr0_cannot_iss (instr0_cannot_iss     ),
                           .instr1_cannot_iss (instr1_cannot_iss     ),
                           .instr0_r0_fwd_sel (instr0_r0_fwd_sel     ),
                           .instr0_r1_fwd_sel (instr0_r1_fwd_sel     ),
                           .instr0_r2_fwd_sel (instr0_r2_fwd_sel     ),
                           .instr1_r0_fwd_sel (instr1_r0_fwd_sel     ),
                           .instr1_r1_fwd_sel (instr1_r1_fwd_sel     ),
                           .instr1_r2_fwd_sel (instr1_r2_fwd_sel     )
                           );

assign dpu_ifu_rdy = instr0_cannot_iss |
                     instr1_cannot_iss ;	


reg       instr0_wr_vld;
reg[4:0]  instr0_wr_addr;
reg[31:0] instr0_imm;
reg       instr0_use_imm;
reg       instr1_wr_vld;
reg[4:0]  instr1_wr_addr;
reg[31:0] instr1_imm;
reg       instr1_use_imm;
reg       instr0_is_ls;
reg       instr0_is_alu;
reg       instr0_is_mul;
reg       instr0_is_div;
reg       instr0_is_br;
reg       instr0_is_fp;
reg       instr0_is_csr;
reg       instr1_is_ls;
reg       instr1_is_alu;
reg       instr1_is_mul;
reg       instr1_is_div;
reg       instr1_is_br;
reg       instr1_is_fp;
reg       instr1_is_csr;
reg[2:0]  instr0_ls_op;
reg[3:0]  instr0_alu_op;
reg[1:0]  instr0_mul_op;
reg[1:0]  instr0_div_op;
reg[2:0]  instr0_br_op;
reg[2:0]  instr1_ls_op;
reg[3:0]  instr1_alu_op;
reg[1:0]  instr1_mul_op;
reg[1:0]  instr1_div_op;
reg[2:0]  instr1_br_op;

wire clk_gated; //TODO
always @ (posedge clk_gated or negedge rst_n) begin
    if(rst_n == 1'b0) begin
      instr0_wr_vld  <= 1'b0;
      instr0_use_imm <= 1'b0;
      instr0_is_ls   <= 1'b0;
      instr0_is_alu  <= 1'b0;
      instr0_is_mul  <= 1'b0;
      instr0_is_div  <= 1'b0;
      instr0_is_br   <= 1'b0;
      instr0_is_fp   <= 1'b0;
      instr0_is_csr  <= 1'b0;
    end
    else if(instr0_vld & ~instr0_cannot_iss) begin
      instr0_wr_vld  <= instr0_wr_vld_nq ;
      instr0_use_imm <= instr0_use_imm_nq;
      instr0_is_ls   <= instr0_is_ls_nq  ;
      instr0_is_alu  <= instr0_is_alu_nq ;
      instr0_is_mul  <= instr0_is_mul_nq ;
      instr0_is_div  <= instr0_is_div_nq ;
      instr0_is_br   <= instr0_is_br_nq  ;
      instr0_is_fp   <= instr0_is_fp_nq  ;
      instr0_is_csr  <= instr0_is_csr_nq ;
    end
end

always @ (posedge clk_gated) begin
    if(instr0_vld & ~instr0_cannot_iss) begin
         instr0_ls_op  <= instr0_ls_op_nq ;
         instr0_alu_op <= instr0_alu_op_nq;
         instr0_mul_op <= instr0_mul_op_nq;
         instr0_div_op <= instr0_div_op_nq;
         instr0_br_op  <= instr0_br_op_nq ;
         instr0_ls_op  <= instr0_ls_op_nq ;
    end
end

always @ (posedge clk_gated or negedge rst_n) begin
    if(rst_n == 1'b0) begin
      instr1_wr_vld  <= 1'b0;
      instr1_use_imm <= 1'b0;
      instr1_is_ls   <= 1'b0;
      instr1_is_alu  <= 1'b0;
      instr1_is_mul  <= 1'b0;
      instr1_is_div  <= 1'b0;
      instr1_is_br   <= 1'b0;
      instr1_is_fp   <= 1'b0;
      instr1_is_csr  <= 1'b0;
    end
    else if(instr1_vld & ~instr1_cannot_iss) begin
      instr1_wr_vld  <= instr1_wr_vld_nq ;
      instr1_use_imm <= instr1_use_imm_nq;
      instr1_is_ls   <= instr1_is_ls_nq  ;
      instr1_is_alu  <= instr1_is_alu_nq ;
      instr1_is_mul  <= instr1_is_mul_nq ;
      instr1_is_div  <= instr1_is_div_nq ;
      instr1_is_br   <= instr1_is_br_nq  ;
      instr1_is_fp   <= instr1_is_fp_nq  ;
      instr1_is_csr  <= instr1_is_csr_nq ;
    end
end

always @ (posedge clk_gated) begin
    if(instr1_vld & ~instr1_cannot_iss) begin
         instr1_ls_op  <= instr1_ls_op_nq ;
         instr1_alu_op <= instr1_alu_op_nq;
         instr1_mul_op <= instr1_mul_op_nq;
         instr1_div_op <= instr1_div_op_nq;
         instr1_br_op  <= instr1_br_op_nq ;
         instr1_ls_op  <= instr1_ls_op_nq ;
    end
end

reg instr0_not_issued;
wire instr0_not_issued_set = instr0_vld & instr0_cannot_iss
wire instr0_not_issued_clr = instr0_vld & ~instr0_cannot_iss;
wire instr0_not_issued_en;
always @ (posedge clk_gated or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        instr0_not_issued <= 1'b0;
    end
    else if(instr0_not_issue_en) begin
	instr0_not_issued <= instr0_not_issued_set;
    end	  
end


assign regbank_rd_addr0 = instr0_need_rd_eq0 ? (instr1_need_r0_eq0 ? 5'h0: instr1_rd_r0_addr_nq) :
	                                       instr0_rd_r0_addr_nq;
assign regbank_rd_addr1 = instr0_need_rd_r0_eq0 ? (instr1_need_r0_eq0 ? 5'h0: instr1_rd_r1_addr_nq) :
	                                       instr1_rd_r1_addr_nq;
assign regbank_rd_addr2 = instr0_need_rd_r0_eq0 ? (instr1_need_r0_eq0 ? 5'h0: instr1_rd_r2_addr_nq) :
	                                        instr1_rd_r2_addr_nq;
	

wire[31:0] instr0_op0_af_mux = {32{instr0_r0_fwd_sel[0]}} & alu0_wr_data_ex |
	                       {32{instr0_r0_fwd_sel[1]}} & alu1_wr_data_ex |
	                       {32{instr0_r0_fwd_sel[2]}} & alu0_wr_data_ex |
	                       {32{instr0_r0_fwd_sel[3]}} & alu0_wr_data_ex |
	                       {32{instr0_r0_fwd_sel[4]}} & lsu_wr_data_ret |
	                       {32{instr0_r0_fwd_sel[5]}} & alu_wr_data_ex  |
	                       {32{instr0_r0_fwd_sel[6]}} & fp_wr_data      |
			       {32{~(|instr0_r0_fwd_sel)}} & regbank_rdata0 ;

wire[31:0] instr0_op1_af_mux = {32{instr0_r1_fwd_sel[0]}} & alu0_wr_data_ex |
	                       {32{instr0_r1_fwd_sel[1]}} & alu1_wr_data_ex |
	                       {32{instr0_r1_fwd_sel[2]}} & alu0_wr_data_ex |
	                       {32{instr0_r1_fwd_sel[3]}} & alu0_wr_data_ex |
	                       {32{instr0_r1_fwd_sel[4]}} & lsu_wr_data_ret |
	                       {32{instr0_r1_fwd_sel[5]}} & alu_wr_data_ex  |
	                       {32{instr0_r1_fwd_sel[6]}} & fp_wr_data      |
			       {32{~(|instr0_r1_fwd_sel)}} & regbank_rdata1 ;

wire[31:0] instr0_op2_af_mux = {32{instr0_r2_fwd_sel[0]}} & alu0_wr_data_ex |
	                       {32{instr0_r2_fwd_sel[1]}} & alu1_wr_data_ex |
	                       {32{instr0_r2_fwd_sel[2]}} & alu0_wr_data_ex |
	                       {32{instr0_r2_fwd_sel[3]}} & alu0_wr_data_ex |
	                       {32{instr0_r2_fwd_sel[4]}} & lsu_wr_data_ret |
	                       {32{instr0_r2_fwd_sel[5]}} & alu_wr_data_ex  |
	                       {32{instr0_r2_fwd_sel[6]}} & fp_wr_data      |
			       {32{~(|instr0_r2_fwd_sel)}} & regbank_rdata2 ;

wire[31:0] instr1_op0_af_mux = {32{instr1_r0_fwd_sel[0]}} & alu0_wr_data_ex |
	                       {32{instr1_r0_fwd_sel[1]}} & alu1_wr_data_ex |
	                       {32{instr1_r0_fwd_sel[2]}} & alu0_wr_data_ex |
	                       {32{instr1_r0_fwd_sel[3]}} & alu0_wr_data_ex |
	                       {32{instr1_r0_fwd_sel[4]}} & lsu_wr_data_ret |
	                       {32{instr1_r0_fwd_sel[5]}} & alu_wr_data_ex  |
	                       {32{instr1_r0_fwd_sel[6]}} & fp_wr_data      |
			       {32{~(|instr1_r0_fwd_sel)}} & regbank_rdata0 ;

wire[31:0] instr1_op1_af_mux = {32{instr1_r1_fwd_sel[0]}} & alu0_wr_data_ex |
	                       {32{instr1_r1_fwd_sel[1]}} & alu1_wr_data_ex |
	                       {32{instr1_r1_fwd_sel[2]}} & alu0_wr_data_ex |
	                       {32{instr1_r1_fwd_sel[3]}} & alu0_wr_data_ex |
	                       {32{instr1_r1_fwd_sel[4]}} & lsu_wr_data_ret |
	                       {32{instr1_r1_fwd_sel[5]}} & alu_wr_data_ex  |
	                       {32{instr1_r1_fwd_sel[6]}} & fp_wr_data      |
			       {32{~(|instr1_r1_fwd_sel)}} & regbank_rdata1 ;

wire[31:0] instr1_op2_af_mux = {32{instr1_r2_fwd_sel[0]}} & alu0_wr_data_ex |
	                       {32{instr1_r2_fwd_sel[1]}} & alu1_wr_data_ex |
	                       {32{instr1_r2_fwd_sel[2]}} & alu0_wr_data_ex |
	                       {32{instr1_r2_fwd_sel[3]}} & alu0_wr_data_ex |
	                       {32{instr1_r2_fwd_sel[4]}} & lsu_wr_data_ret |
	                       {32{instr1_r2_fwd_sel[5]}} & alu_wr_data_ex  |
	                       {32{instr1_r2_fwd_sel[6]}} & fp_wr_data      |
			       {32{~(|instr1_r2_fwd_sel)}} & regbank_rdata2 ;


reg[31:0] instr0_op0;
reg[31:0] instr0_op1;
reg[31:0] instr0_op2;
reg[31:0] instr1_op0;
reg[31:0] instr1_op1;
reg[31:0] instr1_op2;

always @ (posedge clk_gated) begin
    if(instr0_vld & ~instr0_cannot_iss) begin
         instr0_op0 <= instr0_op0_af_mux ;
         instr0_op1 <= instr0_op1_af_mux;
         instr0_op2 <= instr0_op2_af_mux;
    end
end

always @ (posedge clk_gated) begin
    if(instr1_vld & ~instr1_cannot_iss) begin
         instr1_op0 <= instr1_op0_af_mux ;
         instr1_op1 <= instr1_op1_af_mux;
         instr1_op2 <= instr1_op2_af_mux;
    end
end


endmodule
