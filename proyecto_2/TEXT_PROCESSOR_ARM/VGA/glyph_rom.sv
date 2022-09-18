module glyph_rom(
    input wire clk,
    input [10:0] addr,
    output logic [7:0] data
);

reg [7:0] rom [2047:0];

initial begin
    $readmemb("glyphs.dat", rom);
end

always_ff @(posedge clk) begin
    data <= rom[addr];
end

endmodule