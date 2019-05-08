`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:46:57 12/20/2018
// Design Name:   main
// Module Name:   C:/Users/SJTU/Desktop/Zhou Chenixn/test_dac/dac/t_m.v
// Project Name:  dac
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: main
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module t_m;

	// Inputs
	reg clk;

	// Outputs
	wire din;
	wire sync;
	wire clk_out;

	// Instantiate the Unit Under Test (UUT)
	main uut (
		.clk(clk), 
		.din(din), 
		.sync(sync), 
		.clk_out(clk_out)
	);

	initial begin
		// Initialize Inputs
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
   always
		begin
		#50 clk = ~clk;
		end   
endmodule

