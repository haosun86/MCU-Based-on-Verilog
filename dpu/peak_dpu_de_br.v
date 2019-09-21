////////////////////////////////////////////////////////////
// File Description: This file is main decoder
// It can decode compressed and non-compressed
// instructions
// In this file, it can decode branch instructions 
// Date:   2019.09.18
///////////////////////////////////////////////////////////

module peak_dpu_de_br
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

instr_is_jal,
instr_is_br,

instr_br_op

);

//alu op encoding
localparam   JAL  = 3'h0;
localparam   JALR = 3'h1;
localparam   BEQ  = 3'h2;
localparam   BNE  = 3'h3;
localparam   BLT  = 3'h4;
localparam   BGE  = 3'h5;
localparam   BLTU = 3'h6;
localparam   BGEU = 3'h7;

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

output       instr_is_jal;
output       instr_is_br;

output[2:0]  instr_br_op;


reg[2:0] instr_br_op;
always @ (*) begin
	casez(instr_op[15:0])
	16'b????_????_?110_1111: instr_br_op = JAL;  //jal
	16'b????_????_?110_0111: instr_br_op = JALR; //jalr
	16'b?000_????_?110_0011: instr_br_op = BEQ;  //beq
	16'b?001_????_?110_0011: instr_br_op = BNE;  //bne
	16'b?100_????_?110_0011: instr_br_op = BLT;  //blt
	16'b?101_????_?110_0011: instr_br_op = BGE;  //bge
	16'b?110_????_?110_0011: instr_br_op = BLTU; //bltu
	16'b?111_????_?110_0011: instr_br_op = BGEU; //bgeu
	16'b001?_????_????_??01: instr_br_op = JAL;  //c.jal
	16'b101?_????_????_??01: instr_br_op = JAL;  //c.j
	16'b110?_????_????_??01: instr_br_op = BEQ;  //c.beqz
	16'b111?_????_????_??01: instr_br_op = BNE;  //c.bnez
	16'b1000_????_?000_0010: instr_br_op = JALR; //c.jr
	16'b1001_????_?000_0010: instr_br_op = JALR; //c.jalr
	default:
		instr_br_op = 3'h0;
	endcase
end

reg instr_is_jal;
always @ (*) begin
	casez(instr_op[15:0])
	16'b????_????_?110_1111: instr_is_jal = 1'b1;  //jal
	16'b????_????_?110_0111: instr_is_jal = 1'b1; //jalr
	16'b001?_????_????_??01: instr_is_jal = 1'b1;  //c.jal
	16'b101?_????_????_??01: instr_is_jal = 1'b1;  //c.j
	16'b1000_????_?000_0010: instr_is_jal = 1'b1; //c.jr
	16'b1001_????_?000_0010: instr_is_jal = 1'b1; //c.jalr
	default:
		instr_is_jal = 1'b1;
	endcase
end

reg instr_is_br;
always @ (*) begin
	casez(instr_op[15:0])
	16'b????_????_?110_1111: instr_is_br = 1'b1;  //jal
	16'b????_????_?110_0111: instr_is_br = 1'b1; //jalr
	16'b?000_????_?110_0011: instr_is_br = 1'b1;  //beq
	16'b?001_????_?110_0011: instr_is_br = 1'b1;  //bne
	16'b?100_????_?110_0011: instr_is_br = 1'b1;  //blt
	16'b?101_????_?110_0011: instr_is_br = 1'b1;  //bge
	16'b?110_????_?110_0011: instr_is_br = 1'b1; //bltu
	16'b?111_????_?110_0011: instr_is_br = 1'b1; //bgeu
	16'b001?_????_????_??01: instr_is_br = 1'b1;  //c.jal
	16'b101?_????_????_??01: instr_is_br = 1'b1;  //c.j
	16'b110?_????_????_??01: instr_is_br = 1'b1;  //c.beqz
	16'b111?_????_????_??01: instr_is_br = 1'b1;  //c.bnez
	16'b1000_????_?000_0010: instr_is_br = 1'b1; //c.jr
	16'b1001_????_?000_0010: instr_is_br = 1'b1; //c.jalr
	default:
		instr_is_br = 1'b1;
	endcase
end

reg instr_rd_r0_vld;
always @ (*) begin
    casez(instr_op[15:0]) 
	16'b????_????_?110_0111: instr_rd_r0_vld = JALR; //jalr
	16'b?000_????_?110_0011: instr_rd_r0_vld = BEQ;  //beq
	16'b?001_????_?110_0011: instr_rd_r0_vld = BNE;  //bne
	16'b?100_????_?110_0011: instr_rd_r0_vld = BLT;  //blt
	16'b?101_????_?110_0011: instr_rd_r0_vld = BGE;  //bge
	16'b?110_????_?110_0011: instr_rd_r0_vld = BLTU; //bltu
	16'b?111_????_?110_0011: instr_rd_r0_vld = BGEU; //bgeu
	16'b110?_????_????_??01: instr_rd_r0_vld = BEQ;  //c.beqz
	16'b111?_????_????_??01: instr_rd_r0_vld = BNE;  //c.bnez
	16'b1000_????_?000_0010: instr_rd_r0_vld = JALR; //c.jr
	16'b1001_????_?000_0010: instr_rd_r0_vld = JALR; //c.jalr
	default:
    	    instr_rd_r0_vld = 1'b0;
    endcase
end

reg[4:0] instr_rd_r0_addr;
always @ (*) begin
    casez(instr_op[15:0]) 
	16'b110?_????_????_??01: instr_rd_r0_addr = {2'h0, instr_op[9:7]};  //c.beqz
	16'b111?_????_????_??01: instr_rd_r0_addr = {2'h0, instr_op[9:7]};  //c.bnez
	16'b1000_????_?000_0010: instr_rd_r0_addr = instr_op[11:7]; //c.jr
	16'b1001_????_?000_0010: instr_rd_r0_addr = instr_op[11:7]; //c.jalr
        default:
    	    instr_rd_r0_addr = instr_op[19:15];
    endcase
end


reg instr_rd_r1_vld;
always @ (*) begin
    casez(instr_op[15:0]) 
	16'b?000_????_?110_0011: instr_rd_r1_vld = 1'b1;  //beq
	16'b?001_????_?110_0011: instr_rd_r1_vld = 1'b1;  //bne
	16'b?100_????_?110_0011: instr_rd_r1_vld = 1'b1;  //blt
	16'b?101_????_?110_0011: instr_rd_r1_vld = 1'b1;  //bge
	16'b?110_????_?110_0011: instr_rd_r1_vld = 1'b1; //bltu
	16'b?111_????_?110_0011: instr_rd_r1_vld = 1'b1; //bgeu
	16'b110?_????_????_??01: instr_rd_r1_vld = 1'b1;  //c.beqz
	16'b111?_????_????_??01: instr_rd_r1_vld = 1'b1;  //c.bnez
        default:
    	    instr_rd_r1_vld = 1'b0;
    endcase
end

reg[4:0] instr_rd_r1_addr;
always @ (*) begin
    casez(instr_op[15:0]) 
	16'b110?_????_????_??01: instr_rd_r1_vld = 5'h0;  //c.beqz
	16'b111?_????_????_??01: instr_rd_r1_vld = 5'h0;  //c.bnez
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
    casez(instr_op[15:0])
	16'b1000_????_?000_0010: instr_use_imm = 1'b0; //c.jr
	16'b1001_????_?000_0010: instr_use_imm = 1'b0; //c.jalr
        default:
    	    instr_use_imm = 1'b1;
    endcase
end

reg[31:0] instr_imm;
always @ (*) begin
    casez(instr_op[15:0])
	16'b????_????_?110_1111: instr_imm = ({{11{instr_op[31]}}, instr_op[31], instr_op[19:12], instr_op[20], instr_op[30:21], 1'b0});  //jal
	16'b????_????_?110_0111: instr_imm = {{20{instr_op[31]}}, instr_op[31:20]}; //jalr
	16'b001?_????_????_??01: instr_imm = {{20{instr_op[12]}}, instr_op[12], instr_op[8], instr_op[10:9], 
	                                      instr_op[6], instr_op[7], instr_op[2], instr_op[11], instr_op[5:3], 1'b0};  //c.jal
	16'b101?_????_????_??01: instr_imm ={{20{instr_op[12]}}, instr_op[12], instr_op[8], instr_op[10:9], 
	       	                                                 instr_op[6], instr_op[7], instr_op[2], instr_op[11], instr_op[5:3], 1'b0};  //c.j
	16'b110?_????_????_??01: instr_imm = {{23{instr_op[12]}}, instr_op[6:5], instr_op[2], instr_op[11:10], instr_op[4:3], 1'b0};  //c.beqz
	16'b111?_????_????_??01: instr_imm = {{23{instr_op[12]}}, instr_op[6:5], instr_op[2], instr_op[11:10], instr_op[4:3], 1'b0;  //c.bnez
        default:
    	    instr_imm = {{19{instr_op[12]}}, instr_op[31], instr_op[7], instr_op[30:25], instr_op[11:8], 1'b0};
    endcase
end


endmodule
