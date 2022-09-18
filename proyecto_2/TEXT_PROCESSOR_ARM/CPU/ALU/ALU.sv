module ALU
#(parameter N = 4)
(
	
	input [N-1:0] a_i,
	input [N-1:0] b_i,
	input [2:0] opcode_i,
	output logic [N-1:0] result_o,
	output [3:0] ALUFlags
);
	import alu_defs::*;
	
	logic [N-1:0] arith_result_w;
	logic arith_v;
	logic arith_c;
	
	ARITH_UNIT #(.N(N)) arithmetics (
		.a_i(a_i),
		.b_i(b_i),
		.opcode_i(opcode_i),
		.result_o(arith_result_w),
		.overflow_o(arith_v),
		.cout_o(arith_c)
	);
	
	always_comb
	begin
		case (opcode_i)
			AND_: result_o = a_i & b_i;
			OR_: result_o = a_i | b_i;
			default: result_o = arith_result_w;
		endcase
	end
	
	assign ALUFlags[0] = ~opcode_i[1] & arith_v;
	assign ALUFlags[1] = ~opcode_i[1] & arith_c;
	assign ALUFlags[2] = (result_o == '0);
	assign ALUFlags[3] = result_o[N-1];
	
endmodule