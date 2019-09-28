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

module peak_dpu_dsp_ctl(
instr0_vld,
instr0_rd_r0_vld,
instr0_rd_r0_addr,
instr0_rd_r1_vld,
instr0_rd_r1_addr,
instr0_rd_r2_vld,
instr0_rd_r2_addr,
instr0_wr_vld,
instr0_wr_addr,
instr0_is_alu,
instr0_is_mul,
instr0_is_div,
instr0_is_ld,
instr0_is_jal,
instr0_is_ls,
instr0_is_br,
instr0_is_csr,
instr0_is_fp,
instr1_vld,
instr1_rd_r0_vld,
instr1_rd_r0_addr,
instr1_rd_r1_vld,
instr1_rd_r1_addr,
instr1_rd_r2_vld,
instr1_rd_r2_addr,
instr1_wr_vld,
instr1_wr_addr,
instr1_is_alu,
instr1_is_mul,
instr1_is_div,
instr1_is_ld,
instr1_is_jal,
instr1_is_ls,
instr1_is_br,
instr1_is_csr,
instr1_is_fp,
alu0_wr_vld_ex,
alu0_wr_addr_ex,
alu1_wr_vld_ex,
alu1_wr_addr_ex,
mul_wr_vld_ex,
mul_busy,
mul_wr_addr_ex,
div_wr_vld_ex,
div_busy,
div_wr_addr_ex,
lsu_wr_vld_ex,
lsu_wr_addr_ex,
lsu_wr_vld_ret,
lsu_wr_addr_ret,
csr_wr_vld_ex,
csr_wr_addr_ex,
fp_wr_vld,
fp_busy,
fp_wr_addr,
instr0_cannot_iss,
instr1_cannot_iss,
instr0_r0_fwd_sel,
instr0_r1_fwd_sel,
instr0_r2_fwd_sel,
instr1_r0_fwd_sel,
instr1_r1_fwd_sel,
instr1_r2_fwd_sel,
instr0_need_rd_eq0,
instr1_need_rd_eq0,

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
input        mul_busy;
input[4:0]   mul_wr_addr_ex;
input        div_wr_vld_ex;
input        div_busy;
input[4:0]   div_wr_addr_ex;
input        lsu_wr_vld_ex;
input[4:0]   lsu_wr_addr_ex;
input        lsu_wr_vld_ret;
input[4:0]   lsu_wr_addr_ret;
input        csr_wr_vld_ex;
input[4:0]   csr_wr_addr_ex;
input        fp_wr_vld;
input        fp_busy;
input[4:0]   fp_wr_addr;


output      instr0_cannot_iss;
output      instr1_cannot_iss;
output[6:0] instr0_r0_fwd_sel;
output[6:0] instr0_r1_fwd_sel;
output[6:0] instr0_r2_fwd_sel;
output[6:0] instr1_r0_fwd_sel;
output[6:0] instr1_r1_fwd_sel;
output[6:0] instr1_r2_fwd_sel;
output      instr0_need_rd_eq0;
output      instr1_need_rd_eq0;

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
wire instr0_need_rd_eq0 = ~instr0_rd_r0_vld & ~instr0_rd_r1_vld & ~instr0_rd_r2_vld; 
wire instr0_need_rd_eq1 = instr0_rd_r0_vld;

wire instr0_need_rd_eq2 = instr0_rd_r0_vld  & instr0_rd_r1_vld;

wire instr0_need_rd_eq3 = instr0_rd_r0_vld & instr0_rd_r1_vld & instr0_rd_r2_vld; 

wire instr1_need_rd_eq0 = ~instr1_rd_r0_vld & ~instr1_rd_r1_vld & ~instr1_rd_r2_vld; 
wire instr1_need_rd_eq1 = instr1_rd_r0_vld;

wire instr1_need_rd_eq2 = instr1_rd_r0_vld  & instr1_rd_r1_vld;

wire instr1_need_rd_eq3 = instr1_rd_r0_vld & instr1_rd_r1_vld & instr1_rd_r2_vld; 

     
wire instr1_cannot_iss_inter_struct_dep = instr0_vld & instr1_vld &
	                                 ((instr0_is_mul & instr1_is_mul) ||
		                          (instr0_is_div & instr1_is_div) ||
		                          (instr0_is_ls  & instr1_is_ls)  ||
			                  (instr0_is_br  & instr1_is_br)  ||
			                  (instr0_is_csr & instr1_is_csr) ||
			                  (instr0_is_fp  & instr1_is_fp)  ||
					  (instr0_need_rd_eq1 & instr1_need_rd_eq3) ||
					  (instr0_need_rd_eq2 & (instr1_need_rd_eq2 | instr1_need_rd_eq3)) ||
					  (instr0_need_rd_eq3 )) ;

////////////////////////
//DEAL WITH CASE B/E
///////////////////////
//1. data dependency between instr0 and instr1
//2. data dependency between instr{n} and div/mul ex busy instructions
//3. data dependency between instr{n} and ld ex stage
//4. data dependency between instr{n} and fp
wire instr0_cannot_iss_data_dep = instr0_vld &
	                          ((instr0_rd_r0_vld & (instr0_rd_r0_addr == mul_wr_addr_ex) & ~mul_wr_vld_ex & mul_busy) ||
			           (instr0_rd_r1_vld & (instr0_rd_r1_addr == mul_wr_addr_ex) & ~mul_wr_vld_ex & mul_busy) ||
	                           (instr0_rd_r0_vld & (instr0_rd_r0_addr == div_wr_addr_ex) & ~div_wr_vld_ex & div_busy) ||
			           (instr0_rd_r1_vld & (instr0_rd_r1_addr == div_wr_addr_ex) & ~div_wr_vld_ex & div_busy) ||
	                           (instr0_rd_r0_vld & (instr0_rd_r0_addr == lsu_wr_addr_ex) & lsu_wr_vld_ex) ||
	                           (instr0_rd_r1_vld & (instr0_rd_r1_addr == lsu_wr_addr_ex) & lsu_wr_vld_ex) 
			           //TODO: Will add FP related logic when complete fp
			           //plan
		                   );

wire instr1_cannot_iss_data_dep = instr1_vld &
	                          ((instr1_rd_r0_vld & (instr1_rd_r0_addr == mul_wr_addr_ex) & ~mul_wr_vld_ex & mul_busy) ||
			           (instr1_rd_r1_vld & (instr1_rd_r1_addr == mul_wr_addr_ex) & ~mul_wr_vld_ex & mul_busy) ||
	                           (instr1_rd_r0_vld & (instr1_rd_r0_addr == div_wr_addr_ex) & ~div_wr_vld_ex & div_busy) ||
			           (instr1_rd_r1_vld & (instr1_rd_r1_addr == div_wr_addr_ex) & ~div_wr_vld_ex & div_busy) ||
	                           (instr1_rd_r0_vld & (instr1_rd_r0_addr == lsu_wr_addr_ex) & lsu_wr_vld_ex) ||
	                           (instr1_rd_r1_vld & (instr1_rd_r1_addr == lsu_wr_addr_ex) & lsu_wr_vld_ex) ||
				   (instr0_vld & instr0_wr_vld & instr1_rd_r0_vld & (instr1_rd_r0_addr == instr0_wr_addr)) ||
				   (instr0_vld & instr0_wr_vld & instr1_rd_r1_vld & (instr1_rd_r1_addr == instr0_wr_addr)) 
			           //TODO: Will add FP related logic when complete fp
			           //plan
		                   );


////////////////////////
//DEAL WITH CASE C
///////////////////////
wire instr1_cannot_iss_ctl_dep = instr0_vld & instr0_is_br;


////////////////////////
//DEAL WITH CASE D
///////////////////////
wire instr0_cannot_iss_seq_struct_dep = instr0_vld &
	                                ((mul_busy & instr0_is_mul)     ||
					 (div_busy & instr0_is_div)     ||
					 (lsu_wr_vld_ex & instr0_is_ls) 
					 //TODO: will add FP related logic
					 //when complete FP plan
					 );

wire instr1_cannot_iss_seq_struct_dep = instr1_vld &
	                                ((mul_busy & instr1_is_mul)     ||
					 (div_busy & instr1_is_div)     ||
					 (lsu_wr_vld_ex & instr1_is_ls) 
					 //TODO: will add FP related logic
					 //when complete FP plan
					 );
					 

wire instr0_cannot_iss = instr0_cannot_iss_data_dep         ||
			 instr0_cannot_iss_seq_struct_dep   ;

wire instr1_cannot_iss = instr0_cannot_iss                  ||
	                 instr1_cannot_iss_inter_struct_dep ||
	                 instr1_cannot_iss_data_dep         ||
                         instr1_cannot_iss_ctl_dep          ||
			 instr1_cannot_iss_seq_struct_dep   ;


//[0]: alu0
//[1]: alu1
//[2]: mul
//[3]: div
//[4]: ld
//[5]: csr
//[6]: fp
wire[6:0] instr0_r0_fwd_sel;

assign instr0_r0_fwd_sel[0] = instr0_vld &
		    	      (instr0_rd_r0_vld & (instr0_rd_r0_addr == alu0_wr_addr_ex) & alu0_wr_vld_ex);
assign instr0_r0_fwd_sel[1] = instr0_vld &
			      (instr0_rd_r0_vld & (instr0_rd_r0_addr == alu1_wr_addr_ex) & alu1_wr_vld_ex);
assign instr0_r0_fwd_sel[2] = instr0_vld &
			      (instr0_rd_r0_vld & (instr0_rd_r0_addr == mul_wr_addr_ex) & mul_wr_vld_ex & ~mul_busy);
assign instr0_r0_fwd_sel[3] = instr0_vld &
			      (instr0_rd_r0_vld & (instr0_rd_r0_addr == div_wr_addr_ex) & div_wr_vld_ex & ~div_busy);
assign instr0_r0_fwd_sel[4] = instr0_vld &
			      (instr0_rd_r0_vld & (instr0_rd_r0_addr == ls_wr_addr_ret) & ls_wr_vld_ret);
assign instr0_r0_fwd_sel[5] = instr0_vld &
			      (instr0_rd_r0_vld & (instr0_rd_r0_addr == csr_wr_addr_ex) & csr_wr_vld_ex);
assign instr0_r0_fwd_sel[6] = instr0_vld &
			      (instr0_rd_r0_vld & (instr0_rd_r0_addr == fp_wr_addr) & fp_wr_vld);

wire[6:0] instr0_r1_fwd_sel;

assign instr0_r1_fwd_sel[0] = instr0_vld &
		    	      (instr0_rd_r1_vld & (instr0_rd_r1_addr == alu0_wr_addr_ex) & alu0_wr_vld_ex);
assign instr0_r1_fwd_sel[1] = instr0_vld &
			      (instr0_rd_r1_vld & (instr0_rd_r1_addr == alu1_wr_addr_ex) & alu1_wr_vld_ex);
assign instr0_r1_fwd_sel[2] = instr0_vld &
			      (instr0_rd_r1_vld & (instr0_rd_r1_addr == mul_wr_addr_ex) & mul_wr_vld_ex & ~mul_busy);
assign instr0_r1_fwd_sel[3] = instr0_vld &
			      (instr0_rd_r1_vld & (instr0_rd_r1_addr == div_wr_addr_ex) & div_wr_vld_ex & ~div_busy);
assign instr0_r1_fwd_sel[4] = instr0_vld &
			      (instr0_rd_r1_vld & (instr0_rd_r1_addr == ls_wr_addr_ret) & ls_wr_vld_ret);
assign instr0_r1_fwd_sel[5] = instr0_vld &
			      (instr0_rd_r1_vld & (instr0_rd_r1_addr == csr_wr_addr_ex) & csr_wr_vld_ex);
assign instr0_r1_fwd_sel[6] = instr0_vld &
			      (instr0_rd_r1_vld & (instr0_rd_r1_addr == fp_wr_addr) & fp_wr_vld);

wire[6:0] instr0_r2_fwd_sel;

assign instr0_r2_fwd_sel[0] = instr0_vld &
		    	      (instr0_rd_r2_vld & (instr0_rd_r2_addr == alu0_wr_addr_ex) & alu0_wr_vld_ex);
assign instr0_r2_fwd_sel[1] = instr0_vld &
			      (instr0_rd_r2_vld & (instr0_rd_r2_addr == alu1_wr_addr_ex) & alu1_wr_vld_ex);
assign instr0_r2_fwd_sel[2] = instr0_vld &
			      (instr0_rd_r2_vld & (instr0_rd_r2_addr == mul_wr_addr_ex) & mul_wr_vld_ex & ~mul_busy);
assign instr0_r2_fwd_sel[3] = instr0_vld &
			      (instr0_rd_r2_vld & (instr0_rd_r2_addr == div_wr_addr_ex) & div_wr_vld_ex & ~div_busy);
assign instr0_r2_fwd_sel[4] = instr0_vld &
			      (instr0_rd_r2_vld & (instr0_rd_r2_addr == ls_wr_addr_ret) & ls_wr_vld_ret);
assign instr0_r2_fwd_sel[5] = instr0_vld &
			      (instr0_rd_r2_vld & (instr0_rd_r2_addr == csr_wr_addr_ex) & csr_wr_vld_ex);
assign instr0_r2_fwd_sel[6] = instr0_vld &
			      (instr0_rd_r2_vld & (instr0_rd_r2_addr == fp_wr_addr) & fp_wr_vld);


wire[6:0] instr1_r0_fwd_sel;

assign instr1_r0_fwd_sel[0] = instr1_vld &
		    	      (instr1_rd_r0_vld & (instr1_rd_r0_addr == alu0_wr_addr_ex) & alu0_wr_vld_ex);
assign instr1_r0_fwd_sel[1] = instr1_vld &
			      (instr1_rd_r0_vld & (instr1_rd_r0_addr == alu1_wr_addr_ex) & alu1_wr_vld_ex);
assign instr1_r0_fwd_sel[2] = instr1_vld &
			      (instr1_rd_r0_vld & (instr1_rd_r0_addr == mul_wr_addr_ex) & mul_wr_vld_ex & ~mul_busy);
assign instr1_r0_fwd_sel[3] = instr1_vld &
			      (instr1_rd_r0_vld & (instr1_rd_r0_addr == div_wr_addr_ex) & div_wr_vld_ex & ~div_busy);
assign instr1_r0_fwd_sel[4] = instr1_vld &
			      (instr1_rd_r0_vld & (instr1_rd_r0_addr == ls_wr_addr_ret) & ls_wr_vld_ret);
assign instr1_r0_fwd_sel[5] = instr1_vld &
			      (instr1_rd_r0_vld & (instr1_rd_r0_addr == csr_wr_addr_ex) & csr_wr_vld_ex);
assign instr1_r0_fwd_sel[6] = instr1_vld &
			      (instr1_rd_r0_vld & (instr1_rd_r0_addr == fp_wr_addr) & fp_wr_vld);

wire[6:0] instr1_r1_fwd_sel;

assign instr1_r1_fwd_sel[0] = instr1_vld &
		    	      (instr1_rd_r1_vld & (instr1_rd_r1_addr == alu0_wr_addr_ex) & alu0_wr_vld_ex);
assign instr1_r1_fwd_sel[1] = instr1_vld &
			      (instr1_rd_r1_vld & (instr1_rd_r1_addr == alu1_wr_addr_ex) & alu1_wr_vld_ex);
assign instr1_r1_fwd_sel[2] = instr1_vld &
			      (instr1_rd_r1_vld & (instr1_rd_r1_addr == mul_wr_addr_ex) & mul_wr_vld_ex & ~mul_busy);
assign instr1_r1_fwd_sel[3] = instr1_vld &
			      (instr1_rd_r1_vld & (instr1_rd_r1_addr == div_wr_addr_ex) & div_wr_vld_ex & ~div_busy);
assign instr1_r1_fwd_sel[4] = instr1_vld &
			      (instr1_rd_r1_vld & (instr1_rd_r1_addr == ls_wr_addr_ret) & ls_wr_vld_ret);
assign instr1_r1_fwd_sel[5] = instr1_vld &
			      (instr1_rd_r1_vld & (instr1_rd_r1_addr == csr_wr_addr_ex) & csr_wr_vld_ex);
assign instr1_r1_fwd_sel[6] = instr1_vld &
			      (instr1_rd_r1_vld & (instr1_rd_r1_addr == fp_wr_addr) & fp_wr_vld);

wire[6:0] instr2_r2_fwd_sel;

assign instr2_r2_fwd_sel[0] = instr2_vld &
		    	      (instr2_rd_r2_vld & (instr2_rd_r2_addr == alu0_wr_addr_ex) & alu0_wr_vld_ex);
assign instr2_r2_fwd_sel[1] = instr2_vld &
			      (instr2_rd_r2_vld & (instr2_rd_r2_addr == alu1_wr_addr_ex) & alu1_wr_vld_ex);
assign instr2_r2_fwd_sel[2] = instr2_vld &
			      (instr2_rd_r2_vld & (instr2_rd_r2_addr == mul_wr_addr_ex) & mul_wr_vld_ex & ~mul_busy);
assign instr2_r2_fwd_sel[3] = instr2_vld &
			      (instr2_rd_r2_vld & (instr2_rd_r2_addr == div_wr_addr_ex) & div_wr_vld_ex & ~div_busy);
assign instr2_r2_fwd_sel[4] = instr2_vld &
			      (instr2_rd_r2_vld & (instr2_rd_r2_addr == ls_wr_addr_ret) & ls_wr_vld_ret);
assign instr2_r2_fwd_sel[5] = instr2_vld &
			      (instr2_rd_r2_vld & (instr2_rd_r2_addr == csr_wr_addr_ex) & csr_wr_vld_ex);
assign instr2_r2_fwd_sel[6] = instr2_vld &
			      (instr2_rd_r2_vld & (instr2_rd_r2_addr == fp_wr_addr) & fp_wr_vld);

endmodule
