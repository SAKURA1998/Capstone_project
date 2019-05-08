`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:42:35 12/20/2018 
// Design Name: 
// Module Name:    main 
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
module main(clk,din,sync,clk_out,vdd1,vdd2
    );
input clk;
output clk_out,din,sync,vdd1,vdd2;
reg[15:0] value[0:63];// = 16'b1111111111111111;
reg trigger = 0;
reg inner_clk = 0;
reg [15:0] clk_counter = 16'b0;
reg [15:0] inner_clk_counter = 16'b0;

integer i,j,k,l;
/*initial
begin
i = 0;
j = 15;
k = 31;
l = 47;
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
end*/

always@(posedge clk)
begin
	inner_clk_counter <= inner_clk_counter + 1;
	if(inner_clk_counter == 5)
	begin
		inner_clk <= ~inner_clk;
		inner_clk_counter <= 0;
	end
end


always@(posedge inner_clk)
begin
	clk_counter <= clk_counter + 1;
	if(clk_counter == 12)
	begin
		trigger <= ~trigger;
		clk_counter <= 0;
	end
end

/*always@(posedge trigger)
begin
	i <= i + 7;
	if(i >= 63)
		i <= 0;
	j <= j + 7;
	if(j >= 63)
		j <= 0;
	k <= k + 7;
	if(k >= 63)
		k <= 0;
	l <= l + 7;
	if(l >= 63)
		l <= 0;
end*/

dac d3(inner_clk,sync,din,clk_out,trigger);

assign vdd1 = 1;
assign vdd2 = 1;
endmodule
