`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:22:04 12/20/2018 
// Design Name: 
// Module Name:    dac 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module dac(clk,sync,din,clk_out,trigger
    );
input clk,trigger;
//input [15:0] value;
output sync,din,clk_out;
//reg [15:0] clk_counter = 16'b0;
reg[15:0] value[0:63];
reg [7:0] header = 8'b0;
reg [7:0] header3 = 8'b00010110;
reg [7:0] header2 = 8'b00010100;
reg [7:0] header1 = 8'b00010010;
reg [7:0] header0 = 8'b00010000;
reg [7:0] counter = 8'b0; // counter for the index of digit to output
reg [15:0] scan_counter = 16'b0;
reg trigger_buf;
reg [16:0] index = 8'b0;
integer header_i;
integer i,j,k,l; // index for different channels.
integer diff;
initial
begin
header_i = 0;
diff = 0;
i = 0 + 0;
j = 4 + diff;
k = 1 + 2*diff;
l = 49 + 3*diff;
value[0] = 16'h8000;
value[1] = 16'h8c8b;
value[2] = 16'h98f8;
value[3] = 16'ha527;
value[4] = 16'hb0fb;
value[5] = 16'hbc56;
value[6] = 16'hc71c;
value[7] = 16'hd133;
value[8] = 16'hda82;
value[9] = 16'he2f1;
value[10] = 16'hea6d;
value[11] = 16'hf0e2;
value[12] = 16'hf641;
value[13] = 16'hfa7c;
value[14] = 16'hfd89;
value[15] = 16'hff61;
value[16] = 16'hffff;
value[17] = 16'hff61;
value[18] = 16'hfd89;
value[19] = 16'hfa7c;
value[20] = 16'hf641;
value[21] = 16'hf0e2;
value[22] = 16'hea6d;
value[23] = 16'he2f1;
value[24] = 16'hda82;
value[25] = 16'hd133;
value[26] = 16'hc71c;
value[27] = 16'hbc56;
value[28] = 16'hb0fb;
value[29] = 16'ha527;
value[30] = 16'h98f8;
value[31] = 16'h8c8b;
value[32] = 16'h8000;
value[33] = 16'h7374;
value[34] = 16'h6707;
value[35] = 16'h5ad8;
value[36] = 16'h4f04;
value[37] = 16'h43a9;
value[38] = 16'h38e3;
value[39] = 16'h2ecc;
value[40] = 16'h257d;
value[41] = 16'h1d0e;
value[42] = 16'h1592;
value[43] = 16'hf1d;
value[44] = 16'h9be;
value[45] = 16'h583;
value[46] = 16'h276;
value[47] = 16'h9e;
value[48] = 16'h0;
value[49] = 16'h9e;
value[50] = 16'h276;
value[51] = 16'h583;
value[52] = 16'h9be;
value[53] = 16'hf1d;
value[54] = 16'h1592;
value[55] = 16'h1d0e;
value[56] = 16'h257d;
value[57] = 16'h2ecc;
value[58] = 16'h38e3;
value[59] = 16'h43a9;
value[60] = 16'h4f04;
value[61] = 16'h5ad8;
value[62] = 16'h6707;
value[63] = 16'h7374;	
end

always@(posedge clk)
begin
	trigger_buf <= trigger;// use trigger to shift channel by changing header index
	if(trigger == 1 && trigger_buf == 0) // posedge trigger
	begin
		counter <= 0;
		scan_counter <= scan_counter + 1;
		if(scan_counter >= 256)  // the scan counter
		begin
			diff <= diff + 1;
			if(diff >= 30)
				diff <= 0;
			j <= j + diff;
			k <= k + diff + diff;
			l <= l + diff + diff + diff;
			scan_counter <= 0;
		end
		header_i <= header_i + 1;
		if(header_i >= 3)
			header_i <= 0;
		if(header_i == 0) i <= i + 16;
		if(i >= 64)
			i <= i-64;
		if(header_i == 1) j <= j + 16;
		if(j >= 64)
			j <= j-64;
		if(header_i == 2) k <= k + 16;
		if(k >= 64)
			k <= k-64;
		if(header_i == 3) l <= l + 16;
		if(l >= 64)
			l <= l-64;
	end
	else
		counter <= counter + 1;
end


always@(*)// assign header number cooresponding to different channels
begin
	case (header_i)
		0: header <= header0;
		1: header <= header1;
		2: header <= header2;
		3: header <= header3;
		default: header <=8'b0;
	endcase
end

always@(*)//assign index of different channel to output different value
begin
	case (header_i)
		0: index <= i;
		1: index <= j;
		2: index <= k;
		3: index <= l;
		default: index <= 8'b0;
	endcase
end

assign din = (counter >= 24)?1:((counter > 7)?value[index][23-counter]:header[7-counter]); // din is the output digit. 
assign clk_out = clk;
assign sync = (counter <= 23)?0:1; // when sync is 0, start to output

endmodule
