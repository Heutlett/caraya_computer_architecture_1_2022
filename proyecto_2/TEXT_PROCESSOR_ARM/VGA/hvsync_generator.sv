module hvsync_generator(
    input clk,
    output vga_h_sync,
    output vga_v_sync,
    output logic inDisplayArea,
    output logic [9:0] CounterX,
    output logic [9:0] CounterY
  );
    logic vga_HS, vga_VS;

    always_ff @(posedge clk)
    if (CounterX < 799)
		CounterX <= CounterX + 1;
    else
      CounterX <= 0;

    always_ff @(posedge clk)
    begin
      if (CounterX == 799)
      begin
        if(CounterY < 525)
			 CounterY <= CounterY + 1;
        else
         CounterY <= 0;
      end
    end

    always_ff @(posedge clk)
    begin
      vga_HS <= (CounterX > (640 + 16) && (CounterX < (640 + 16 + 96)));
      vga_VS <= (CounterY > (480 + 10) && (CounterY < (480 + 10 + 2))); 
    end

    always_ff @(posedge clk)
    begin
        inDisplayArea <= (CounterX < 640) && (CounterY < 480);
    end

		assign vga_h_sync = ~vga_HS;
		assign vga_v_sync = ~vga_VS;

endmodule