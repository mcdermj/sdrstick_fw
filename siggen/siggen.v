module siggen(
	input clk,
	input reset,
	output wire [15:0] signal
);

reg [3:0] counter = 0;

assign out_signal = signal;

siggen_table siggen_table_inst (
	.address(counter),
	.clock (clk),
	.q (signal));
		
always @(posedge clk) begin
	if(reset == 1'b1) begin
		counter <= 4'b0;
	end
	
	if(counter == 12)
		counter <= 0;
	else
		counter <= counter + 1;
end

endmodule