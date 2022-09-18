module PC_REG
(
	input logic clk, reset,start,
	input logic [31:0] d,
	output logic [31:0] q
);

	always_ff @(posedge clk, posedge reset)
		if (reset) q <= 0;
		else if(start) q <= d;
	
endmodule