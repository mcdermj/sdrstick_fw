module halfbandfir(
	input clock,
	input in_strobe,
	input signed [23:0] in_data,
	output reg signed [23:0] out_data,
	output reg out_strobe
);

parameter TAPS = 128; // This is always odd

reg [2:0] state = 0;

reg do_write;

reg [5:0] coeff_addr = 0;

reg [6:0] samplea_addr = 0;
reg [6:0] sampleb_addr = TAPS - 1;
reg [6:0] write_addr = TAPS - 1;
wire [6:0] address_a = do_write ? write_addr : samplea_addr;

wire signed [23:0] samplea_value;
wire signed [23:0] sampleb_value;
wire signed [26:0] coeff_value;
wire signed [23:0] second_sample;

reg even_sample = 0;

reg signed [51:0] first_accum = 0;
wire signed [24:0] preadder = samplea_value + sampleb_value;
wire signed [49:0] product = preadder * coeff_value;
wire signed [49:0] second_product = second_sample <<< 25;
wire signed [51:0] accum = first_accum + second_product;
wire signed [23:0] unreg_out = accum[51-:24] + accum[51 - 24];

reg delay_enable;


halfbandfir_rom coeffs (
	.clock (clock),
	.address ({1'b0, coeff_addr}),
	.q (coeff_value)
);

halfbandfir_ram values (
	.clock (clock),
	.data_a (in_data),
	.data_b (24'b0),
	.q_a (samplea_value),
	.q_b (sampleb_value),
	.address_a(address_a),
	.address_b(sampleb_addr),
	.wren_a(do_write),
	.wren_b(1'b0)
);

halfbandfir_delay delay (
	.clock (clock),
	.clken (delay_enable),
	.shiftin (in_data),
	.shiftout (second_sample),
	.taps()
);

localparam IDLE = 0;
localparam WRITE = 1;
localparam WAIT1 = 2;
localparam WAIT2 = 3;
localparam CALC = 4;
localparam OUTPUT = 5;

always @(posedge clock) begin
	if(state > WRITE) begin
		coeff_addr <= coeff_addr + 1;
		if(samplea_addr == TAPS - 1)
			samplea_addr <= 0;
		else
			samplea_addr <= samplea_addr + 1;
		if(sampleb_addr == 0)
			sampleb_addr <= TAPS - 1;
		else
			sampleb_addr <= sampleb_addr - 1; 
	end

	if(in_strobe == 1) begin
		even_sample = ~even_sample;
	end

	out_strobe <= 1'b0;
	delay_enable = 1'b0;
	do_write <= 1'b0;

	case(state)
		IDLE: begin
			if(in_strobe == 1) begin
				if(even_sample) begin
					do_write <= 1'b1;
					first_accum <= 0;
					if(write_addr == TAPS - 1) begin
						write_addr <= 0;
						samplea_addr <= 1;
						sampleb_addr <= 0;
					end else begin
						write_addr <= write_addr + 1;
						samplea_addr <= write_addr + 2;
						sampleb_addr <= write_addr + 1;
					end
					coeff_addr <= 0;
					state <= WRITE;
				end else begin
					delay_enable = 1'b1;
					state <= OUTPUT;
				end
			end
		end
		WRITE: begin // Change this to WRITE
			state <= WAIT1;
		end
		WAIT1: begin
			state <= WAIT2;
		end
		WAIT2: begin
			state <= CALC;
		end
		CALC: begin
			//  We're done when coeff_addr is 1
			if(coeff_addr == 1) begin
				state <= IDLE;
			end

			first_accum <= product + first_accum;
		end
		OUTPUT: begin
			out_strobe <= 1'b1;
			out_data <= unreg_out;
			state <= IDLE;
		end
	endcase
end

endmodule
