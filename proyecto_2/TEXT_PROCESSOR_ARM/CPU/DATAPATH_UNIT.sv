module DATAPATH_UNIT
(
	input logic clk, reset, start,
	input logic [1:0] RegSrc,
	input logic RegWrite,
	input logic [1:0] ImmSrc,
	input logic ALUSrc,
	input logic [2:0] ALUControl,
	input logic MemtoReg,
	input logic PCSrc,
	output logic [3:0] ALUFlags,
	output logic [31:0] PC,
	input logic [31:0] Instr,
	output logic [31:0] ALUResult, WriteData,
	input logic [31:0] ReadData
);
	
	logic [3:0] RA1, RA2;
	logic [31:0] PC_NEXT, PCPlus4, PCPlus8;
	logic [31:0] ExtImm, SrcA, SrcB, result;
	
	
	// ---------------------- PC --------------------------
	
	// MUX PARA SELECCIONAR EL PROXIMO PC (PC+4) O (BRANCH)
	MUX_21 #(32) MUX21_PC(PCPlus4, result, PCSrc, PC_NEXT);
	
	// REGISTRO PARA EL PC
	PC_REG REG_PC(clk, reset, start, PC_NEXT, PC);
	
	// SUMADOR PARA EL PC+4
	ADDER ADDER_PC4(PC, 32'b100, PCPlus4);
	
	// SUMADOR PARA EL PC+8
	ADDER ADDER_PC8(PCPlus4, 32'b100, PCPlus8);
	
	// ------------------- REGISTER FILE--------------------
	
	MUX_21 #(4) MUX21_RA1(Instr[19:16], 4'b1111, RegSrc[0], RA1);
	
	MUX_21 #(4) MUX21_RA2(Instr[3:0], Instr[15:12], RegSrc[1], RA2);
	
	REGISTER_FILE REG_FILE(clk, RegWrite, RA1, RA2, Instr[15:12], result, PCPlus8,SrcA, WriteData);
					
	MUX_21 #(32) MUX21_RESULT(ALUResult, ReadData, MemtoReg, result);
	
	EXTEND EXTENDER(Instr[23:0], ImmSrc, ExtImm);
	
	// ------------------- ALU -------------------------------
	
	MUX_21 #(32) MUX_21_SRC_B(WriteData, ExtImm, ALUSrc, SrcB);
	
	ALU #(32) ALU_(SrcA, SrcB, ALUControl, ALUResult, ALUFlags);
	
endmodule