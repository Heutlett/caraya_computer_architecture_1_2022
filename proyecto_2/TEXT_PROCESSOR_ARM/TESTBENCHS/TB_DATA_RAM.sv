import arm_const::*;
module TB_DATA_RAM();
	logic clk, we;
	logic [31:0] a, wd;
	logic [31:0] rd;
	logic [31:0] tex_o [VGA_SCREEN_SIZE-1:0];

	DATA_RAM d(clk,we,a,wd,rd,tex_o);

	initial begin
	
		#10; 
		clk = 0; we = 0; #10;

		a = 0;  wd = 1; #10; we = 1;  #10;
		a = 0;  we = 0;

		a = 100;  wd = 66; #10; we = 1;  #10;
		a = 100;  we = 0;


		a = 1;  wd = 77; #10; we = 1;  #10;
		a = 1;  we = 0;

	end

	always begin
		clk = ~clk; #5;
	end

endmodule