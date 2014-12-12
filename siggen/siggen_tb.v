module siggen_tb;
reg clk;
reg reset;
wire [15:0] test_signal;

siggen siggen_inst(
	.clk (clk),
	.reset (reset),
	.signal (test_signal));


initial begin
	clk = 0;
	reset = 1;
end

always #5 begin
	clk = !clk;
	reset = 0;
end


endmodule