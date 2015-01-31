//  All the information for a single polyphase component

module compfir(
	input clock,
	input in_strobe,
	input signed [23:0] in_data,
	output logic signed [23:0] out_data,
	output logic out_strobe
);

parameter ORDER = 254;  // This is always even
parameter COMPONENTS = 2;
parameter BASENAME = "compfir_p";
parameter COEFF_WIDTH = 27;
parameter SAMPLE_WIDTH = 24;

localparam TAPS = ORDER + 1;

reg signed [52:0] accum = 0;
wire [23:0] test_data = accum[52-:24];

logic signed [23:0] in_data_reg;

function logic [COMPONENTS-1:0] [31:0]  get_taps (int increment);
	logic [COMPONENTS-1:0] [31:0]  comptaps;
	
	automatic int tapsleft = TAPS;
	
	for(int i = 0; i < COMPONENTS; ++i, tapsleft -= increment)
		comptaps[i] = increment > tapsleft ? tapsleft : increment;
		
	return comptaps;
endfunction

localparam [COMPONENTS-1:0][31:0] COMPONENT_TAPS = get_taps($ceil(TAPS / real'(COMPONENTS)));

typedef struct {
	logic do_write = 0;
	logic [$clog2(COMPONENT_TAPS[0] / 2)-1:0] coeff_addr = 0;
	logic [$clog2(COMPONENT_TAPS[0])-1:0] samplea_addr = 1;
	logic [$clog2(COMPONENT_TAPS[0])-1:0] sampleb_addr = 0;
	logic [$clog2(COMPONENT_TAPS[0])-1:0] write_addr = 0;
} phase_inputs;

typedef struct {
	logic signed [SAMPLE_WIDTH-1:0] samplea;
	logic signed [SAMPLE_WIDTH-1:0] sampleb;
	logic signed [COEFF_WIDTH-1:0] coeff;
} phase_outputs;

phase_inputs phase[COMPONENTS];
phase_outputs phase_out[COMPONENTS];

genvar i;
generate
for(i = 0; i < COMPONENTS; ++i) begin: storage
	compfir_rom #(.filename ({ BASENAME, i + 48, ".mif" }), .depth(COMPONENT_TAPS[0] / 2), .width(COEFF_WIDTH)) coeffs (
		.clock (clock),
		.address (phase[i].coeff_addr),
		.coeff (phase_out[i].coeff)
	);
	
	compfir_ram #(.depth (COMPONENT_TAPS[i]), .width (SAMPLE_WIDTH)) samples (
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

// XXX These may not be able to take integers when synthesized.
task reset_addr(input int phs);
	phase[phs].write_addr <= phase[phs].write_addr == COMPONENT_TAPS[phs] - 1'd1 ? 0 : phase[phs].write_addr + 1'd1;
	phase[phs].samplea_addr <= phase[phs].write_addr == COMPONENT_TAPS[phs] - 2'd2 ? 0 : phase[phs].write_addr + 2'd2;
	phase[phs].sampleb_addr <= phase[phs].write_addr == COMPONENT_TAPS[phs] - 1'd1 ? 0 : phase[phs].write_addr + 1'd1;

	phase[phs].coeff_addr <= 0;
endtask

task advance_addr(input int phs);
	phase[phs].coeff_addr <= phase[phs].coeff_addr + 1'd1;
	
	phase[phs].samplea_addr <= phase[phs].samplea_addr == COMPONENT_TAPS[phs] - 1'd1 ? 0 : phase[phs].samplea_addr + 1'd1;
	phase[phs].sampleb_addr <= phase[phs].sampleb_addr == 0 ? COMPONENT_TAPS[phs] - 1'd1 : phase[phs].sampleb_addr - 1'd1;
endtask

enum logic [3:0] {
	IDLE_P1 = 0,
	WRITE_P1 = 1,
	WAIT1_P1 = 2,
	WAIT2_P1 = 3,
	CALC_P1 = 4,
	IDLE_P2 = 5,
	WRITE_P2 = 6,
	WAIT1_P2 = 7,
	WAIT2_P2 = 8,
	CALC_P2 = 9,
	CLKOUT = 10 
} state = IDLE_P1;

int counter = 0;

always @(posedge clock) begin
	out_strobe <= 1'b0;
	
	for(int j = 0; j < COMPONENTS; ++j)
		phase[j].do_write <= 1'b0;

	case(state)
		IDLE_P1: begin
			if(in_strobe == 1) begin
				phase[0].do_write <= 1'b1;
				in_data_reg <= in_data;
				reset_addr(0);
				state <= WRITE_P1;
			end
		end
		WRITE_P1: begin
			phase[0].do_write <= 0;
			state <= WAIT1_P1;
		end
		WAIT1_P1: begin
			advance_addr(0);
			state <= WAIT2_P1;
		end
		WAIT2_P1: begin
			advance_addr(0);
			state <= CALC_P1;
		end
		CALC_P1: begin
			if(phase[0].coeff_addr == $size(phase[0].coeff_addr)'($ceil(COMPONENT_TAPS[0] / 2.0)) + 1'd1)
				state <= IDLE_P2;
				
			advance_addr(0);
			accum <= ((phase_out[0].samplea + phase_out[0].sampleb) * phase_out[0].coeff) + accum;
		end
		IDLE_P2: begin
			if(in_strobe == 1) begin
				phase[1].do_write <= 1'b1;
				in_data_reg <= in_data;
				reset_addr(1);
				state <= WRITE_P2;
			end
		end
		WRITE_P2: begin
			phase[1].do_write <= 0;
			state <= WAIT1_P2;
		end
		WAIT1_P2: begin
			advance_addr(1);
			state <= WAIT2_P2;
		end
		WAIT2_P2: begin
			advance_addr(1);
			state <= CALC_P2;
		end
		CALC_P2: begin
			if(phase[1].coeff_addr == $size(phase[1].coeff_addr)'($ceil(COMPONENT_TAPS[1] / 2.0)) + 1'd1)
				state <= CLKOUT;
			
			//  XXX These probably need to wrap
			if(phase[1].samplea_addr - 1'd1 == phase[1].sampleb_addr + 1'd1)
				accum <= (phase_out[1].samplea * phase_out[1].coeff) + accum;
			else
				accum <= ((phase_out[1].samplea + phase_out[1].sampleb) * phase_out[1].coeff) + accum;
			
			advance_addr(1);
		end
		CLKOUT: begin
			out_strobe <= 1'b1;
			out_data <= accum[46-:24] + accum[46 - 24];
			accum <= 0;
			state <= IDLE_P1;
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

	//parameter depth = 128;

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
