import arm_const::*;
module VRAM
(
	input logic clk, we,
	input logic [13:0] a,
	input logic [31:0] wd,
	output [31:0] tex_o [VGA_SCREEN_SIZE-1:0]
);
	logic [31:0] tex [VGA_SCREEN_SIZE-1:0];

	assign tex_o = tex;

	always_ff @(posedge clk)
		if (we) begin 
			tex[a[13:2]] <= wd;
			
			$display("\n\n-----Write cycle---(vram)--");
			$display("Address:---------- %h", a);
			$display("Write data:------- %h", wd);
			$display("ASCII:------------ %c", wd[7:0]);
			
			case (wd[31:8])
				24'h000000: $display("COLOR RGB:-------- NEGRO");
				24'h00ff00: $display("COLOR RGB:-------- VERDE");
				24'hff0000: $display("COLOR RGB:-------- ROJO");
			endcase
		end
endmodule