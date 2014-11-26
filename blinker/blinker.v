// blinker.v

`timescale 1 ps / 1 ps
module blinker (
		input  wire  clk,   // clock.clk
		input  wire  reset, // reset.reset
		input  wire  [7:0] address,
		output  reg  [31:0] readdata,
		input  wire  read,
		input  wire  [31:0] writedata,
		input  wire  write,
		
		output wire  led   //   led.export
	);

	reg [31:0] counter;
	reg [31:0] divider;
	reg led_state;

	assign led = led_state;
	
	always @(posedge clk)
	begin
		if (reset == 1'b1)
		begin
			divider <= 32'd0;
		end else
		begin
			if(write == 1'b1)
			begin
				case(address)
					8'd0:
					begin
						divider <= writedata;
					end
				endcase
			end
			else if(read == 1'b1)
			begin
				case(address)
					8'd0:
					begin
						readdata <= divider;
					end
				endcase
			end
		end
	end

	always @(posedge clk)
	begin
		if(reset == 1'b1)
		begin
			counter <= 32'd0;
		end else
		begin
			if(counter > divider) 
				counter <= 0;
			else
				counter <= counter + 1;
			if(counter == divider)
			begin
				counter <= 32'd0;
				led_state = ~led_state;
			end
		end
	end

endmodule
