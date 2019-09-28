////////////////////////////////////////////////////////////
// File Description: 
// This file is compressed isa decoder top file
//
// 
// Date:   2019.09.18
///////////////////////////////////////////////////////////

module peak_dpu_de1
(

instr1_is_compressed,
instr1_vld,
instr1_op,


instr1_rd_r0_vld,
instr1_rd_r0_addr,
instr1_rd_r1_vld,
instr1_rd_r1_addr,
instr1_rd_r2_vld,
instr1_rd_r2_addr,
instr1_wr_vld,
instr1_wr_addr,
instr1_imm,
instr1_use_imm,

instr1_is_ls,
instr1_is_alu,
instr1_is_mul,
instr1_is_div,
instr1_is_br,
instr1_is_fp,
instr1_is_csr,

instr1_ls_op,
instr1_alu_op,
instr1_mul_op,
instr1_div_op,
instr1_br_op

);

input        instr1_is_compressed;
input        instr1_vld;
input[31:0]  instr1_op;


output       instr1_rd_r0_vld;
output[4:0]  instr1_rd_r0_addr;
output       instr1_rd_r1_vld;
output[4:0]  instr1_rd_r1_addr;
output       instr1_rd_r2_vld;
output[4:0]  instr1_rd_r2_addr;
output       instr1_wr_vld;
output[4:0]  instr1_wr_addr;
output[31:0] instr1_imm;
output       instr1_use_imm;

output       instr1_is_ls;
output       instr1_is_alu;
output       instr1_is_mul;
output       instr1_is_div;
output       instr1_is_br;
output       instr1_is_fp;
output       instr1_is_csr;

output[2:0]  instr1_ls_op;
output[3:0]  instr1_alu_op;
output[1:0]  instr1_mul_op;
output[1:0]  instr1_div_op;
output[2:0]  instr1_br_op;

wire       instr1_dp_rd_r0_vld;
wire[4:0]  instr1_dp_rd_r0_addr;
wire       instr1_dp_rd_r1_vld;
wire[4:0]  instr1_dp_rd_r1_addr;
wire       instr1_dp_rd_r2_vld;
wire[4:0]  instr1_dp_rd_r2_addr;
wire       instr1_dp_wr_vld;
wire[4:0]  instr1_dp_wr_addr;
wire[31:0] instr1_dp_imm;
wire       instr1_dp_use_imm;

peak_dpu_de_dp u_de_dp16 (
                          .instr_is_compressed(instr1_is_compressed),
                          .instr_vld          (instr1_vld),
                          .instr_op           (instr1_op),
                          .instr_rd_r0_vld    (instr1_dp_rd_r0_vld ),
                          .instr_rd_r0_addr   (instr1_dp_rd_r0_addr),
                          .instr_rd_r1_vld    (instr1_dp_rd_r1_vld ),
                          .instr_rd_r1_addr   (instr1_dp_rd_r1_addr),
                          .instr_rd_r2_vld    (instr1_dp_rd_r2_vld ),
                          .instr_rd_r2_addr   (instr1_dp_rd_r2_addr),
                          .instr_wr_vld       (instr1_dp_wr_vld    ),
                          .instr_wr_addr      (instr1_dp_wr_addr   ),
                          .instr_imm          (instr1_dp_imm       ),
                          .instr_use_imm      (instr1_dp_use_imm   ),
                          .instr_is_alu       (instr1_is_alu    ),
                          .instr_is_mul       (instr1_is_mul    ),
                          .instr_is_div       (instr1_is_div    ),
                          .instr_alu_op       (instr1_alu_op    ),
                          .instr_mul_op       (instr1_mul_op    ),
                          .instr_div_op       (instr1_div_op    )
                         );

wire       instr1_ls_rd_r0_vld;
wire[4:0]  instr1_ls_rd_r0_addr;
wire       instr1_ls_rd_r1_vld;
wire[4:0]  instr1_ls_rd_r1_addr;
wire       instr1_ls_rd_r2_vld;
wire[4:0]  instr1_ls_rd_r2_addr;
wire       instr1_ls_wr_vld;
wire[4:0]  instr1_ls_wr_addr;
wire[31:0] instr1_ls_imm;
wire       instr1_ls_use_imm;

peak_dpu_de_ls u_de_ls16 (
                          .instr_is_compressed(instr1_is_compressed),
                          .instr_vld          (instr1_vld),
                          .instr_op           (instr1_op),
                          .instr_rd_r0_vld    (instr1_ls_rd_r0_vld ),
                          .instr_rd_r0_addr   (instr1_ls_rd_r0_addr),
                          .instr_rd_r1_vld    (instr1_ls_rd_r1_vld ),
                          .instr_rd_r1_addr   (instr1_ls_rd_r1_addr),
                          .instr_rd_r2_vld    (instr1_ls_rd_r2_vld ),
                          .instr_rd_r2_addr   (instr1_ls_rd_r2_addr),
                          .instr_wr_vld       (instr1_ls_wr_vld    ),
                          .instr_wr_addr      (instr1_ls_wr_addr   ),
                          .instr_imm          (instr1_ls_imm       ),
                          .instr_use_imm      (instr1_ls_use_imm   ),
                          .instr_is_ld        (instr1_is_ld    ),
                          .instr_is_ls        (instr1_is_ls    ),
                          .instr_div_op       (instr1_ls_op    )
                         );

wire       instr1_br_rd_r0_vld;
wire[4:0]  instr1_br_rd_r0_addr;
wire       instr1_br_rd_r1_vld;
wire[4:0]  instr1_br_rd_r1_addr;
wire       instr1_br_rd_r2_vld;
wire[4:0]  instr1_br_rd_r2_addr;
wire       instr1_br_wr_vld;
wire[4:0]  instr1_br_wr_addr;
wire[31:0] instr1_br_imm;
wire       instr1_br_use_imm;

peak_dpu_de_br u_de_br16 (
                          .instr_is_compressed(instr1_is_compressed),
                          .instr_vld          (instr1_vld),
                          .instr_op           (instr1_op),
                          .instr_rd_r0_vld    (instr1_br_rd_r0_vld ),
                          .instr_rd_r0_addr   (instr1_br_rd_r0_addr),
                          .instr_rd_r1_vld    (instr1_br_rd_r1_vld ),
                          .instr_rd_r1_addr   (instr1_br_rd_r1_addr),
                          .instr_rd_r2_vld    (instr1_br_rd_r2_vld ),
                          .instr_rd_r2_addr   (instr1_br_rd_r2_addr),
                          .instr_wr_vld       (instr1_br_wr_vld    ),
                          .instr_wr_addr      (instr1_br_wr_addr   ),
                          .instr_imm          (instr1_br_imm       ),
                          .instr_use_imm      (instr1_br_use_imm   ),
                          .instr_is_jal       (instr1_is_jal   ),
                          .instr_is_br        (instr1_is_br    ),
                          .instr_div_op       (instr1_br_op    )
                         );


assign instr1_rd_r0_vld  = instr1_vld & 
	                   ((instr1_is_dp & instr1_dp_rd_r0_vld) ||
                            (instr1_is_ls & instr1_ls_rd_r0_vld) ||
                            (instr1_is_br & instr1_br_rd_r0_vld) );

assign instr1_rd_r0_addr = {5{instr1_is_dp}} & instr1_dp_rd_r0_addr |
	                   {5{instr1_is_ls}} & instr1_ls_rd_r0_addr |
	                   {5{instr1_is_br}} & instr1_br_rd_r0_addr ;

assign instr1_rd_r1_vld  = instr1_vld & 
	                   ((instr1_is_dp & instr1_dp_rd_r1_vld) ||
                            (instr1_is_ls & instr1_ls_rd_r1_vld) ||
                            (instr1_is_br & instr1_br_rd_r1_vld) );

assign instr1_rd_r1_addr = {5{instr1_is_dp}} & instr1_dp_rd_r1_addr |
	                   {5{instr1_is_ls}} & instr1_ls_rd_r1_addr |
	                   {5{instr1_is_br}} & instr1_br_rd_r1_addr ;

assign instr1_rd_r2_vld  = instr1_vld & 
	                   ((instr1_is_dp & instr1_dp_rd_r2_vld) ||
                            (instr1_is_ls & instr1_ls_rd_r2_vld) ||
                            (instr1_is_br & instr1_br_rd_r2_vld) );

assign instr1_rd_r2_addr = {5{instr1_is_dp}} & instr1_dp_rd_r2_addr |
	                   {5{instr1_is_ls}} & instr1_ls_rd_r2_addr |
	                   {5{instr1_is_br}} & instr1_br_rd_r2_addr ;

assign instr1_wr_vld  = instr1_vld & 
	                ((instr1_is_dp & instr1_dp_wr_vld) ||
                         (instr1_is_ls & instr1_ls_wr_vld) ||
                         (instr1_is_br & instr1_br_wr_vld) );

assign instr1_wr_addr = {5{instr1_is_dp}} & instr1_dp_wr_addr |
	                {5{instr1_is_ls}} & instr1_ls_wr_addr |
	                {5{instr1_is_br}} & instr1_br_wr_addr ;

assign instr1_imm = {32{instr1_is_dp}} & instr1_dp_imm |
                    {32{instr1_is_ls}} & instr1_ls_imm |
                    {32{instr1_is_br}} & instr1_br_imm ;

assign instr1_use_imm = instr1_vld &
	                ((instr1_is_dp & instr1_dp_use_imm) ||
			 (instr1_is_ls & instr1_ls_use_imm) ||
			 (instr1_is_br & instr1_br_use_imm)) ;;


endmodule
