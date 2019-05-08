`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:23:23 12/19/2018
// Design Name:   test
// Module Name:   C:/Users/SJTU/Desktop/Zhou Chenixn/test/test/test2.v
// Project Name:  test
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: test
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test2;

	// Inputs
	reg clk;
	reg reset;
	// Outputs
	wire clk_out;
	wire sync_out;
	wire din;
	// Instantiate the Unit Under Test (UUT)
	test uut (
		.clk(clk), 
		.clk_out(clk_out), 
		.sync_out(sync_out), 
		.din(din),
		.reset(reset)
	);

	initial begin
		// Initialize Inputs
		clk = 0;

		// Wait 100 ns for global reset to finish
		#200;
      reset = 1;
		#1 reset = 0;
		// Add stimulus here

	end
    always
	begin
		#50 clk = ~clk;
	end   
endmodule

