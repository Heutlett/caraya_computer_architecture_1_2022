module TB_ALU;
	
	localparam N = 32;
	logic [N-1:0] result;
	logic [1:0] opcode;
	logic [N-1:0] a;
	logic [N-1:0] b;
	logic [3:0] ALUFlags;
	
	ALU #(.N(N)) alu_unit (
		.opcode_i(opcode),
		.a_i(a),
		.b_i(b),
		.result_o(result),
		.ALUFlags(ALUFlags)
	);
	
	initial begin
		// Incialización de variables
		opcode = 2'b00;
		a = 32'd1;
		b = 32'd10;
		#10;
		opcode = 2'b01;
		a = 32'd10;
		#10;
		opcode = 2'b10;
		#10;
		opcode = 2'b11;
		#10;
	end
endmodule