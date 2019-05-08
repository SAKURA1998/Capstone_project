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
module dac(clk,sync,din,clk_out,header,value,trigger
    );
input clk,trigger;
input [15:0] value;
input [7:0] header;
output sync,din,clk_out;
//reg [15:0] clk_counter = 16'b0;
//reg [7:0] header = 8'b00010110;
reg [7:0] counter = 8'b0;
reg trigger_buf;

/*always@(posedge clk)
begin
	clk_counter <= clk_counter + 1;
	if(clk_counter == 200)
	begin
		inner_clk <= ~inner_clk;
		clk_counter <= 0;
	end
end*/

always@(posedge clk)
begin
	trigger_buf <= trigger;
	if(trigger == 1 && trigger_buf == 0)
	begin
		counter <= 0;
	end
	else
		counter <= counter + 1;
end


assign din = (counter >= 24)?1:((counter > 7)?value[23-counter]:header[7-counter]);
assign clk_out = clk;
assign sync = (counter <= 23)?0:1;
endmodule
