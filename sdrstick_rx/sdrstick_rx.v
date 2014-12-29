module sdrstick_rx (
	input wire 						clk,
	input wire 						reset,
	
	// Outputs to FIFO
	output wire [31:0]			fifo_writedata,
	output wire						fifo_write,
	
	// Control Interface
	input wire [2:0]				ctl_address,
	output reg [31:0]				ctl_readdata,
	input wire 						ctl_read,
	input wire [31:0]				ctl_writedata,
	input wire						ctl_write,
	
	// Inputs for Mercury Receiver module
	input wire						adc_clk,
	input wire                 adc_clk_reset,
	input wire signed [15:0]	adc_data,
	output wire                 debug_led
);

	//  Hard code phase word for 10MHz and a 192k sample rate
	reg [5:0] sample_rate = 6'd10;
	reg [31:0] phase_word = 32'd2863313051;
	wire [23:0] i_sample_in;
	reg [31:0] i_sample;
	wire [23:0] q_sample_in;
	reg [31:0] q_sample;
	wire strobe;
	
	reg write;
	reg [31:0] writedata;
	reg led;
	
	reg enabled = 1'b0;
	reg enabled_122 = 1'b0;
	reg [31:0] phase_word_122 = 32'd2863313051;
	
	assign fifo_write = write;
	assign fifo_writedata = writedata;
	assign debug_led = led;
	
	//assign i_sample = {i_sample_in, 8'b0};
	//assign q_sample = {q_sample_in, 8'b0};

	receiver rx(
		.clock(adc_clk),
		.rate(sample_rate),
		.frequency(phase_word_122),
		//.frequency(32'd330382110),
		.out_strobe(strobe),
		.in_data(adc_data),
		.out_data_I(i_sample_in),
		.out_data_Q(q_sample_in)
	);

	/* counter counter_inst(
		.clk(adc_clk),
		.reset(reset),
		.out_data_i(i_sample_in),
		.out_data_q(q_sample_in),
		.strobe(strobe)
	); */
	
	//  The control interface from the CPU
	always @ (posedge clk) begin
		if (reset == 1'b1) begin
			enabled <= 1'b0;
		end else
		begin
			if(ctl_write == 1'b1) begin
				case(ctl_address)
					3'd0:
						enabled <= ctl_writedata[0];
					3'd1:
						phase_word <= ctl_writedata;
					default:
						;
				endcase
			end
			else if(ctl_read == 1'b1) begin
				case(ctl_address)
					3'd0: 
						ctl_readdata <= {31'd0, enabled};
					3'd1:
						ctl_readdata <= phase_word;
					default:
						ctl_readdata <= 32'd0;
				endcase
			end
		end
	end
	
	//  Prepare registers for clock domain crossing
	always @ (posedge adc_clk) begin
		enabled_122 <= enabled;
		phase_word_122 <= phase_word;
	end
	
	localparam STATE_IDLE = 3'b00;
	localparam STATE_WRITE_I = 3'b01;
	localparam STATE_WRITE_Q = 3'b10;
	reg [2:0] state = STATE_IDLE;
	wire strobe_edge;
	reg old_strobe;

	assign strobe_edge = strobe & !old_strobe;

	//  The data transfer process
	always @ (posedge adc_clk) begin
		if (adc_clk_reset == 1'b1 || enabled_122 == 1'b0) begin
			state <= STATE_IDLE;
		end else begin
			old_strobe <= strobe;	
			case (state)
				STATE_IDLE: begin
					write <= 1'b0;
					led <= 1'b0;
					if (strobe_edge == 1'b1) begin
						state <= STATE_WRITE_I;
					end
				end
				STATE_WRITE_I: begin
					writedata <= {8'b0, i_sample_in};
					//writedata <= {8'b0, 24'hABCDEF};
					write <= 1'b1;
					led <= 1'b1;
					state <= STATE_WRITE_Q;
				end
				STATE_WRITE_Q: begin
					writedata <= {8'b0, q_sample_in};
					//writedata <= 32'b0;
					write <= 1'b1;
					led <= 1'b1;
					state <= STATE_IDLE;
				end
				default: state <= STATE_IDLE;
			endcase
		end
	end

endmodule
