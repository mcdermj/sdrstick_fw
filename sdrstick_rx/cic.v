/*
--------------------------------------------------------------------------------
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.
You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the
Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
Boston, MA  02110-1301, USA.
--------------------------------------------------------------------------------
*/


//------------------------------------------------------------------------------
//           Copyright (c) 2008 Alex Shovkoplyas, VE3NEA
//           Copyright (c) 2015 Jeremy McDermond, NH6Z
//------------------------------------------------------------------------------

// 2013 Jan 26	- Modified to accept decimation values from 1-40. VK6APH 

module cic(decimation, clock, in_strobe,  out_strobe, in_data, out_data );

  //design parameters
  parameter STAGES = 5;
  parameter MIN_DECIMATION = 2;
  parameter MAX_DECIMATION = 40;
  parameter IN_WIDTH = 18;
  parameter OUT_WIDTH = 18;

  // derived parameters
  parameter ACC_WIDTH = IN_WIDTH + (STAGES * $clog2(MAX_DECIMATION));
  
  input [5:0] decimation; 
  
  input clock;
  input in_strobe;
  output reg out_strobe;

  input signed [IN_WIDTH-1:0] in_data;
  output reg signed [OUT_WIDTH-1:0] out_data;


//------------------------------------------------------------------------------
//                               control
//------------------------------------------------------------------------------
reg [15:0] sample_no;
initial sample_no = 16'd0;

task advance_sample_no;
input [5:0] decimation_factor;
begin
	if (sample_no == (decimation_factor - 1)) begin
		sample_no <= 0;
		out_strobe <= 1;
	end else begin
		sample_no <= sample_no + 8'd1;
      		out_strobe <= 0;
	end
end
endtask

generate
if(MIN_DECIMATION == MAX_DECIMATION) begin
	always @(posedge clock) begin
		if (in_strobe) 
			advance_sample_no(MAX_DECIMATION);
		else
			out_strobe <= 0;
	end
end else begin
	always @(posedge clock) begin
		if (in_strobe) 
			advance_sample_no(decimation);
		else
			out_strobe <= 0;
	end
end
endgenerate

//------------------------------------------------------------------------------
//                                stages
//------------------------------------------------------------------------------
reg signed [ACC_WIDTH-1:0] integrator_data [0:STAGES];
reg signed [ACC_WIDTH-1:0] comb_data [0:STAGES];
reg signed [ACC_WIDTH-1:0] comb_last [0:STAGES];

always @(posedge clock) begin
	integer index;

	//  Integrators
	if(in_strobe) begin
		integrator_data[1] <= integrator_data[1] + in_data;
		for(index = 1; index < STAGES; index = index + 1) begin
			integrator_data[index + 1] <= integrator_data[index] + integrator_data[index+1];
		end
	end

	if(out_strobe) begin
		comb_data[1] <= integrator_data[STAGES] - comb_last[0];
		comb_last[0] <= integrator_data[STAGES];
		for(index = 1; index < STAGES; index = index + 1) begin
			comb_data[index + 1] <= comb_data[index] - comb_last[index];
			comb_last[index] <= comb_data[index]; 
		end
	end
end

//------------------------------------------------------------------------------
//                            output rounding
//------------------------------------------------------------------------------

//XXX  Can we use assigns here for the output?

genvar j;
generate
	if(MIN_DECIMATION == MAX_DECIMATION) begin
		always @(posedge clock) begin
			out_data <= comb_data[STAGES][ACC_WIDTH - 1 -: OUT_WIDTH] + comb_data[STAGES][ACC_WIDTH - OUT_WIDTH - 1];
		end
	end else begin
		wire [$clog2(ACC_WIDTH):0] msb [MAX_DECIMATION + 1];
		for(j = MIN_DECIMATION; j < MAX_DECIMATION + 1; j = j + 1) begin: round_position
			assign msb[j] = IN_WIDTH + ($clog2(j) * STAGES) - 1 ;
		end

		//  Round values
		always @(posedge clock) begin
			out_data <= comb_data[STAGES][msb[decimation] -: OUT_WIDTH] + comb_data[STAGES][msb[decimation] - OUT_WIDTH];
		end
	end
endgenerate

endmodule
