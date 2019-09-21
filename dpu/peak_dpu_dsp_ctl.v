////////////////////////////////////////////////////////////
// File Description: 
// This file aims to detect the potential hazards to determine
// how to dispatch instructions.This block is needed with
// the main reason that we need to support dual issue for 
// compressed instructions. To support dual issue, we can 
// support 2 alus without mul/div, which will not take much
// areas.
//
// 
// Date:   2019.09.18
///////////////////////////////////////////////////////////

module peak_dpu_dsp_ctl
(

);

input        instr0_vld;
input        instr0_rd_r0_vld;
input[4:0]   instr0_rd_r0_addr;
input        instr0_rd_r1_vld;
input[4:0]   instr0_rd_r1_addr;
input        instr0_rd_r2_vld;
input[4:0]   instr0_rd_r2_addr;
input        instr0_wr_vld;
input[4:0]   instr0_wr_addr;
input        instr0_is_alu;
input        instr0_is_mul;
input        instr0_is_div;
input        instr0_is_ld;
input        instr0_is_jal;
input        instr0_is_ls;
input        instr0_is_br;
input        instr0_is_csr;
input        instr0_is_fp;

input        instr1_vld;
input        instr1_rd_r0_vld;
input[4:0]   instr1_rd_r0_addr;
input        instr1_rd_r1_vld;
input[4:0]   instr1_rd_r1_addr;
input        instr1_rd_r2_vld;
input[4:0]   instr1_rd_r2_addr;
input        instr1_wr_vld;
input[4:0]   instr1_wr_addr;
input        instr1_is_alu;
input        instr1_is_mul;
input        instr1_is_div;
input        instr1_is_ld;
input        instr1_is_jal;
input        instr1_is_ls;
input        instr1_is_br;
input        instr1_is_csr;
input        instr1_is_fp;

input        alu0_wr_vld_ex;
input[4:0]   alu0_wr_addr_ex;
input        alu1_wr_vld_ex;
input[4:0]   alu1_wr_addr_ex;
input        mul_wr_vld_ex;
input[4:0]   mul_wr_addr_ex;
input        div_wr_vld_ex;
input        div_busy;
input[4:0]   div_wr_addr_ex;
input        lsu_wr_vld_ex;
input[4:0]   lsu_wr_addr_ex;
input        lsu_wr_vld_ret;
input[4:0]   lsu_wr_addr_ret;


//The hazards cases I can think out (including but not limited):
//a. inter instructions with structure hazards
//b. inter instructions with data dependency
//c. inter instructions with control dependency
//d. sequential instructions with structure hazards
//e. sequential instructions with data dependency

///////////////////////
//DEAL WITH CASE A
///////////////////////
//The plan is to have 2 alus, but they are not equal
//alu0 acts as the main alu, which couple the data path
//with mul/div, branch and csr access.
//alu1 only has the alu functions
//Two many data paths are not necessary and take more
//area and power
//If instr0 is alu, and instr1 is mul. we can switch the
//two places, and notify which one is older
//This case will be similar with branch and div
wire instr1_cannot_iss = instr0_vld & instr1_vld &
	                 ((instr0_is_mul & instr1_is_mul) ||
		          (instr0_is_div & instr1_is_div) ||
		          (instr0_is_ls  & instr1_is_ls)  ||
			  (instr0_is_br  & instr1_is_br)  ||
			  (instr0_is_csr & instr1_is_csr) ||
			  (instr0_is_fp  & instr1_is_fp)  ||



endmodule
