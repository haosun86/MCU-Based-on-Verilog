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


output       instr_rd_r0_vld;
output[4:0]  instr_rd_r0_addr;
output       instr_rd_r1_vld;
output[4:0]  instr_rd_r1_addr;
output       instr_rd_r2_vld;
output[4:0]  instr_rd_r2_addr;
output       instr_wr_vld;
output[4:0]  instr_wr_addr;
output[31:0] instr_imm;
output       instr_use_imm;

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




endmodule
