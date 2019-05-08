`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:12:59 12/21/2018
// Design Name:   main
// Module Name:   C:/Users/SJTU/Desktop/Zhou Chenxin/test_dac/dac_multipath/t.v
// Project Name:  dac_multipath
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

module t;

	// Inputs
	reg clk;

	// Outputs
	wire din;
	wire sync;
	wire clk_out;
	wire vdd1;
	wire vdd2;

	// Instantiate the Unit Under Test (UUT)
	main uut (
		.clk(clk), 
		.din(din), 
		.sync(sync), 
		.clk_out(clk_out), 
		.vdd1(vdd1), 
		.vdd2(vdd2)
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

