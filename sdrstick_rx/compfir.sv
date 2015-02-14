//  All the information for a single polyphase component

module compfir #(ORDER = 490, COMPONENTS = 2, BASENAME = "compfir_p", COEFF_WIDTH = 27, INPUT_WIDTH = 24, OUTPUT_WIDTH = 24, ACCUM_WIDTH = 51) (
	input clock,
	input in_strobe,
	input signed [INPUT_WIDTH-1:0] in_data,
	output logic signed [OUTPUT_WIDTH-1:0] out_data,
	output logic out_strobe
);

localparam TAPS = ORDER + 1;

logic signed [ACCUM_WIDTH-1:0] accum = 0;
logic signed [23:0] in_data_reg;

function logic [COMPONENTS-1:0][31:0] get_taps;
	input [31:0] increment;
	integer j;
	logic [31:0] tapsleft;
	begin
		for(j = 0, tapsleft = TAPS; j < COMPONENTS; ++j, tapsleft -= increment)
			get_taps[j] = increment > tapsleft ? tapsleft : increment;
	end
endfunction

localparam [COMPONENTS-1:0][31:0] COMPONENT_TAPS = get_taps(TAPS / real'(COMPONENTS));

localparam [$size(phase[0].coeff_addr)-1:0] STOP_VALUE = $size(phase[0].coeff_addr)'(COMPONENT_TAPS[0] / 2) + 1'd1;

struct {
	logic do_write;
	logic [$clog2(COMPONENT_TAPS[0] / 2)-1:0] coeff_addr;
	logic [$clog2(COMPONENT_TAPS[0])-1:0] samplea_addr;
	logic [$clog2(COMPONENT_TAPS[0])-1:0] sampleb_addr;
	logic [$clog2(COMPONENT_TAPS[0])-1:0] write_addr;
} phase[COMPONENTS] = '{default: '{do_write:0, coeff_addr:0, samplea_addr:1, sampleb_addr:0, write_addr:0}};

struct {
	logic signed [INPUT_WIDTH-1:0] samplea;
	logic signed [INPUT_WIDTH-1:0] sampleb;
	logic signed [COEFF_WIDTH-1:0] coeff;
} phase_out[COMPONENTS];

genvar i;
generate
for(i = 0; i < COMPONENTS; ++i) begin: storage
	compfir_rom #(.filename ({ BASENAME, i + 48, ".mif" }), .depth(COMPONENT_TAPS[0] / 2), .width(COEFF_WIDTH)) coeffs (
		.clock (clock),
		.address (phase[i].coeff_addr >= COMPONENT_TAPS[0] / 2 ? '0 : phase[i].coeff_addr),
		.coeff (phase_out[i].coeff)
	);
	
	compfir_ram #(.depth (COMPONENT_TAPS[i]), .width (INPUT_WIDTH)) samples (
		.clock (clock),
		.data_a (in_data_reg),
		.do_write (phase[i].do_write),
		.write_addr (phase[i].write_addr),
		.sampleb_addr (phase[i].sampleb_addr),
		.samplea_addr (phase[i].samplea_addr),
		.samplea (phase_out[i].samplea),
		.sampleb (phase_out[i].sampleb)
	);	
end
endgenerate

enum logic [2:0] {
	IDLE = 3'd0,
	WRITE = 3'd1,
	WAIT1 = 3'd2,
	WAIT2 = 3'd3,
	CALC = 3'd4,
	CLKOUT = 3'd5 
} state = IDLE;

logic [$clog2(COMPONENTS):0] current_phase = 0;

logic signed [INPUT_WIDTH-1:0] samplea;
assign samplea = ((phase[current_phase].coeff_addr == STOP_VALUE) && (current_phase == COMPONENTS - 1)) ? 0 : phase_out[current_phase].samplea;
logic signed [INPUT_WIDTH:0] sum;
assign sum = samplea + phase_out[current_phase].sampleb;
logic signed [INPUT_WIDTH + COEFF_WIDTH:0] product;
assign product = sum * phase_out[current_phase].coeff;


always @(posedge clock) begin
	out_strobe <= 1'b0;
	
	if(state > WRITE) begin
		phase[current_phase].coeff_addr <= phase[current_phase].coeff_addr + 1'd1;
	
		phase[current_phase].samplea_addr <= phase[current_phase].samplea_addr == COMPONENT_TAPS[current_phase] - 1'd1 ? 0 : phase[current_phase].samplea_addr + 1'd1;
		phase[current_phase].sampleb_addr <= phase[current_phase].sampleb_addr == 0 ? COMPONENT_TAPS[current_phase] - 1'd1 : phase[current_phase].sampleb_addr - 1'd1;
	end

	case(state)
		IDLE: begin
			if(in_strobe == 1) begin
				phase[current_phase].do_write <= 1'b1;
				in_data_reg <= in_data;
				
				case(phase[current_phase].write_addr)
					COMPONENT_TAPS[current_phase] - 2'd2: begin
						phase[current_phase].sampleb_addr <= COMPONENT_TAPS[current_phase] - 1'd1;
						phase[current_phase].write_addr <= COMPONENT_TAPS[current_phase] - 1'd1;
						phase[current_phase].samplea_addr <= 0;
					end
					COMPONENT_TAPS[current_phase] - 1'd1: begin
						phase[current_phase].sampleb_addr <= 0;
						phase[current_phase].write_addr <= 0;
						phase[current_phase].samplea_addr <= 1'd1;
					end
					default: begin
						phase[current_phase].sampleb_addr <= phase[current_phase].write_addr + 1'd1;
						phase[current_phase].write_addr <= phase[current_phase].write_addr + 1'd1;
						phase[current_phase].samplea_addr <= phase[current_phase].write_addr + 2'd2;
					end
				endcase
				
				phase[current_phase].coeff_addr <= 0;
				
				state <= WRITE;
			end
		end
		WRITE: begin
			phase[current_phase].do_write <= 0;
			state <= WAIT1;
		end
		WAIT1: begin
			state <= WAIT2;
		end
		WAIT2: begin
			state <= CALC;
		end
		CALC: begin
			accum <= product + accum;
			
			if(phase[current_phase].coeff_addr == STOP_VALUE) begin
				state <= current_phase == COMPONENTS - 1'd1 ? CLKOUT : IDLE;
				current_phase <= current_phase + 1'd1;				
			end
		end
		CLKOUT: begin
			out_strobe <= 1'b1;
			//out_data <= accum[ACCUM_WIDTH-1-:OUTPUT_WIDTH]; // + accum[ACCUM_WIDTH - OUTPUT_WIDTH];
			//out_data <= accum[49-:OUTPUT_WIDTH] + (accum[49] & |accum[49-OUTPUT_WIDTH-1:0]);
			out_data <= accum[ACCUM_WIDTH-1-:OUTPUT_WIDTH] + (accum[ACCUM_WIDTH-1] & |accum[ACCUM_WIDTH-OUTPUT_WIDTH-1:0]);
			accum <= 0;
			current_phase <= 0;
			state <= IDLE;
		end
	endcase
end

endmodule

module compfir_ram #(depth = 128, width = 24) (
	input clock,
	input [width-1:0] data_a,
	input do_write,
	input [$clog2(depth)-1:0] write_addr,
	input [$clog2(depth)-1:0] sampleb_addr,
	input [$clog2(depth)-1:0] samplea_addr,
	output signed [width-1:0] samplea,
	output signed [width-1:0] sampleb
);

	wire [23:0] sub_wire0;
	wire [23:0] sub_wire1;
	assign samplea = sub_wire0[23:0];
	assign sampleb = sub_wire1[23:0];

	altsyncram	altsyncram_component (
				.address_a (do_write ? write_addr : samplea_addr),
				.address_b (sampleb_addr),
				.clock0 (clock),
				.data_a (data_a),
				.data_b (24'b0),
				.wren_a (do_write),
				.wren_b (1'b0),
				.q_a (sub_wire0),
				.q_b (sub_wire1),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.eccstatus (),
				.rden_a (1'b1),
				.rden_b (1'b1));
	defparam
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.indata_reg_b = "CLOCK0",
		altsyncram_component.intended_device_family = "Cyclone V",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = depth,
		altsyncram_component.numwords_b = depth,
		altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.outdata_reg_b = "CLOCK0",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_mixed_ports = "OLD_DATA",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.widthad_a = $clog2(depth),
		altsyncram_component.widthad_b = $clog2(depth),
		altsyncram_component.width_a = width,
		altsyncram_component.width_b = width,
		altsyncram_component.width_byteena_a = 1,
		altsyncram_component.width_byteena_b = 1,
		altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK0";
endmodule

module compfir_rom #(width = 27, depth = 64, filename = "") (
	input clock,
	input [$clog2(depth)-1:0] address,
	output [width-1:0] coeff
);

	wire [26:0] sub_wire0;
	assign coeff = sub_wire0[26:0];

	altsyncram	altsyncram_component (
				.address_a (address),
				.clock0 (clock),
				.q_a (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_a ({27{1'b1}}),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_a (1'b0),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_a = "NONE",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.intended_device_family = "Cyclone V",
		altsyncram_component.init_file = filename,
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = depth,
		altsyncram_component.operation_mode = "ROM",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.widthad_a = $clog2(depth),
		altsyncram_component.width_a = width,
		altsyncram_component.width_byteena_a = 1;

endmodule
