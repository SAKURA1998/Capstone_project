`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:31:32 09/26/2018
// Design Name:   test
// Module Name:   C:/Users/Administrator/Desktop/lab/test/test1.v
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

module test1;

	// Inputs
	reg clk;

	// Outputs

	wire sin_out;
	wire sync_out;
	wire din;
	// Instantiate the Unit Under Test (UUT)
	test uut (
		.clk(clk), 
		.clk_out(clk_out),
		.sync_out(sync_out),
		.din(din)
	);

	initial begin
		// Initialize Inputs
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
  

	
endmodule

