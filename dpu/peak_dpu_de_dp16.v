////////////////////////////////////////////////////////////
// File Description: This file is main decoder
// It can decode compressed and non-compressed
// instructions
// In this file, it can decode dp instructions 
// Date:   2019.09.18
///////////////////////////////////////////////////////////

module peak_dpu_de_dp
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

instr_is_alu,
instr_is_mul,
instr_is_div,

instr_alu_op,
instr_mul_op,
instr_div_op

);

//alu op encoding
localparam   ADD = 4'h0;
localparam   SUB = 4'h1;
localparam   XOR = 4'h2;
localparam   OR  = 4'h3;
localparam   AND = 4'h4;
localparam   SLL = 4'h5;
localparam   SRL = 4'h6;
localparam   SRA = 4'h7;
localparam   SLT = 4'h8;
localparam   NOP = 4'h9;

//mul op encoding
localparam   MUL     = 2'h0;
localparam   MULH    = 2'h1;
localparam   MULHSU  = 2'h2;
localparam   MULHU   = 2'h3;

//div op encoding
localparam   DIV     = 2'h0;
localparam   DIVU    = 2'h1;
localparam   REM     = 2'h2;
localparam   REMU    = 2'h3;


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

output       instr_is_alu;
output       instr_is_mul;
output       instr_is_div;

output[3:0]  instr_alu_op;
output[1:0]  instr_mul_op;
output[1:0]  instr_div_op;

reg instr_is_alu;
always @ (*) begin
    casez(instr_op)
        16'b000?_????_????_??00: instr_is_alu = 1'b1;//c.addi4spn
        16'b000?_0000_0???_??01: instr_is_alu = 1'b1;//c.nop
        16'b000?_????_????_??01: instr_is_alu = 1'b1;//c.addi
        16'b010?_????_????_??01: instr_is_alu = 1'b1;//c.li
        16'b011?_???1_0???_??01: instr_is_alu = 1'b1;//c.addi16sp
        16'b011?_????_????_??01: instr_is_alu = 1'b1;//c.lui
        16'b100?_00??_????_??01: instr_is_alu = 1'b1;//c.srli
        16'b1000_01??_????_??01: instr_is_alu = 1'b1;//c.srai
        16'b1000_10??_????_??01: instr_is_alu = 1'b1;//c.andi
        16'b1000_11??_?00?_??01: instr_is_alu = 1'b1;//c.sub
        16'b1000_11??_?01?_??01: instr_is_alu = 1'b1;//c.xor
        16'b1000_11??_?10?_??01: instr_is_alu = 1'b1;//c.or
        16'b1000_11??_?11?_??01: instr_is_alu = 1'b1;//c.and
        16'b000?_????_????_??10: instr_is_alu = 1'b1;//c.slli
        16'b1000_????_????_??10: instr_is_alu = 1'b1;//c.mv
        16'b1001_????_????_??10: instr_is_alu = 1'b1;//c.add
        default:
    	    instr_is_alu = 1'b0;
    endcase
end

reg[3:0] instr_alu_op;
always @ (*) begin
    casez(instr_op)
        16'b100?_00??_????_??01: instr_alu_op = SRL;//c.srli
        16'b1000_01??_????_??01: instr_alu_op = SRA;//c.srai
        16'b1000_10??_????_??01: instr_alu_op = AND;//c.andi
        16'b1000_11??_?00?_??01: instr_alu_op = SUB;//c.sub
        16'b1000_11??_?01?_??01: instr_alu_op = XOR;//c.xor
        16'b1000_11??_?10?_??01: instr_alu_op = OR;//c.or
        16'b1000_11??_?11?_??01: instr_alu_op = AND;//c.and
        16'b000?_????_????_??10: instr_alu_op = SLL;//c.slli
        16'b000?_0000_0???_??01: instr_alu_op = NOP;//c.nop
        default:
    	    instr_alu_op = ADD;
    endcase
end



assign instr_is_mul = 1'b0;

assign instr_mul_op = 2'h0;

assign instr_is_div = 1'b0;

assign instr_div_op = 2'h0;

reg instr_rd_r0_vld;
always @ (*) begin
    casez(instr_op) 
        16'b000?_????_????_??00: instr_rd_r0_vld = 1'b1;//c.addi4spn
        16'b000?_????_????_??01: instr_rd_r0_vld = 1'b1;//c.addi
        16'b010?_????_????_??01: instr_rd_r0_vld = 1'b1;//c.li
        16'b011?_???1_0???_??01: instr_rd_r0_vld = 1'b1;//c.addi16sp
        16'b011?_????_????_??01: instr_rd_r0_vld = 1'b1;//c.lui
        16'b100?_00??_????_??01: instr_rd_r0_vld = 1'b1;//c.srli
        16'b1000_01??_????_??01: instr_rd_r0_vld = 1'b1;//c.srai
        16'b1000_10??_????_??01: instr_rd_r0_vld = 1'b1;//c.andi
        16'b1000_11??_?00?_??01: instr_rd_r0_vld = 1'b1;//c.sub
        16'b1000_11??_?01?_??01: instr_rd_r0_vld = 1'b1;//c.xor
        16'b1000_11??_?10?_??01: instr_rd_r0_vld = 1'b1;//c.or
        16'b1000_11??_?11?_??01: instr_rd_r0_vld = 1'b1;//c.and
        16'b000?_????_????_??10: instr_rd_r0_vld = 1'b1;//c.slli
        16'b1000_????_????_??10: instr_rd_r0_vld = 1'b1;//c.mv
        16'b1001_????_????_??10: instr_rd_r0_vld = 1'b1;//c.add
        default:
    	    instr_rd_r0_vld = 1'b0;
    endcase
end

reg instr_rd_r0_addr;
always @ (*) begin
    casez(instr_op) 
        16'b000?_????_????_??00: instr_rd_r0_addr = instr_op[11:7];//c.addi4spn
        16'b000?_????_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.addi
        16'b010?_????_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.li
        16'b011?_???1_0???_??01: instr_rd_r0_addr = instr_op[11:7];//c.addi16sp
        16'b011?_????_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.lui
        16'b100?_00??_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.srli
        16'b1000_01??_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.srai
        16'b1000_10??_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.andi
        16'b1000_11??_?00?_??01: instr_rd_r0_addr = instr_op[11:7];//c.sub
        16'b1000_11??_?01?_??01: instr_rd_r0_addr = instr_op[11:7];//c.xor
        16'b1000_11??_?10?_??01: instr_rd_r0_addr = instr_op[11:7];//c.or
        16'b1000_11??_?11?_??01: instr_rd_r0_addr = instr_op[11:7];//c.and
        16'b000?_????_????_??10: instr_rd_r0_addr = instr_op[11:7];//c.slli
        16'b1000_????_????_??10: instr_rd_r0_addr = 5'h0;//c.mv
        16'b1001_????_????_??10: instr_rd_r0_addr = instr_op[11:7];//c.add
        default:
    	    instr_rd_r0_addr = 5'h0;
    endcase
end


reg instr_rd_r1_vld;
always @ (*) begin
    casez(instr_op) 
        16'b1000_11??_?00?_??01: instr_rd_r1_vld = 1'b1;//c.sub
        16'b1000_11??_?01?_??01: instr_rd_r1_vld = 1'b1;//c.xor
        16'b1000_11??_?10?_??01: instr_rd_r1_vld = 1'b1;//c.or
        16'b1000_11??_?11?_??01: instr_rd_r1_vld = 1'b1;//c.and
        16'b1000_????_????_??10: instr_rd_r1_vld = 1'b1;//c.mv
        16'b1001_????_????_??10: instr_rd_r1_vld = 1'b1;//c.add
        default:
    	    instr_rd_r1_vld = 1'b0;
    endcase
end

assign instr_rd_r1_addr = instr_op[6:2];


//currently we just support standard extension
//so no need to 3rd source
//just tie this signal to zeros
//If we want to add custom instructions, we
//may want to utilize them
assign instr_rd_r2_vld  = 1'b0;
assign instr_rd_r2_addr = 5'h0;

assign instr_wr_vld = instr_is_alu |
	              instr_is_mul |
		      instr_is_div ;

assign instr_wr_addr = instr_op[11:7]; 

reg instr_use_imm;
always @ (*) begin
    casez(instr_op)
        16'b000?_????_????_??00: instr_use_imm = 1'b1;//c.addi4spn
        16'b000?_????_????_??01: instr_use_imm = 1'b1;//c.addi
        16'b010?_????_????_??01: instr_use_imm = 1'b1;//c.li
        16'b011?_???1_0???_??01: instr_use_imm = 1'b1;//c.addi16sp
        16'b011?_????_????_??01: instr_use_imm = 1'b1;//c.lui
        16'b100?_00??_????_??01: instr_use_imm = 1'b1;//c.srli
        16'b1000_01??_????_??01: instr_use_imm = 1'b1;//c.srai
        16'b1000_10??_????_??01: instr_use_imm = 1'b1;//c.andi
        16'b000?_????_????_??10: instr_use_imm = 1'b1;//c.slli
        default:
    	    instr_use_imm = 1'b0;
    endcase
end

reg[31:0] instr_imm;
always @ (*) begin
    casez(instr_op)
        32'b????_????_????_????_000?_????_????_??00: instr_imm = {24'h0, instr_op[10:7], instr_op[12:11], instr_op[5], instr_op[6]};//c.addi4spn
        32'b????_????_????_????_000?_????_????_??01: instr_imm = {{26{instr_op[12]}}, instr_op[12], instr_op[6:2]};//c.addi
        32'b????_????_????_????_010?_????_????_??01: instr_imm = {{26{instr_op[12]}}, instr_op[12], instr_op[6:2];//c.li
        32'b????_????_????_????_011?_???1_0???_??01: instr_imm = {{26{instr_op[12]}}, instr_op[12], instr_op[4:3], instr_op[5], instr_op[2], instr_op[6]};//c.addi16sp
        32'b????_????_????_????_011?_????_????_??01: instr_imm = {{14{instr_op[12]}}, instr_op[12], instr_op[6:2], 12'h0};//c.lui
        32'b????_????_????_????_100?_00??_????_??01: instr_imm = {26'h0, instr_op[12], instr_op[6:2]};//c.srli
        32'b????_????_????_????_1000_01??_????_??01: instr_imm = {26'h0, instr_op[12], instr_op[6:2]};//c.srai
        32'b????_????_????_????_1000_10??_????_??01: instr_imm = {26'h0, instr_op[12], instr_op[6:2]};//c.andi
        32'b????_????_????_????_000?_????_????_??10: instr_imm = {26'h0, instr_op[12], instr_op[6:2]};//c.slli
        default:
    	    instr_imm = 32'h0;
    endcase
end


endmodule
