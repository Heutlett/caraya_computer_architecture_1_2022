module REGISTER_FF_E 
(
	input logic clk, reset, en,
	input logic d,
	output logic q
);

	always_ff @(posedge clk, posedge reset)
		if (reset) q <= 0;
		else if (en) q <= d;
		
endmodule