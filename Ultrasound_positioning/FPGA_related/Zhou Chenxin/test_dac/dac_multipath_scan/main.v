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


always@(posedge clk) //divide 200MHz clk
begin
	inner_clk_counter <= inner_clk_counter + 1;
	if(inner_clk_counter == 5)
	begin
		inner_clk <= ~inner_clk;
		inner_clk_counter <= 0;
	end
end


always@(posedge inner_clk)// trigger clock for each channel to write
begin
	clk_counter <= clk_counter + 1;
	if(clk_counter == 12)
	begin
		trigger <= ~trigger;
		clk_counter <= 0;
	end
end


dac d3(inner_clk,sync,din,clk_out,trigger);

assign vdd1 = 1;//output high voltage
assign vdd2 = 1;
endmodule
