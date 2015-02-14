//
// cic - A Cascaded Integrator-Comb filter
//
// Copyright (c) 2008 Alex Shovkoplyas, VE3NEA
// Copyright (c) 2013 Phil Harman, VK6PH
// Copyright (c) 2015 Jeremy McDermond, NH6Z
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Library General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later version.
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
// You should have received a copy of the GNU Library General Public
// License along with this library; if not, write to the
// Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
// Boston, MA  02110-1301, USA.


// 2013 Jan 26	- Modified to accept decimation values from 1-40. VK6APH 

module cic(decimation, clock, in_strobe,  out_strobe, in_data, out_data );

  //design parameters
  parameter STAGES = 5; //  Sections of both Comb and Integrate
  parameter MIN_DECIMATION = 2;  // If MIN = MAX, we are single-rate filter
  parameter MAX_DECIMATION = 40;
  parameter IN_WIDTH = 18;
  parameter OUT_WIDTH = 18;

  // derived parameters
  //parameter ACC_WIDTH = IN_WIDTH + (STAGES * $clog2(MAX_DECIMATION));
  parameter ACC_WIDTH = IN_WIDTH + get_bit_growth(MAX_DECIMATION, STAGES);
//localparam FOO = get_bit_growth(MAX_DECIMATION, STAGES) + IN_WIDTH;
   
  input [$clog2(MAX_DECIMATION) - 1:0] decimation; 
  
  input clock;
  input in_strobe;
  output reg out_strobe;

  input signed [IN_WIDTH-1:0] in_data;
  output signed [OUT_WIDTH-1:0] out_data;


//------------------------------------------------------------------------------
//                               control
//------------------------------------------------------------------------------
reg [$clog2(MAX_DECIMATION)-1:0] sample_no = 0;

generate
if(MIN_DECIMATION == MAX_DECIMATION)
	always @(posedge clock)
		if (in_strobe) 
			if (sample_no == (MAX_DECIMATION - 1'd1)) begin
				sample_no <= 0;
				out_strobe <= 1;
			end else begin
				sample_no <= sample_no + 1'd1;
     				out_strobe <= 0;
			end
		else
			out_strobe <= 0;
else
	always @(posedge clock)
		if (in_strobe) 
			if (sample_no == (decimation - 1'd1)) begin
				sample_no <= 0;
				out_strobe <= 1;
			end else begin
				sample_no <= sample_no + 1'd1;
     				out_strobe <= 0;
			end
		else
			out_strobe <= 0;
endgenerate

//------------------------------------------------------------------------------
//                                stages
//------------------------------------------------------------------------------
reg signed [ACC_WIDTH-1:0] integrator_data [1:STAGES] = '{default: '0};
reg signed [ACC_WIDTH-1:0] comb_data [1:STAGES] = '{default: '0};
reg signed [ACC_WIDTH-1:0] comb_last [0:STAGES] = '{default: '0};

always @(posedge clock) begin
	integer index;

	//  Integrators
	if(in_strobe) begin
		integrator_data[1] <= integrator_data[1] + in_data;
		for(index = 1; index < STAGES; index = index + 1) begin
			integrator_data[index + 1] <= integrator_data[index] + integrator_data[index+1];
		end
	end

	// Combs
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

genvar i;
generate
	if(MIN_DECIMATION == MAX_DECIMATION) begin
		assign out_data = comb_data[STAGES][ACC_WIDTH - 1 -: OUT_WIDTH] + comb_data[STAGES][ACC_WIDTH - OUT_WIDTH - 1];
	end else begin
		wire [$clog2(ACC_WIDTH)-1:0] msb [MAX_DECIMATION:MIN_DECIMATION];
		for(i = MIN_DECIMATION; i <= MAX_DECIMATION; i = i + 1) begin: round_position
			//assign msb[i] = IN_WIDTH + ($clog2(i) * STAGES) - 1 ;
			assign msb[i] = IN_WIDTH + get_bit_growth(i, STAGES) - 1;
		end

		assign out_data = comb_data[STAGES][msb[decimation] -: OUT_WIDTH] + comb_data[STAGES][msb[decimation] - OUT_WIDTH];
	end
endgenerate

function integer get_bit_growth;
	input integer decimation;
	input integer stages;
	integer log2 [254:1];
	integer truncated_answer;
	integer expanded_answer;
	begin
		log2[1] = 0;
		log2[2] = 1000000;
		log2[3] = 1584962;
		log2[4] = 2000000;
		log2[5] = 2321928;
		log2[6] = 2584962;
		log2[7] = 2807354;
		log2[8] = 3000000;
		log2[9] = 3169925;
		log2[10] = 3321928;
		log2[11] = 3459431;
		log2[12] = 3584962;
		log2[13] = 3700439;
		log2[14] = 3807354;
		log2[15] = 3906890;
		log2[16] = 4000000;
		log2[17] = 4087462;
		log2[18] = 4169925;
		log2[19] = 4247927;
		log2[20] = 4321928;
		log2[21] = 4392317;
		log2[22] = 4459431;
		log2[23] = 4523561;
		log2[24] = 4584962;
		log2[25] = 4643856;
		log2[26] = 4700439;
		log2[27] = 4754887;
		log2[28] = 4807354;
		log2[29] = 4857980;
		log2[30] = 4906890;
		log2[31] = 4954196;
		log2[32] = 5000000;
		log2[33] = 5044394;
		log2[34] = 5087462;
		log2[35] = 5129283;
		log2[36] = 5169925;
		log2[37] = 5209453;
		log2[38] = 5247927;
		log2[39] = 5285402;
		log2[40] = 5321928;
		log2[41] = 5357552;
		log2[42] = 5392317;
		log2[43] = 5426264;
		log2[44] = 5459431;
		log2[45] = 5491853;
		log2[46] = 5523561;
		log2[47] = 5554588;
		log2[48] = 5584962;
		log2[49] = 5614709;
		log2[50] = 5643856;
		log2[51] = 5672425;
		log2[52] = 5700439;
		log2[53] = 5727920;
		log2[54] = 5754887;
		log2[55] = 5781359;
		log2[56] = 5807354;
		log2[57] = 5832890;
		log2[58] = 5857980;
		log2[59] = 5882643;
		log2[60] = 5906890;
		log2[61] = 5930737;
		log2[62] = 5954196;
		log2[63] = 5977279;
		log2[64] = 6000000;
		log2[65] = 6022367;
		log2[66] = 6044394;
		log2[67] = 6066089;
		log2[68] = 6087462;
		log2[69] = 6108524;
		log2[70] = 6129283;
		log2[71] = 6149747;
		log2[72] = 6169925;
		log2[73] = 6189824;
		log2[74] = 6209453;
		log2[75] = 6228818;
		log2[76] = 6247927;
		log2[77] = 6266786;
		log2[78] = 6285402;
		log2[79] = 6303780;
		log2[80] = 6321928;
		log2[81] = 6339850;
		log2[82] = 6357552;
		log2[83] = 6375039;
		log2[84] = 6392317;
		log2[85] = 6409390;
		log2[86] = 6426264;
		log2[87] = 6442943;
		log2[88] = 6459431;
		log2[89] = 6475733;
		log2[90] = 6491853;
		log2[91] = 6507794;
		log2[92] = 6523561;
		log2[93] = 6539158;
		log2[94] = 6554588;
		log2[95] = 6569855;
		log2[96] = 6584962;
		log2[97] = 6599912;
		log2[98] = 6614709;
		log2[99] = 6629356;
		log2[100] = 6643856;
		log2[101] = 6658211;
		log2[102] = 6672425;
		log2[103] = 6686500;
		log2[104] = 6700439;
		log2[105] = 6714245;
		log2[106] = 6727920;
		log2[107] = 6741466;
		log2[108] = 6754887;
		log2[109] = 6768184;
		log2[110] = 6781359;
		log2[111] = 6794415;
		log2[112] = 6807354;
		log2[113] = 6820178;
		log2[114] = 6832890;
		log2[115] = 6845490;
		log2[116] = 6857980;
		log2[117] = 6870364;
		log2[118] = 6882643;
		log2[119] = 6894817;
		log2[120] = 6906890;
		log2[121] = 6918863;
		log2[122] = 6930737;
		log2[123] = 6942514;
		log2[124] = 6954196;
		log2[125] = 6965784;
		log2[126] = 6977279;
		log2[127] = 6988684;
		log2[128] = 7000000;
		log2[129] = 7011227;
		log2[130] = 7022367;
		log2[131] = 7033423;
		log2[132] = 7044394;
		log2[133] = 7055282;
		log2[134] = 7066089;
		log2[135] = 7076815;
		log2[136] = 7087462;
		log2[137] = 7098032;
		log2[138] = 7108524;
		log2[139] = 7118941;
		log2[140] = 7129283;
		log2[141] = 7139551;
		log2[142] = 7149747;
		log2[143] = 7159871;
		log2[144] = 7169925;
		log2[145] = 7179909;
		log2[146] = 7189824;
		log2[147] = 7199672;
		log2[148] = 7209453;
		log2[149] = 7219168;
		log2[150] = 7228818;
		log2[151] = 7238404;
		log2[152] = 7247927;
		log2[153] = 7257387;
		log2[154] = 7266786;
		log2[155] = 7276124;
		log2[156] = 7285402;
		log2[157] = 7294620;
		log2[158] = 7303780;
		log2[159] = 7312882;
		log2[160] = 7321928;
		log2[161] = 7330916;
		log2[162] = 7339850;
		log2[163] = 7348728;
		log2[164] = 7357552;
		log2[165] = 7366322;
		log2[166] = 7375039;
		log2[167] = 7383704;
		log2[168] = 7392317;
		log2[169] = 7400879;
		log2[170] = 7409390;
		log2[171] = 7417852;
		log2[172] = 7426264;
		log2[173] = 7434628;
		log2[174] = 7442943;
		log2[175] = 7451211;
		log2[176] = 7459431;
		log2[177] = 7467605;
		log2[178] = 7475733;
		log2[179] = 7483815;
		log2[180] = 7491853;
		log2[181] = 7499845;
		log2[182] = 7507794;
		log2[183] = 7515699;
		log2[184] = 7523561;
		log2[185] = 7531381;
		log2[186] = 7539158;
		log2[187] = 7546894;
		log2[188] = 7554588;
		log2[189] = 7562242;
		log2[190] = 7569855;
		log2[191] = 7577428;
		log2[192] = 7584962;
		log2[193] = 7592457;
		log2[194] = 7599912;
		log2[195] = 7607330;
		log2[196] = 7614709;
		log2[197] = 7622051;
		log2[198] = 7629356;
		log2[199] = 7636624;
		log2[200] = 7643856;
		log2[201] = 7651051;
		log2[202] = 7658211;
		log2[203] = 7665335;
		log2[204] = 7672425;
		log2[205] = 7679480;
		log2[206] = 7686500;
		log2[207] = 7693486;
		log2[208] = 7700439;
		log2[209] = 7707359;
		log2[210] = 7714245;
		log2[211] = 7721099;
		log2[212] = 7727920;
		log2[213] = 7734709;
		log2[214] = 7741466;
		log2[215] = 7748192;
		log2[216] = 7754887;
		log2[217] = 7761551;
		log2[218] = 7768184;
		log2[219] = 7774787;
		log2[220] = 7781359;
		log2[221] = 7787902;
		log2[222] = 7794415;
		log2[223] = 7800899;
		log2[224] = 7807354;
		log2[225] = 7813781;
		log2[226] = 7820178;
		log2[227] = 7826548;
		log2[228] = 7832890;
		log2[229] = 7839203;
		log2[230] = 7845490;
		log2[231] = 7851749;
		log2[232] = 7857980;
		log2[233] = 7864186;
		log2[234] = 7870364;
		log2[235] = 7876516;
		log2[236] = 7882643;
		log2[237] = 7888743;
		log2[238] = 7894817;
		log2[239] = 7900866;
		log2[240] = 7906890;
		log2[241] = 7912889;
		log2[242] = 7918863;
		log2[243] = 7924812;
		log2[244] = 7930737;
		log2[245] = 7936637;
		log2[246] = 7942514;
		log2[247] = 7948367;
		log2[248] = 7954196;
		log2[249] = 7960001;
		log2[250] = 7965784;
		log2[251] = 7971543;
		log2[252] = 7977279;
		log2[253] = 7982993;
		log2[254] = 7988684;
		
		expanded_answer = stages * log2[decimation];
		truncated_answer = expanded_answer / 1000000;
		get_bit_growth = (expanded_answer > truncated_answer * 1000000 ? truncated_answer + 1 : truncated_answer);
	end
endfunction

endmodule
