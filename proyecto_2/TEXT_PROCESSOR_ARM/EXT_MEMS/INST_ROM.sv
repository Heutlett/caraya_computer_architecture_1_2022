module INST_ROM
(
	input logic [31:0] a,
	output logic [31:0] rd
);

	logic [31:0] ROM[255:0];
	
	initial
		$readmemh("inst_mem_init.dat",ROM);
	
	assign rd = ROM[a[31:2]]; 	// Lee el dato en la direccion alineada "a",
										// se alinea por comodidad de trabajar de 4 en 4
										// (Un STR rx, [r0, #1] no se permite en CPULATOR)
	
endmodule