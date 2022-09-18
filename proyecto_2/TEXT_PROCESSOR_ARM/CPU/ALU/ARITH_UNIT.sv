module ARITH_UNIT
#(parameter N = 4)
(
	input [N-1:0] a_i,
	input [N-1:0] b_i,
	input [2:0] opcode_i,
	output [N-1:0] result_o,
	output logic overflow_o,
	output logic cout_o
);
	import alu_defs::ARITH_ADD;
	import alu_defs::ARITH_SUB;
	import alu_defs::MOV_;
	
	logic [N:0] result_r;
	
	always_comb
	begin
		case (opcode_i)
			ARITH_ADD:
			begin
				result_r = (a_i + b_i);
				overflow_o = ~(a_i[N-1] ^ b_i[N-1]) & (result_r[N-1] ^ b_i[N-1]);
				cout_o = result_r[N];
			end
			ARITH_SUB:
			begin
				result_r = (a_i - b_i);
				overflow_o = (a_i[N-1] ^ b_i[N-1]) & (result_r[N-1] == b_i[N-1]);
				cout_o = result_r[N];
			end
			MOV_:
			begin
				result_r = b_i; 
				overflow_o = 0;
				cout_o = 0;
			end
			default:
			begin
				result_r = '0;
				overflow_o = 1'b0;
				cout_o = 1'b0;
			end
		endcase
	end
	
	assign result_o = result_r[N-1:0];
endmodule