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

module varcic(decimation, clock, in_strobe,  out_strobe, in_data, out_data );

  //design parameters
  parameter STAGES = 5;
  parameter MAX_DECIMATION = 40;
  parameter IN_WIDTH = 18;
  parameter OUT_WIDTH = 18;

  // derived parameters
  parameter ACC_WIDTH = STAGES * $clog2(MAX_DECIMATION);
  
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


always @(posedge clock)
  if (in_strobe)
    begin
    if (sample_no == (decimation - 1))
      begin
      sample_no <= 0;
      out_strobe <= 1;
      end
    else
      begin
      sample_no <= sample_no + 8'd1;
      out_strobe <= 0;
      end
    end

  else
    out_strobe <= 0;


//------------------------------------------------------------------------------
//                                stages
//------------------------------------------------------------------------------
wire signed [ACC_WIDTH-1:0] integrator_data [0:STAGES];
wire signed [ACC_WIDTH-1:0] comb_data [0:STAGES];


assign integrator_data[0] = in_data;
assign comb_data[0] = integrator_data[STAGES];


genvar i;
generate
  for (i=0; i<STAGES; i=i+1)
    begin : cic_stages

    cic_integrator #(ACC_WIDTH) cic_integrator_inst(
      .clock(clock),
      .strobe(in_strobe),
      .in_data(integrator_data[i]),
      .out_data(integrator_data[i+1])
      );


    cic_comb #(ACC_WIDTH) cic_comb_inst(
      .clock(clock),
      .strobe(out_strobe),
      .in_data(comb_data[i]),
      .out_data(comb_data[i+1])
      );
    end
endgenerate


//------------------------------------------------------------------------------
//                            output rounding
//------------------------------------------------------------------------------

//
//  Generate a table of msb offsets for each decimation value from 1 to
//  MAX_DECIMATION
//
wire [$clog2(ACC_WIDTH):0] msb [MAX_DECIMATION + 1];
genvar j;
generate
	for(j = 1; j < MAX_DECIMATION + 1; j = j + 1) begin: round_position
		assign msb[j] = IN_WIDTH + ($clog2(j) * STAGES) - 1 ;
	end
endgenerate

//  Round values
always @(posedge clock) begin
	out_data <= comb_data[STAGES][msb[decimation] -: OUT_WIDTH] + comb_data[STAGES][msb[decimation] - OUT_WIDTH];
end

endmodule
