////////////////////////////////////////////////////////////
// File Description: This file is main decoder
// It can decode compressed and non-compressed
// instructions
// In this file, it can decode dp instructions 
// Date:   2019.09.18
///////////////////////////////////////////////////////////

module peak_dpu_de_dp
(

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

output       instr_is_alu;
output       instr_is_mul;
output       instr_is_div;

output[3:0]  instr_alu_op;
output[1:0]  instr_mul_op;
output[1:0]  instr_div_op;

reg instr_is_alu;
casez(instr_op)
    32'b????_????_????_????_????_????_?011_0111: instr_is_alu = 1'b1;//lui
    32'b????_????_????_????_????_????_?001_0111: instr_is_alu = 1'b1;//auipc
    32'b????_????_????_????_?000_????_?001_0011: instr_is_alu = 1'b1;//addi
    32'b????_????_????_????_?010_????_?001_0011: instr_is_alu = 1'b1;//slti
    32'b????_????_????_????_?011_????_?001_0011: instr_is_alu = 1'b1;//sltiu
    32'b????_????_????_????_?100_????_?001_0011: instr_is_alu = 1'b1;//xori
    32'b????_????_????_????_?110_????_?001_0011: instr_is_alu = 1'b1;//ori
    32'b????_????_????_????_?111_????_?001_0011: instr_is_alu = 1'b1;//andi
    32'b0000_000?_????_????_?001_????_?001_0011: instr_is_alu = 1'b1;//slli
    32'b0000_000?_????_????_?101_????_?001_0011: instr_is_alu = 1'b1;//srli
    32'b0100_000?_????_????_?101_????_?001_0011: instr_is_alu = 1'b1;//srai
    32'b0000_000?_????_????_?000_????_?011_0011: instr_is_alu = 1'b1;//add
    32'b0100_000?_????_????_?000_????_?011_0011: instr_is_alu = 1'b1;//sub
    32'b0000_000?_????_????_?001_????_?011_0011: instr_is_alu = 1'b1;//sll
    32'b0000_000?_????_????_?010_????_?011_0011: instr_is_alu = 1'b1;//slt
    32'b0000_000?_????_????_?011_????_?011_0011: instr_is_alu = 1'b1;//sltu
    32'b0000_000?_????_????_?100_????_?011_0011: instr_is_alu = 1'b1;//xor
    32'b0000_000?_????_????_?101_????_?011_0011: instr_is_alu = 1'b1;//srl
    32'b0100_000?_????_????_?101_????_?011_0011: instr_is_alu = 1'b1;//sra
    32'b0000_000?_????_????_?110_????_?011_0011: instr_is_alu = 1'b1;//or
    32'b0000_000?_????_????_?111_????_?011_0011: instr_is_alu = 1'b1;//and
    32'b0000_0000_0000_0000_000?_????_????_??00: instr_is_alu = 1'b1;//c.addi4spn
    32'b0000_0000_0000_0000_000?_0000_0???_??01: instr_is_alu = 1'b1;//c.nop
    32'b0000_0000_0000_0000_000?_????_????_??01: instr_is_alu = 1'b1;//c.addi
    32'b0000_0000_0000_0000_010?_????_????_??01: instr_is_alu = 1'b1;//c.li
    32'b0000_0000_0000_0000_011?_???1_0???_??01: instr_is_alu = 1'b1;//c.addi16sp
    32'b0000_0000_0000_0000_011?_????_????_??01: instr_is_alu = 1'b1;//c.lui
    32'b0000_0000_0000_0000_100?_00??_????_??01: instr_is_alu = 1'b1;//c.srli
    32'b0000_0000_0000_0000_1000_01??_????_??01: instr_is_alu = 1'b1;//c.srai
    32'b0000_0000_0000_0000_1000_10??_????_??01: instr_is_alu = 1'b1;//c.andi
    32'b0000_0000_0000_0000_1000_11??_?00?_??01: instr_is_alu = 1'b1;//c.sub
    32'b0000_0000_0000_0000_1000_11??_?01?_??01: instr_is_alu = 1'b1;//c.xor
    32'b0000_0000_0000_0000_1000_11??_?10?_??01: instr_is_alu = 1'b1;//c.or
    32'b0000_0000_0000_0000_1000_11??_?11?_??01: instr_is_alu = 1'b1;//c.and
    32'b0000_0000_0000_0000_000?_????_????_??10: instr_is_alu = 1'b1;//c.slli
    32'b0000_0000_0000_0000_1000_????_????_??10: instr_is_alu = 1'b1;//c.mv
    32'b0000_0000_0000_0000_1001_????_????_??10: instr_is_alu = 1'b1;//c.add
    default:
	    instr_is_alu = 1'b0;
endcase

reg[3:0] instr_alu_op;
casez(instr_op)
    32'b????_????_????_????_?010_????_?001_0011: instr_alu_op = SLT;//slti
    32'b????_????_????_????_?011_????_?001_0011: instr_alu_op = SLT;//sltiu
    32'b????_????_????_????_?100_????_?001_0011: instr_alu_op = XOR;//xori
    32'b????_????_????_????_?110_????_?001_0011: instr_alu_op = OR;//ori
    32'b????_????_????_????_?111_????_?001_0011: instr_alu_op = AND;//andi
    32'b0000_000?_????_????_?001_????_?001_0011: instr_alu_op = SLL;//slli
    32'b0000_000?_????_????_?101_????_?001_0011: instr_alu_op = SRL;//srli
    32'b0100_000?_????_????_?101_????_?001_0011: instr_alu_op = SRA;//srai
    32'b0100_000?_????_????_?000_????_?011_0011: instr_alu_op = SUB;//sub
    32'b0000_000?_????_????_?001_????_?011_0011: instr_alu_op = SLL;//sll
    32'b0000_000?_????_????_?010_????_?011_0011: instr_alu_op = SLT;//slt
    32'b0000_000?_????_????_?011_????_?011_0011: instr_alu_op = SLT;//sltu
    32'b0000_000?_????_????_?100_????_?011_0011: instr_alu_op = XOR;//xor
    32'b0000_000?_????_????_?101_????_?011_0011: instr_alu_op = SRL;//srl
    32'b0100_000?_????_????_?101_????_?011_0011: instr_alu_op = SRA;//sra
    32'b0000_000?_????_????_?110_????_?011_0011: instr_alu_op = OR;//or
    32'b0000_000?_????_????_?111_????_?011_0011: instr_alu_op = AND;//and
    32'b0000_0000_0000_0000_100?_00??_????_??01: instr_alu_op = SRL;//c.srli
    32'b0000_0000_0000_0000_1000_01??_????_??01: instr_alu_op = SRA;//c.srai
    32'b0000_0000_0000_0000_1000_10??_????_??01: instr_alu_op = AND;//c.andi
    32'b0000_0000_0000_0000_1000_11??_?00?_??01: instr_alu_op = SUB;//c.sub
    32'b0000_0000_0000_0000_1000_11??_?01?_??01: instr_alu_op = XOR;//c.xor
    32'b0000_0000_0000_0000_1000_11??_?10?_??01: instr_alu_op = OR;//c.or
    32'b0000_0000_0000_0000_1000_11??_?11?_??01: instr_alu_op = AND;//c.and
    32'b0000_0000_0000_0000_000?_????_????_??10: instr_alu_op = SLL;//c.slli
    32'b0000_0000_0000_0000_000?_0000_0???_??01: instr_alu_op = NOP;//c.nop
    default:
	    instr_alu_op = ADD;
endcase



reg instr_is_mul;
casez(instr_op)
    32'b0000_001?_????_????_?000_????_?011_0011: instr_is_mul = 1'b1;//mul
    32'b0000_001?_????_????_?001_????_?011_0011: instr_is_mul = 1'b1;//mulh
    32'b0000_001?_????_????_?010_????_?011_0011: instr_is_mul = 1'b1;//mulhsu
    32'b0000_001?_????_????_?011_????_?011_0011: instr_is_mul = 1'b1;//mulhu
    default:
	    instr_is_mul = 1'b0;
endcase

reg[1:0] instr_mul_op;
casez(instr_op)
    32'b0000_001?_????_????_?000_????_?011_0011: instr_mul_op = MUL;//mul
    32'b0000_001?_????_????_?001_????_?011_0011: instr_mul_op = MULH;//mulh
    32'b0000_001?_????_????_?010_????_?011_0011: instr_mul_op = MULHSU;//mulhsu
    32'b0000_001?_????_????_?011_????_?011_0011: instr_mul_op = MULHU;//mulhu
    default:
	    instr_mul_op = 2'h0;
endcase

reg instr_is_div;
casez(instr_op)
    32'b0000_001?_????_????_?100_????_?011_0011: instr_is_div = 1'b1;//div
    32'b0000_001?_????_????_?101_????_?011_0011: instr_is_div = 1'b1;//divu
    32'b0000_001?_????_????_?110_????_?011_0011: instr_is_div = 1'b1;//rem
    32'b0000_001?_????_????_?111_????_?011_0011: instr_is_div = 1'b1;//remu
    default:
	    instr_is_div = 1'b0;
endcase

reg[1:0]
casez(instr_op)
    32'b0000_001?_????_????_?100_????_?011_0011: instr_div_op = DIV;//div
    32'b0000_001?_????_????_?101_????_?011_0011: instr_div_op = DIVU;//divu
    32'b0000_001?_????_????_?110_????_?011_0011: instr_div_op = REM;//rem
    32'b0000_001?_????_????_?111_????_?011_0011: instr_div_op = REMU;//remu
    default:
	    instr_div_op = 2'h0;
endcase


reg instr_rd_r0_vld;
casez(instr_op) 
    32'b????_????_????_????_????_????_?011_0111: instr_rd_r0_vld = 1'b1;//lui
    32'b????_????_????_????_????_????_?001_0111: instr_rd_r0_vld = 1'b1;//auipc
    32'b????_????_????_????_?000_????_?001_0011: instr_rd_r0_vld = 1'b1;//addi
    32'b????_????_????_????_?010_????_?001_0011: instr_rd_r0_vld = 1'b1;//slti
    32'b????_????_????_????_?011_????_?001_0011: instr_rd_r0_vld = 1'b1;//sltiu
    32'b????_????_????_????_?100_????_?001_0011: instr_rd_r0_vld = 1'b1;//xori
    32'b????_????_????_????_?110_????_?001_0011: instr_rd_r0_vld = 1'b1;//ori
    32'b????_????_????_????_?111_????_?001_0011: instr_rd_r0_vld = 1'b1;//andi
    32'b0000_000?_????_????_?001_????_?001_0011: instr_rd_r0_vld = 1'b1;//slli
    32'b0000_000?_????_????_?101_????_?001_0011: instr_rd_r0_vld = 1'b1;//srli
    32'b0100_000?_????_????_?101_????_?001_0011: instr_rd_r0_vld = 1'b1;//srai
    32'b0000_000?_????_????_?000_????_?011_0011: instr_rd_r0_vld = 1'b1;//add
    32'b0100_000?_????_????_?000_????_?011_0011: instr_rd_r0_vld = 1'b1;//sub
    32'b0000_000?_????_????_?001_????_?011_0011: instr_rd_r0_vld = 1'b1;//sll
    32'b0000_000?_????_????_?010_????_?011_0011: instr_rd_r0_vld = 1'b1;//slt
    32'b0000_000?_????_????_?011_????_?011_0011: instr_rd_r0_vld = 1'b1;//sltu
    32'b0000_000?_????_????_?100_????_?011_0011: instr_rd_r0_vld = 1'b1;//xor
    32'b0000_000?_????_????_?101_????_?011_0011: instr_rd_r0_vld = 1'b1;//srl
    32'b0100_000?_????_????_?101_????_?011_0011: instr_rd_r0_vld = 1'b1;//sra
    32'b0000_000?_????_????_?110_????_?011_0011: instr_rd_r0_vld = 1'b1;//or
    32'b0000_000?_????_????_?111_????_?011_0011: instr_rd_r0_vld = 1'b1;//and
    32'b0000_0000_0000_0000_000?_????_????_??00: instr_rd_r0_vld = 1'b1;//c.addi4spn
    32'b0000_0000_0000_0000_000?_????_????_??01: instr_rd_r0_vld = 1'b1;//c.addi
    32'b0000_0000_0000_0000_010?_????_????_??01: instr_rd_r0_vld = 1'b1;//c.li
    32'b0000_0000_0000_0000_011?_???1_0???_??01: instr_rd_r0_vld = 1'b1;//c.addi16sp
    32'b0000_0000_0000_0000_011?_????_????_??01: instr_rd_r0_vld = 1'b1;//c.lui
    32'b0000_0000_0000_0000_100?_00??_????_??01: instr_rd_r0_vld = 1'b1;//c.srli
    32'b0000_0000_0000_0000_1000_01??_????_??01: instr_rd_r0_vld = 1'b1;//c.srai
    32'b0000_0000_0000_0000_1000_10??_????_??01: instr_rd_r0_vld = 1'b1;//c.andi
    32'b0000_0000_0000_0000_1000_11??_?00?_??01: instr_rd_r0_vld = 1'b1;//c.sub
    32'b0000_0000_0000_0000_1000_11??_?01?_??01: instr_rd_r0_vld = 1'b1;//c.xor
    32'b0000_0000_0000_0000_1000_11??_?10?_??01: instr_rd_r0_vld = 1'b1;//c.or
    32'b0000_0000_0000_0000_1000_11??_?11?_??01: instr_rd_r0_vld = 1'b1;//c.and
    32'b0000_0000_0000_0000_000?_????_????_??10: instr_rd_r0_vld = 1'b1;//c.slli
    32'b0000_0000_0000_0000_1000_????_????_??10: instr_rd_r0_vld = 1'b1;//c.mv
    32'b0000_0000_0000_0000_1001_????_????_??10: instr_rd_r0_vld = 1'b1;//c.add
    32'b0000_001?_????_????_?000_????_?011_0011: instr_rd_r0_vld = 1'b1;//mul
    32'b0000_001?_????_????_?001_????_?011_0011: instr_rd_r0_vld = 1'b1;//mulh
    32'b0000_001?_????_????_?010_????_?011_0011: instr_rd_r0_vld = 1'b1;//mulhsu
    32'b0000_001?_????_????_?011_????_?011_0011: instr_rd_r0_vld = 1'b1;//mulhu
    32'b0000_001?_????_????_?100_????_?011_0011: instr_rd_r0_vld = 1'b1;//div
    32'b0000_001?_????_????_?101_????_?011_0011: instr_rd_r0_vld = 1'b1;//divu
    32'b0000_001?_????_????_?110_????_?011_0011: instr_rd_r0_vld = 1'b1;//rem
    32'b0000_001?_????_????_?111_????_?011_0011: instr_rd_r0_vld = 1'b1;//remu
    default:
	    instr_rd_r0_vld = 1'b0;
endcase

reg instr_rd_r0_addr;
casez(instr_op) 
    32'b????_????_????_????_????_????_?011_0111: instr_rd_r0_addr = 5'h0;//lui
    32'b????_????_????_????_????_????_?001_0111: instr_rd_r0_addr = 5'h0;//auipc
    32'b????_????_????_????_?000_????_?001_0011: instr_rd_r0_addr = instr_op[19:15];//addi
    32'b????_????_????_????_?010_????_?001_0011: instr_rd_r0_addr = instr_op[19:15];//slti
    32'b????_????_????_????_?011_????_?001_0011: instr_rd_r0_addr = instr_op[19:15];//sltiu
    32'b????_????_????_????_?100_????_?001_0011: instr_rd_r0_addr = instr_op[19:15];//xori
    32'b????_????_????_????_?110_????_?001_0011: instr_rd_r0_addr = instr_op[19:15];//ori
    32'b????_????_????_????_?111_????_?001_0011: instr_rd_r0_addr = instr_op[19:15];//andi
    32'b0000_000?_????_????_?001_????_?001_0011: instr_rd_r0_addr = instr_op[19:15];//slli
    32'b0000_000?_????_????_?101_????_?001_0011: instr_rd_r0_addr = instr_op[19:15];//srli
    32'b0100_000?_????_????_?101_????_?001_0011: instr_rd_r0_addr = instr_op[19:15];//srai
    32'b0000_000?_????_????_?000_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//add
    32'b0100_000?_????_????_?000_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//sub
    32'b0000_000?_????_????_?001_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//sll
    32'b0000_000?_????_????_?010_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//slt
    32'b0000_000?_????_????_?011_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//sltu
    32'b0000_000?_????_????_?100_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//xor
    32'b0000_000?_????_????_?101_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//srl
    32'b0100_000?_????_????_?101_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//sra
    32'b0000_000?_????_????_?110_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//or
    32'b0000_000?_????_????_?111_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//and
    32'b0000_0000_0000_0000_000?_????_????_??00: instr_rd_r0_addr = instr_op[11:7];//c.addi4spn
    32'b0000_0000_0000_0000_000?_????_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.addi
    32'b0000_0000_0000_0000_010?_????_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.li
    32'b0000_0000_0000_0000_011?_???1_0???_??01: instr_rd_r0_addr = instr_op[11:7];//c.addi16sp
    32'b0000_0000_0000_0000_011?_????_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.lui
    32'b0000_0000_0000_0000_100?_00??_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.srli
    32'b0000_0000_0000_0000_1000_01??_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.srai
    32'b0000_0000_0000_0000_1000_10??_????_??01: instr_rd_r0_addr = instr_op[11:7];//c.andi
    32'b0000_0000_0000_0000_1000_11??_?00?_??01: instr_rd_r0_addr = instr_op[11:7];//c.sub
    32'b0000_0000_0000_0000_1000_11??_?01?_??01: instr_rd_r0_addr = instr_op[11:7];//c.xor
    32'b0000_0000_0000_0000_1000_11??_?10?_??01: instr_rd_r0_addr = instr_op[11:7];//c.or
    32'b0000_0000_0000_0000_1000_11??_?11?_??01: instr_rd_r0_addr = instr_op[11:7];//c.and
    32'b0000_0000_0000_0000_000?_????_????_??10: instr_rd_r0_addr = instr_op[11:7];//c.slli
    32'b0000_0000_0000_0000_1000_????_????_??10: instr_rd_r0_addr = 5'h0;//c.mv
    32'b0000_0000_0000_0000_1001_????_????_??10: instr_rd_r0_addr = instr_op[11:7];//c.add
    32'b0000_001?_????_????_?000_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//mul
    32'b0000_001?_????_????_?001_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//mulh
    32'b0000_001?_????_????_?010_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//mulhsu
    32'b0000_001?_????_????_?011_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//mulhu
    32'b0000_001?_????_????_?100_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//div
    32'b0000_001?_????_????_?101_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//divu
    32'b0000_001?_????_????_?110_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//rem
    32'b0000_001?_????_????_?111_????_?011_0011: instr_rd_r0_addr = instr_op[19:15];//remu
    default:
	    instr_rd_r0_addr = 5'h0;
endcase


reg instr_rd_r1_vld;
casez(instr_op) 
    32'b0000_000?_????_????_?000_????_?011_0011: instr_rd_r1_vld = 1'b1;//add
    32'b0100_000?_????_????_?000_????_?011_0011: instr_rd_r1_vld = 1'b1;//sub
    32'b0000_000?_????_????_?001_????_?011_0011: instr_rd_r1_vld = 1'b1;//sll
    32'b0000_000?_????_????_?010_????_?011_0011: instr_rd_r1_vld = 1'b1;//slt
    32'b0000_000?_????_????_?011_????_?011_0011: instr_rd_r1_vld = 1'b1;//sltu
    32'b0000_000?_????_????_?100_????_?011_0011: instr_rd_r1_vld = 1'b1;//xor
    32'b0000_000?_????_????_?101_????_?011_0011: instr_rd_r1_vld = 1'b1;//srl
    32'b0100_000?_????_????_?101_????_?011_0011: instr_rd_r1_vld = 1'b1;//sra
    32'b0000_000?_????_????_?110_????_?011_0011: instr_rd_r1_vld = 1'b1;//or
    32'b0000_000?_????_????_?111_????_?011_0011: instr_rd_r1_vld = 1'b1;//and
    32'b0000_0000_0000_0000_1000_11??_?00?_??01: instr_rd_r1_vld = 1'b1;//c.sub
    32'b0000_0000_0000_0000_1000_11??_?01?_??01: instr_rd_r1_vld = 1'b1;//c.xor
    32'b0000_0000_0000_0000_1000_11??_?10?_??01: instr_rd_r1_vld = 1'b1;//c.or
    32'b0000_0000_0000_0000_1000_11??_?11?_??01: instr_rd_r1_vld = 1'b1;//c.and
    32'b0000_0000_0000_0000_1000_????_????_??10: instr_rd_r1_vld = 1'b1;//c.mv
    32'b0000_0000_0000_0000_1001_????_????_??10: instr_rd_r1_vld = 1'b1;//c.add
    32'b0000_001?_????_????_?000_????_?011_0011: instr_rd_r1_vld = 1'b1;//mul
    32'b0000_001?_????_????_?001_????_?011_0011: instr_rd_r1_vld = 1'b1;//mulh
    32'b0000_001?_????_????_?010_????_?011_0011: instr_rd_r1_vld = 1'b1;//mulhsu
    32'b0000_001?_????_????_?011_????_?011_0011: instr_rd_r1_vld = 1'b1;//mulhu
    32'b0000_001?_????_????_?100_????_?011_0011: instr_rd_r1_vld = 1'b1;//div
    32'b0000_001?_????_????_?101_????_?011_0011: instr_rd_r1_vld = 1'b1;//divu
    32'b0000_001?_????_????_?110_????_?011_0011: instr_rd_r1_vld = 1'b1;//rem
    32'b0000_001?_????_????_?111_????_?011_0011: instr_rd_r1_vld = 1'b1;//remu
    default:
	    instr_rd_r1_vld = 1'b0;
endcase

assign instr_rd_r1_addr = instr_is_compressed ? instr_op[6:2] : instr_op[24:20];


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
casez(instr_op)
    32'b????_????_????_????_????_????_?011_0111: instr_use_imm = 1'b1;//lui
    32'b????_????_????_????_????_????_?001_0111: instr_use_imm = 1'b1;//auipc
    32'b????_????_????_????_?000_????_?001_0011: instr_use_imm = 1'b1;//addi
    32'b????_????_????_????_?010_????_?001_0011: instr_use_imm = 1'b1;//slti
    32'b????_????_????_????_?011_????_?001_0011: instr_use_imm = 1'b1;//sltiu
    32'b????_????_????_????_?100_????_?001_0011: instr_use_imm = 1'b1;//xori
    32'b????_????_????_????_?110_????_?001_0011: instr_use_imm = 1'b1;//ori
    32'b????_????_????_????_?111_????_?001_0011: instr_use_imm = 1'b1;//andi
    32'b0000_000?_????_????_?001_????_?001_0011: instr_use_imm = 1'b1;//slli
    32'b0000_000?_????_????_?101_????_?001_0011: instr_use_imm = 1'b1;//srli
    32'b0100_000?_????_????_?101_????_?001_0011: instr_use_imm = 1'b1;//srai
    32'b0000_0000_0000_0000_000?_????_????_??00: instr_use_imm = 1'b1;//c.addi4spn
    32'b0000_0000_0000_0000_000?_????_????_??01: instr_use_imm = 1'b1;//c.addi
    32'b0000_0000_0000_0000_010?_????_????_??01: instr_use_imm = 1'b1;//c.li
    32'b0000_0000_0000_0000_011?_???1_0???_??01: instr_use_imm = 1'b1;//c.addi16sp
    32'b0000_0000_0000_0000_011?_????_????_??01: instr_use_imm = 1'b1;//c.lui
    32'b0000_0000_0000_0000_100?_00??_????_??01: instr_use_imm = 1'b1;//c.srli
    32'b0000_0000_0000_0000_1000_01??_????_??01: instr_use_imm = 1'b1;//c.srai
    32'b0000_0000_0000_0000_1000_10??_????_??01: instr_use_imm = 1'b1;//c.andi
    32'b0000_0000_0000_0000_000?_????_????_??10: instr_use_imm = 1'b1;//c.slli
    default:
	    instr_use_imm = 1'b0;
endcase

reg[31:0] instr_imm;
casez(instr_op)
    32'b????_????_????_????_????_????_?011_0111: instr_imm = {instr_op[31:12], 12'h0};//lui
    32'b????_????_????_????_????_????_?001_0111: instr_imm = {instr_op[31:12], 12'h0};//auipc
    //32'b????_????_????_????_?000_????_?001_0011: instr_imm = ({20{instr_op[11]}, instr_op[11:0]});//addi
    //32'b????_????_????_????_?010_????_?001_0011: instr_imm = ({20{instr_op[11]}, instr_op[11:0]});//slti
    //32'b????_????_????_????_?011_????_?001_0011: instr_imm = ({20{instr_op[11]}, instr_op[11:0]});//sltiu
    //32'b????_????_????_????_?100_????_?001_0011: instr_imm = ({20{instr_op[11]}, instr_op[11:0]});//xori
    //32'b????_????_????_????_?110_????_?001_0011: instr_imm = ({20{instr_op[11]}, instr_op[11:0]});//ori
    //32'b????_????_????_????_?111_????_?001_0011: instr_imm = ({20{instr_op[11]}, instr_op[11:0]});//andi
    //32'b0000_000?_????_????_?001_????_?001_0011: instr_imm = ({20{instr_op[11]}, instr_op[11:0]});//slli
    //32'b0000_000?_????_????_?101_????_?001_0011: instr_imm = ({20{instr_op[11]}, instr_op[11:0]});//srli
    //32'b0100_000?_????_????_?101_????_?001_0011: instr_imm = ({20{instr_op[11]}, instr_op[11:0]});//srai
    32'b0000_0000_0000_0000_000?_????_????_??00: instr_imm = {24'h0, instr_op[10:7], instr_op[12:11], instr_op[5], instr_op[6]};//c.addi4spn
    32'b0000_0000_0000_0000_000?_????_????_??01: instr_imm = {{26{instr_op[12]}}, instr_op[12], instr_op[6:2]};//c.addi
    32'b0000_0000_0000_0000_010?_????_????_??01: instr_imm = {{26{instr_op[12]}}, instr_op[12], instr_op[6:2];//c.li
    32'b0000_0000_0000_0000_011?_???1_0???_??01: instr_imm = {{26{instr_op[12]}}, instr_op[12], instr_op[4:3], instr_op[5], instr_op[2], instr_op[6]};//c.addi16sp
    32'b0000_0000_0000_0000_011?_????_????_??01: instr_imm = {{14{instr_op[12]}}, instr_op[12], instr_op[6:2], 12'h0};//c.lui
    32'b0000_0000_0000_0000_100?_00??_????_??01: instr_imm = {26'h0, instr_op[12], instr_op[6:2]};//c.srli
    32'b0000_0000_0000_0000_1000_01??_????_??01: instr_imm = {26'h0, instr_op[12], instr_op[6:2]};//c.srai
    32'b0000_0000_0000_0000_1000_10??_????_??01: instr_imm = {26'h0, instr_op[12], instr_op[6:2]};//c.andi
    32'b0000_0000_0000_0000_000?_????_????_??10: instr_imm = {26'h0, instr_op[12], instr_op[6:2]};//c.slli
    default:
	    instr_imm = ({20{instr_op[11]}, instr_op[11:0]});
endcase


endmodule
