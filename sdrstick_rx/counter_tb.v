module counter_tb;

reg clk = 0;
reg reset = 1;
wire [23:0] out_data_i;
wire [23:0] out_data_q;

counter counter_inst (
	.clk (clk),
	.out_data_i (out_data_i),
	.out_data_q (out_data_q),
	.reset (reset)
);

initial
begin
	reset = 1;
end

always #5
begin
	clk = ~clk;
	reset = 0;
end

endmodule
