`timescale 1ns / 100ps

module top_tb;


top topi(
	.clk(tb_clk),
	.rst(tb_rst)
);

reg tb_clk = 1'b0;
reg tb_rst = 1'b1;

// Setup recording
initial begin
	$dumpfile("top_tb.vcd");
	$dumpvars(0,top_tb);
end

always #42 tb_clk = !tb_clk; // 42ns half, 84ns period (12MHz)

initial begin
	#100 tb_rst = 1'b0;
	#1000 $finish; // 1us
end
endmodule
