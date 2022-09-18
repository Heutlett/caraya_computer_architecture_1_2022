import arm_const::*;
module DATA_RAM
(
	input logic clk, we,
	input logic [31:0] a, wd,
	output logic [31:0] rd,
	output [31:0] tex_o [VGA_SCREEN_SIZE-1:0]
);

	logic ram_select;
	logic vram_select;
	logic [13:0] addr;
	
	assign addr = a[13:0];
	assign vram_select = a[14] & we;
	assign ram_select = !a[14] & we;
	
	DRAM cpu_ram
	(
		.clk(clk),
		.we(ram_select),
		.a(addr),
		.wd(wd),
		.rd(rd)
	);

	
	VRAM vram
	(
		.clk(clk),
		.we(vram_select),
		.a(addr),
		.wd(wd),
		.tex_o(tex_o)
	);
	
endmodule
