`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:25:33 12/19/2018
// Design Name:   send
// Module Name:   C:/Users/SJTU/Desktop/Zhou Chenixn/test/test/testsend.v
// Project Name:  test
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: send
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testsend;

	// Inputs
	reg clk;
	reg [7:0] header;
	reg load;
	reg [15:0] sin_out;

	// Outputs
	wire sync;
	wire din;

	// Instantiate the Unit Under Test (UUT)
	send uut (
		.clk(clk), 
		.header(header), 
		.load(load), 
		.sync(sync), 
		.sin_out(sin_out), 
		.din(din)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		header = 8'b00010110;
		load = 0;
		sin_out = 0;

		// Wait 100 ns for global reset to finish
		#100;
		sin_out = 16'b1010101010101010;
      #20 load = 1;
		#1 load = 0;
		// Add stimulus here

	end
   always
	begin
		#50 clk = ~clk;
	end    
endmodule

