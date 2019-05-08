`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:08:24 01/16/2019
// Design Name:   main
// Module Name:   C:/Users/SJTU/Desktop/Zhou Chenxin/test_dac/dac_multipath_final/ttt.v
// Project Name:  dac_multipath_final
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

module ttt;

	// Inputs
	reg clk;

	// Outputs
	wire din;
	wire sync;
	wire clk_out;
	wire vdd1;
	wire vdd2;
	wire clk_out_1;
	wire sync_1;
	wire din_1;

	// Instantiate the Unit Under Test (UUT)
	main uut (
		.clk(clk), 
		.din(din), 
		.sync(sync), 
		.clk_out(clk_out), 
		.vdd1(vdd1), 
		.vdd2(vdd2), 
		.clk_out_1(clk_out_1), 
		.sync_1(sync_1), 
		.din_1(din_1)
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

