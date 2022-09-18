import arm_const::*;
module painter
(
	input clk,
	input [9:0] horzCoord,
	input [9:0] vertCoord,
	input [31:0] tex [VGA_SCREEN_SIZE-1:0],
	output logic pixel,
	output logic [23:0] colors
);

	localparam FONT_WIDTH = 8;
	localparam FONT_HEIGHT = 16;
	integer fontAddress;
	logic [FONT_WIDTH-1:0]  charBits;
	integer charPos = 0;
	integer bitPos = 0;
	
	
	glyph_rom glyphs(
		.clk(clk),
		.addr(fontAddress),
		.data(charBits)
	);
	
	always_ff @(negedge clk) begin
		pixel <= 1'b0;
		colors <= '0;
		charPos <= horzCoord/FONT_WIDTH + (vertCoord/FONT_HEIGHT) * 80;
		if (charPos <= VGA_SCREEN_SIZE) begin
			bitPos <= horzCoord % FONT_WIDTH;
			fontAddress <= tex[charPos][6:0] * 16 + vertCoord % FONT_HEIGHT;
			if (charBits[FONT_WIDTH-bitPos]) begin
				colors <= tex[charPos][31:8];
				pixel <= 1'b1;
			end
		end
	end
endmodule