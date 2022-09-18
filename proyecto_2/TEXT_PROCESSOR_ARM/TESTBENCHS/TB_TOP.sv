module TB_TOP();
	logic clk;
	logic rst;
	logic start;
	
	TEXT_PROCESSOR_TOP top(.clk(clk), .reset(rst), .start(start));
	
	initial begin
		rst 	<= 1; 	#10; rst 	<= 0;
		start <= 0; 	#10; start 	<= 1;
	end

	always
	begin
		clk <= 1; #5; clk <= 0; #5;
	end
	
endmodule