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
input[31:0]  instr_op;

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

output[2:0]  instr_ls_op;


reg[2:0] instr_ls_op;
always @ (*) begin
	casez({instr_op[14:12], instr_op[6:0]})
	    32'b????_????_????_????_?000_????_?000_0011: instr_ls_op = LB;
	    32'b????_????_????_????_?001_????_?000_0011: instr_ls_op = LH;
	    32'b????_????_????_????_?010_????_?000_0011: instr_ls_op = LW;
	    32'b????_????_????_????_?100_????_?000_0011: instr_ls_op = LBU;
	    32'b????_????_????_????_?101_????_?000_0011: instr_ls_op = LHU;
	    32'b????_????_????_????_?000_????_?010_0011: instr_ls_op = SB;
	    32'b????_????_????_????_?001_????_?010_0011: instr_ls_op = SH;
	    32'b????_????_????_????_?010_????_?010_0011: instr_ls_op = SW;
	    32'b????_????_????_????_010?_????_????_??00: instr_ls_op = LW;
	    32'b????_????_????_????_110?_????_????_??00: instr_ls_op = SW;
	    32'b????_????_????_????_010?_????_????_??10: instr_ls_op = LW;
	    32'b????_????_????_????_110?_????_????_??10: instr_ls_op = SW;
	default:
		instr_ls_op = 3'h0;
	endcase
end


reg instr_rd_r0_vld;
always @ (*) begin
    casez(instr_op) 
	default:
    	    instr_rd_r0_vld = 1'b0;
    endcase
end

reg[4:0] instr_rd_r0_addr;
always @ (*) begin
    casez(instr_op) 
        default:
    	    instr_rd_r0_addr = instr_op[19:15];
    endcase
end


reg instr_rd_r1_vld;
always @ (*) begin
    casez(instr_op) 
        default:
    	    instr_rd_r1_vld = 1'b0;
    endcase
end

reg[4:0] instr_rd_r1_addr;
always @ (*) begin
    casez(instr_op) 
        default:
    	    instr_rd_r1_addr = instr_op[24:20];
    endcase
end



//currently we just support standard extension
//so no need to 3rd source
//just tie this signal to zeros
//If we want to add custom instructions, we
//may want to utilize them
assign instr_rd_r2_vld  = 1'b0;
assign instr_rd_r2_addr = 5'h0;

assign instr_wr_vld  = (instr_br_op == JAL) ||
	               (instr_br_op == JALR);

assign instr_wr_addr = instr_op[11:7]; 

reg instr_use_imm;
always @ (*) begin
    casez(instr_op)
        default:
    	    instr_use_imm = 1'b1;
    endcase
end

reg[31:0] instr_imm;
always @ (*) begin
    casez(instr_op)
        default:
    	    instr_imm = {{19{instr_op[12]}}, instr_op[31], instr_op[7], instr_op[30:25], instr_op[11:8], 1'b0};
    endcase
end


endmodule
