`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:17:42 09/26/2018 
// Design Name: 
// Module Name:    test 
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

module send(clk,header,load,sync,sin_out, din,reset,led);
input [7 : 0] header;
output sync,din,led;
input [15 : 0] sin_out;
input clk,reset;
input load;
reg [23 : 0] outsequence = 24'b0;
reg [4:0] count = 5'b0;
always @(posedge clk or posedge load or posedge reset)
begin
if(reset)
begin
	outsequence <= 24'b0;
	count <= 5'b0;
end
else 
begin
	if(load)
	begin
		if(sync)
		begin
			#1 outsequence <= {header,sin_out};
		end
		else
		begin
			outsequence <= outsequence<<1;
		end
		count <= count + 1'b1;
		if(count == 5'b11000)
			count <= 5'b0;
	end
	else if(!sync)
	begin
		outsequence <= outsequence<<1;
		count <= count + 1'b1;
		if(count == 5'b11000)
			count <= 5'b0;
	end
	else
		outsequence <= outsequence;
end
end


assign din = outsequence[23];
assign sync = (count == 5'b0)?1:0;
assign led = reset;
endmodule

module test(
clk, clk_out, sync_out, din, reset,led,clk_led,c_led
    );
input clk,reset;
reg [15 : 0] phase_in = 16'hd980;
reg [7 : 0] header = 8'b00010110;
wire [15 : 0]sin_out = 16'b1111111111111111;
wire load = 0;
reg clk_divider = 0;
reg clk_10 = 0;
reg [3:0]counter = 4'b0;
reg [6:0]counter1 = 7'b0;
output din;
output clk_out, sync_out;
output led,clk_led,c_led;

//sin s(clk_divider, sin_out, phase_in);
send se(clk_10, header, clk_divider, sync_out, sin_out, din,reset,led);
always @(posedge clk_divider or posedge reset)
begin
	/*if(reset) phase_in <= 16'hd980;
	else begin
	if(phase_in == 16'h 1940)
		phase_in <= 16'hd980;
	else
		phase_in <= phase_in + 16'h00c0;
	end*/
	//load <= ~load;
	//#10 load = 0;
end

always@(posedge clk)
begin
	counter1 <= counter1 + 1;
	if(counter1 == 7'b1100100)
	begin
		clk_10 <= ~clk_10;
		counter1 <= 7'b0;
	end
end

always@(posedge clk_10)
begin
	counter <= counter + 1;
	if(counter == 4'b1100)
	begin
		clk_divider <= ~clk_divider;
		counter <= 4'b0;
	end
end
//assign load = clk_divider;
assign clk_out = clk_10;
assign clk_led = sync_out;
assign c_led = clk_divider;
endmodule
