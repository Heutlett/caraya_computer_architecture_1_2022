module CONTROL_UNIT
(
	input logic clk, rst,
	// Instruction [31:20] = Decoding bits (no register and src bits)
	input logic [3:0] Cond,
	input logic [1:0] Op,
	input logic [5:0] Funct,
	input logic [3:0] ALUFlags,
	output logic MemtoReg, ALUSrc,
	output logic [1:0] ImmSrc, RegSrc, 
	output logic [2:0] ALUControl,
	output logic PCSrc, RegWrite, MemWrite
);

	logic [9:0] signals;
	logic Branch, ALUOp;
	logic MemW, RegW, UpdateFlag;
	

	always_comb
		case(Op)
										
			2'b00: 	
			
				if (Funct[5] & Funct[4:1] == 4'b1010) begin 				// CMP Immediate
					signals = 10'b0000100001;
				end else if(!Funct[5] & Funct[4:1] == 4'b1010) begin 	// CMP Register
					signals = 10'b0000000001; 
				end else if(Funct[5]) begin									// Data-processing immediate			
					signals = 10'b0000101001; 
				end else begin 													// Data-processing register 
					signals = 10'b0000001001; 
				end
				
			2'b01: 
				if (Funct[0]) begin												// LDR
					signals = 10'b0001111000; 
				end else begin														// STR
					signals = 10'b1001110100; 														
				end
										
			2'b10: signals = 10'b0110100010; 								// Be
										
			default: signals = 10'd0;
			
		endcase
	
	// Señales
	
	// RegSrc: señal de seleccion de los dos mux que entran al banco de registros.
					// El LSB (ra1mux): selecciona entre RN y "15" (pc)
					// El MSB (ra2mux): selecciona entre RM y RD
					
	//	ImmSrc: señal del extensor:
					// 00: 8-bit unsigned immediate
					// 01: 12-bit unsigned immediate
					// 10. 24-bit two's complement shifted branch
					
	// ALUSrc: señal de seleccion de la entrada B del ALU.
					// 0: selecciona el registro RD2.
				   // 1: selecciona el immediato exentedido.
	
	// MemtoReg: señal del mux que selecciona entre el resultado de la ALU o el dato leido de mem.
					// 0: ALURESULT
					// 1: ReadData (mem)
	
	// RegW: enable para escribir en el banco de registros
	
	// MemW: enable para escribir en la memoria
	
	// Branch: bandera del branch, se utiliza para definir el PCSrc (al final esta el assign)
	
	// ALUOp: bandera para indicar  si se necesita la ALU, con esta se define el valor de
	// ALUControl, abajo esta el decoder.
	
		
	//	CMP IMMEDIATE
	//			00			00			1			0		  0     0     0      1
	//	CMP REGISTER			
	//			00			00			0			0		  0	  0	  0		1
	// Data-processing immediate
	//			00			00			1			0	  	  1	  0	  0		1		
	// Data-processing register
	// 		00			00			0			0		  1	  0	  0		1		
	// LDR
	//			00			01			1			1		  1	  0	  0		0		
	// LDRB
	//			00			01			1			1		  1	  0	  0	   0		
	// STR
	// 		10			01			1			1		  0	  1	  0		0		
	// STRB
	//			10			01			1			1		  0	  1	  0		0		
	// B
	// 		01			10			1			0		  0	  0	  1		0		
	assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = signals;
	

	always_comb
	
		if (ALUOp) begin 
			case(Funct[4:1])
				4'b0100: ALUControl = 3'b000; // ADD
				4'b0010: ALUControl = 3'b001; // SUB
				4'b0000: ALUControl = 3'b010; // AND
				4'b1100: ALUControl = 3'b011; // ORR
				4'b1010: ALUControl = 3'b001; // COMPARE
				4'b1101: ALUControl = 3'b100; // MOV
				default: ALUControl = 3'b000; 
			endcase
		
		UpdateFlag = Funct[0]; // Si el bit S es 1: la instruccion es condicional (ocupa banderas)
		
		end else begin
			ALUControl 	= 3'b000; 	// ADD para las instrucciones tipo MEM
			UpdateFlag 	= 1'b0; 		// No se actualizan las banderas
		end

	
	
	///////////////////////////////////////////////////////////////////////////////////////
	////////////////// CONDITIONAL CONTROLLER (FLAGS MANAGMENT) ///////////////////////////
	
	logic CondResult;
	logic Zero;
	logic FlagWrite;
	
	// Registro que guarda el valor de la bandera de cero
	// Solo se escribe cuando se cumple el FlagWriteEnable
	REGISTER_FF_E zeroFlagReg(clk, reset, FlagWriteEnable, ALUFlags[2], Zero); // bandera Z
		
	
	
	assign FlagWriteEnable = UpdateFlag & CondResult;  	// Si S=1 y Zero = 1 ----> guarda el valor de la flag Z en un registro
														// para usarla luego cuando hay un branch.
														
														
	assign CondResult = ((Cond == 4'b0000) & Zero) | (Cond == 4'b1110);  // Condicion de ejecucion
																						// Si se cumple se ejecuta la instruccion
	
	// Señal de seleccion del mux SEL_PC (selecciona entre PC+4 y un Branch)
	assign PCSrc = Branch & CondResult; // Si PCS = 1 (branch) y Se cumple CondResult entonces se ejecuta branch (PCSrc = label)
	
	// Si se cumple la condicion entonces habilita la escritura
	assign RegWrite = RegW & CondResult;	
	assign MemWrite = MemW & CondResult;
	
endmodule