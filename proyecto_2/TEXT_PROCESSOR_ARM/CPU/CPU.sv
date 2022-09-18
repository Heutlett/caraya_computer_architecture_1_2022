module CPU
(
	input logic clk, reset, start,
	output logic [31:0] PC,
	input logic [31:0] Instr,
	output logic MemWrite,
	output logic [31:0] ALUResult, WriteData,
	input logic [31:0] ReadData
);

	logic [3:0] ALUFlags;
	logic RegWrite, ALUSrc, MemtoReg, PCSrc;
	logic [1:0] RegSrc, ImmSrc;
	logic [2:0] ALUControl;
	
	CONTROL_UNIT control_unit
	(
		clk, rst,
		Instr[31:28],
		Instr[27:26],
		Instr[25:20],
		ALUFlags,
		MemtoReg, ALUSrc,
		ImmSrc, RegSrc, 
		ALUControl,
		PCSrc, RegWrite, MemWrite
	);
					
	DATAPATH_UNIT datapath_unit
	(
		clk, reset, start,
		RegSrc, RegWrite, ImmSrc,
		ALUSrc, ALUControl,
		MemtoReg, PCSrc,
		ALUFlags, PC, Instr,
		ALUResult, WriteData, ReadData
	);
	
endmodule