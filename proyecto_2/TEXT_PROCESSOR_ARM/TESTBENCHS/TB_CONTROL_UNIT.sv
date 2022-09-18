module TB_CONTROL_UNIT();

	logic clk, rst;
	logic [3:0] Cond;
	logic [1:0] Op;
	logic [5:0] Funct;
	logic [3:0] ALUFlags;
	logic MemtoReg, ALUSrc;
	logic [1:0] ImmSrc, RegSrc; 
	logic [2:0] ALUControl;
	logic PCSrc, RegWrite, MemWrite;
	logic [31:0] instr;

	CONTROL_UNIT cu
	(
		clk, rst,Cond,Op,Funct,ALUFlags,
		MemtoReg, ALUSrc,ImmSrc, RegSrc, ALUControl,
		PCSrc, RegWrite, MemWrite
	);

	initial begin
	

		clk = 0; 
		instr = 32'he2800004;   // ADD		r0,r0,#4
		
		Cond = instr[31:28];
		Op = instr[27:26];
		Funct = instr[25:20];
		ALUFlags = 4'b0000;
		
		#10;
		instr = 32'he3a00000;   // MOV		r0,#0x0 
		
		Cond = instr[31:28];
		Op = instr[27:26];
		Funct = instr[25:20];
		ALUFlags = 4'b0000;
		
		#10;
		instr = 32'he35100ff;   // CMP		r1,#0xFF
	
		Cond = instr[31:28];
		Op = instr[27:26];
		Funct = instr[25:20];
		ALUFlags = 4'b0000;
	
		#10;
		instr = 32'he5901000;   // LDR		r1,[r0]
		
		Cond = instr[31:28];
		Op = instr[27:26];
		Funct = instr[25:20];
		ALUFlags = 4'b0000;
		
		#10;
		instr = 32'he5804000;   // STR		r4, [r0]
		
		Cond = instr[31:28];
		Op = instr[27:26];
		Funct = instr[25:20];
		ALUFlags = 4'b0000;
	
		#10;
		instr = 32'heaffffdf;   // B		   find_cycle
		
		Cond = instr[31:28];
		Op = instr[27:26];
		Funct = instr[25:20];
		ALUFlags = 4'b0000;
		
		#10;
		instr = 32'h0a00003f;  // BEQ
		
		Cond = instr[31:28];
		Op = instr[27:26];
		Funct = instr[25:20];
		ALUFlags = 4'b0000;
		
		#10;
		
		$stop;
		
		
	end

	always begin
		clk = ~clk; #5;
		
		if (clk) begin
		
			$display("\n-------------------------------");
			$display("Instruccion: %h", instr);
			$display("\nMemtoReg: %d", MemtoReg);
			$display("ALUSrc: %d", ALUSrc);
			$display("ImmSrc: %d", ImmSrc);
			$display("RegSrc: %d", RegSrc);
			$display("ALUControl: %d", ALUControl);
			$display("PCSrc: %d", PCSrc);
			$display("RegWrite: %d", RegWrite);  
			$display("MemWrite: %d", MemWrite);
		end
		
	end

endmodule