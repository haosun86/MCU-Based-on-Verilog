////////////////////////////////////////////////////////////
// File Description: 
// This file is main decoder top file
//
// 
// Date:   2019.09.18
///////////////////////////////////////////////////////////

module peak_dpu_de0
(

instr0_is_compressed,
instr0_vld,
instr0_op,


instr0_rd_r0_vld,
instr0_rd_r0_addr,
instr0_rd_r1_vld,
instr0_rd_r1_addr,
instr0_rd_r2_vld,
instr0_rd_r2_addr,
instr0_wr_vld,
instr0_wr_addr,
instr0_imm,
instr0_use_imm,

instr0_is_ls,
instr0_is_alu,
instr0_is_mul,
instr0_is_div,
instr0_is_br,
instr0_is_fp,
instr0_is_csr,

instr0_ls_op,
instr0_alu_op,
instr0_mul_op,
instr0_div_op,
instr0_br_op

);

input        instr0_is_compressed;
input        instr0_vld;
input[31:0]  instr0_op;


output       instr0_rd_r0_vld;
output[4:0]  instr0_rd_r0_addr;
output       instr0_rd_r1_vld;
output[4:0]  instr0_rd_r1_addr;
output       instr0_rd_r2_vld;
output[4:0]  instr0_rd_r2_addr;
output       instr0_wr_vld;
output[4:0]  instr0_wr_addr;
output[31:0] instr0_imm;
output       instr0_use_imm;

output       instr0_is_ls;
output       instr0_is_alu;
output       instr0_is_mul;
output       instr0_is_div;
output       instr0_is_br;
output       instr0_is_fp;
output       instr0_is_csr;

output[2:0]  instr0_ls_op;
output[3:0]  instr0_alu_op;
output[1:0]  instr0_mul_op;
output[1:0]  instr0_div_op;
output[2:0]  instr0_br_op;

wire       instr0_dp_rd_r0_vld;
wire[4:0]  instr0_dp_rd_r0_addr;
wire       instr0_dp_rd_r1_vld;
wire[4:0]  instr0_dp_rd_r1_addr;
wire       instr0_dp_rd_r2_vld;
wire[4:0]  instr0_dp_rd_r2_addr;
wire       instr0_dp_wr_vld;
wire[4:0]  instr0_dp_wr_addr;
wire[31:0] instr0_dp_imm;
wire       instr0_dp_use_imm;

peak_dpu_de_dp u_de_dp (
                        .instr_is_compressed(instr0_is_compressed),
                        .instr_vld          (instr0_vld),
                        .instr_op           (instr0_op),
                        .instr_rd_r0_vld    (instr0_dp_rd_r0_vld ),
                        .instr_rd_r0_addr   (instr0_dp_rd_r0_addr),
                        .instr_rd_r1_vld    (instr0_dp_rd_r1_vld ),
                        .instr_rd_r1_addr   (instr0_dp_rd_r1_addr),
                        .instr_rd_r2_vld    (instr0_dp_rd_r2_vld ),
                        .instr_rd_r2_addr   (instr0_dp_rd_r2_addr),
                        .instr_wr_vld       (instr0_dp_wr_vld    ),
                        .instr_wr_addr      (instr0_dp_wr_addr   ),
                        .instr_imm          (instr0_dp_imm       ),
                        .instr_use_imm      (instr0_dp_use_imm   ),
                        .instr_is_alu       (instr0_is_alu    ),
                        .instr_is_mul       (instr0_is_mul    ),
                        .instr_is_div       (instr0_is_div    ),
                        .instr_alu_op       (instr0_alu_op    ),
                        .instr_mul_op       (instr0_mul_op    ),
                        .instr_div_op       (instr0_div_op    )
                       );

wire       instr0_ls_rd_r0_vld;
wire[4:0]  instr0_ls_rd_r0_addr;
wire       instr0_ls_rd_r1_vld;
wire[4:0]  instr0_ls_rd_r1_addr;
wire       instr0_ls_rd_r2_vld;
wire[4:0]  instr0_ls_rd_r2_addr;
wire       instr0_ls_wr_vld;
wire[4:0]  instr0_ls_wr_addr;
wire[31:0] instr0_ls_imm;
wire       instr0_ls_use_imm;

peak_dpu_de_ls u_de_ls (
                        .instr_is_compressed(instr0_is_compressed),
                        .instr_vld          (instr0_vld),
                        .instr_op           (instr0_op),
                        .instr_rd_r0_vld    (instr0_ls_rd_r0_vld ),
                        .instr_rd_r0_addr   (instr0_ls_rd_r0_addr),
                        .instr_rd_r1_vld    (instr0_ls_rd_r1_vld ),
                        .instr_rd_r1_addr   (instr0_ls_rd_r1_addr),
                        .instr_rd_r2_vld    (instr0_ls_rd_r2_vld ),
                        .instr_rd_r2_addr   (instr0_ls_rd_r2_addr),
                        .instr_wr_vld       (instr0_ls_wr_vld    ),
                        .instr_wr_addr      (instr0_ls_wr_addr   ),
                        .instr_imm          (instr0_ls_imm       ),
                        .instr_use_imm      (instr0_ls_use_imm   ),
                        .instr_is_ld        (instr0_is_ld    ),
                        .instr_is_ls        (instr0_is_ls    ),
                        .instr_div_op       (instr0_ls_op    )
                       );

wire       instr0_br_rd_r0_vld;
wire[4:0]  instr0_br_rd_r0_addr;
wire       instr0_br_rd_r1_vld;
wire[4:0]  instr0_br_rd_r1_addr;
wire       instr0_br_rd_r2_vld;
wire[4:0]  instr0_br_rd_r2_addr;
wire       instr0_br_wr_vld;
wire[4:0]  instr0_br_wr_addr;
wire[31:0] instr0_br_imm;
wire       instr0_br_use_imm;

peak_dpu_de_br u_de_br (
                        .instr_is_compressed(instr0_is_compressed),
                        .instr_vld          (instr0_vld),
                        .instr_op           (instr0_op),
                        .instr_rd_r0_vld    (instr0_br_rd_r0_vld ),
                        .instr_rd_r0_addr   (instr0_br_rd_r0_addr),
                        .instr_rd_r1_vld    (instr0_br_rd_r1_vld ),
                        .instr_rd_r1_addr   (instr0_br_rd_r1_addr),
                        .instr_rd_r2_vld    (instr0_br_rd_r2_vld ),
                        .instr_rd_r2_addr   (instr0_br_rd_r2_addr),
                        .instr_wr_vld       (instr0_br_wr_vld    ),
                        .instr_wr_addr      (instr0_br_wr_addr   ),
                        .instr_imm          (instr0_br_imm       ),
                        .instr_use_imm      (instr0_br_use_imm   ),
                        .instr_is_jal       (instr0_is_jal   ),
                        .instr_is_br        (instr0_is_br    ),
                        .instr_div_op       (instr0_br_op    )
                       );


assign instr0_rd_r0_vld  = instr0_vld & 
	                   ((instr0_is_dp & instr0_dp_rd_r0_vld) ||
                            (instr0_is_ls & instr0_ls_rd_r0_vld) ||
                            (instr0_is_br & instr0_br_rd_r0_vld) );

assign instr0_rd_r0_addr = {5{instr0_is_dp}} & instr0_dp_rd_r0_addr |
	                   {5{instr0_is_ls}} & instr0_ls_rd_r0_addr |
	                   {5{instr0_is_br}} & instr0_br_rd_r0_addr ;

assign instr0_rd_r1_vld  = instr0_vld & 
	                   ((instr0_is_dp & instr0_dp_rd_r1_vld) ||
                            (instr0_is_ls & instr0_ls_rd_r1_vld) ||
                            (instr0_is_br & instr0_br_rd_r1_vld) );

assign instr0_rd_r1_addr = {5{instr0_is_dp}} & instr0_dp_rd_r1_addr |
	                   {5{instr0_is_ls}} & instr0_ls_rd_r1_addr |
	                   {5{instr0_is_br}} & instr0_br_rd_r1_addr ;

assign instr0_rd_r2_vld  = instr0_vld & 
	                   ((instr0_is_dp & instr0_dp_rd_r2_vld) ||
                            (instr0_is_ls & instr0_ls_rd_r2_vld) ||
                            (instr0_is_br & instr0_br_rd_r2_vld) );

assign instr0_rd_r2_addr = {5{instr0_is_dp}} & instr0_dp_rd_r2_addr |
	                   {5{instr0_is_ls}} & instr0_ls_rd_r2_addr |
	                   {5{instr0_is_br}} & instr0_br_rd_r2_addr ;

assign instr0_wr_vld  = instr0_vld & 
	                ((instr0_is_dp & instr0_dp_wr_vld) ||
                         (instr0_is_ls & instr0_ls_wr_vld) ||
                         (instr0_is_br & instr0_br_wr_vld) );

assign instr0_wr_addr = {5{instr0_is_dp}} & instr0_dp_wr_addr |
	                {5{instr0_is_ls}} & instr0_ls_wr_addr |
	                {5{instr0_is_br}} & instr0_br_wr_addr ;

assign instr0_imm = {32{instr0_is_dp}} & instr0_dp_imm |
                    {32{instr0_is_ls}} & instr0_ls_imm |
                    {32{instr0_is_br}} & instr0_br_imm ;

assign instr0_use_imm = instr0_vld &
	                ((instr0_is_dp & instr0_dp_use_imm) ||
			 (instr0_is_ls & instr0_ls_use_imm) ||
			 (instr0_is_br & instr0_br_use_imm)) ;;


endmodule
