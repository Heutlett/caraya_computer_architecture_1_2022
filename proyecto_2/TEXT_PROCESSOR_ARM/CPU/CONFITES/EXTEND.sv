module EXTEND
(
	input logic [23:0] Instr,
	input logic [1:0] ImmSrc,
	output logic [31:0] ExtImm
);
	logic [4:0] shift;
	logic [31:0] val;

	assign shift = {Instr[11:8], 1'b0};
	assign val   = {24'b0, Instr[7:0]};

	always_comb
		case(ImmSrc)
						// 8-bits
			2'b00: 	ExtImm = (val >> shift) | (val << (32 - shift));
						// 12-bits 
			2'b01: 	ExtImm = (val >> shift) | (val << (32 - shift));
						// 24-bits
			2'b10: 	ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00};
			default: ExtImm = 32'bx; 
		endcase

endmodule