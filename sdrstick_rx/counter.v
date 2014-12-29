module counter (
 input clk,
 input reset,
 output reg [23:0] out_data_i,
 output reg [23:0] out_data_q,
 output reg strobe
);

reg [10:0] delay = 0;

always @ (posedge clk)
begin
	if(reset == 1'b1) begin
		out_data_i = 0;
		out_data_q = 0;
	end else begin
		if(delay == 10'd640) begin	
			out_data_i <= out_data_i + 1;
			out_data_q <= ~out_data_i;
			strobe <= 1;
			delay <= 0;
		end else begin
			delay <= delay + 1;
			strobe <= 0;
		end
	end
end

endmodule
