////////////////////////////////////////////////////////////
// File Description: This file is main decoder
// It can decode compressed and non-compressed
// instructions
// In this file, it can decode ld/st instructions 
// Date:   2019.09.18
///////////////////////////////////////////////////////////

module peak_dpu_de_ls
(
instr_is_compressed,
instr_vld,
instr_op,

instr_rd_r0_vld,
instr_rd_r0_addr,

instr_rd_r1_vld,
instr_rd_r1_addr,

instr_rd_r2_vld,
instr_rd_r2_addr,

instr_wr_vld,
instr_wr_addr,

instr_imm,
instr_use_imm,

instr_is_ld,
instr_is_ls,

instr_ls_op

);

//alu op encoding
localparam   LB  = 3'h0;
localparam   LH  = 3'h1;
localparam   LW  = 3'h2;
localparam   LBU = 3'h3;
localparam   LHU = 3'h4;
localparam   SB  = 3'h5;
localparam   SH  = 3'h6;
localparam   SW  = 3'h7;

input        instr_is_compressed;
input        instr_vld;
input[15:0]  instr_op;

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

output       instr_is_ld;
output       instr_is_ls;

output[2:0]  instr_ls_op;


reg[2:0] instr_ls_op;
always @ (*) begin
	casez(instr_op[15:0])
	    16'b010?_????_????_??00: instr_ls_op = LW;  //c.lw
	    16'b110?_????_????_??00: instr_ls_op = SW;  //c.sw
	    16'b010?_????_????_??10: instr_ls_op = LW;  //c.lwsp
	    16'b110?_????_????_??10: instr_ls_op = SW;  //c.swsp
	default:
		instr_ls_op = 3'h0;
	endcase
end

reg instr_is_ld;
always @ (*) begin
	casez(instr_op[15:0])
	    16'b010?_????_????_??00: instr_ls_ld = 1'b1;  //c.lw
	    16'b010?_????_????_??10: instr_ls_ld = 1'b1;  //c.lwsp
	default:
		instr_is_ld = 1'b0;
	endcase
end

reg instr_is_ls;
always @ (*) begin
	casez(instr_op[15:0])
	    16'b010?_????_????_??00: instr_ls_ls = 1'b1;  //c.lw
	    16'b110?_????_????_??00: instr_ls_ls = 1'b1;  //c.sw
	    16'b010?_????_????_??10: instr_ls_ls = 1'b1;  //c.lwsp
	    16'b110?_????_????_??10: instr_ls_ls = 1'b1;  //c.swsp
	default:
		instr_is_ls = 1'b1;
	endcase
end

assign  instr_rd_r1_vld = 1'b1;
assign  instr_rd_r0_addr =  ((instr_op[1:0] == 2'b10) ? 5'h2: instr_op[9;7]) ;
                                            	  

reg instr_rd_r1_vld;
always @ (*) begin
    casez(instr_op[15:0]) 
	    16'b110?_????_????_??00: instr_rd_r1_vld = 1'b1;  //c.sw
	    16'b110?_????_????_??10: instr_rd_r1_vld = 1'b1;  //c.swsp
        default:
    	    instr_rd_r1_vld = 1'b0;
    endcase
end

reg[4:0] instr_rd_r1_addr = ((instr_op[1:0] == 2'b10) ? instr_op[6:2] : instr_op[4:2]) ;

//currently we just support standard extension
//so no need to 3rd source
//just tie this signal to zeros
//If we want to add custom instructions, we
//may want to utilize them
assign instr_rd_r2_vld  = 1'b0;
assign instr_rd_r2_addr = 5'h0;

assign instr_wr_vld  = (instr_ls_op == LB)  ||
	               (instr_ls_op == LH)  ||
	               (instr_ls_op == LW)  ||
	               (instr_ls_op == LBU) ||
	               (instr_ls_op == LHU) ;

assign instr_wr_addr = instr_op[11:7]; 

assign instr_use_imm = 1'b1;


reg[31:0] instr_imm;
always @ (*) begin
    casez(instr_op)
	    16'b010?_????_????_??00: instr_imm = {{27{1'b0}}, instr_op[5], instr_op[12:10], instr_op[6], 2'h0};  //c.lw
	    16'b110?_????_????_??00: instr_imm = {{27{1'b0}}, instr_op[5], instr_op[12:10], instr_op[6], 2'h0;  //c.sw
	    16'b010?_????_????_??10: instr_imm = {{24{1'b0}, instr_op[3:2], instr_op[12], instr_op[6:4], 2'h0}};  //c.lwsp
	    16'b110?_????_????_??10: instr_imm = {{24{1'b0}, instr_op[8:7], instr_op[12:9], 2'h0};  //c.swsp
        default:
    	    instr_imm = 32'h0;
    endcase
end


endmodule
