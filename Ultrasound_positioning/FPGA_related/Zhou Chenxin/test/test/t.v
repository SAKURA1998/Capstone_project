`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:09:56 12/20/2018
// Design Name:   test
// Module Name:   C:/Users/SJTU/Desktop/Zhou Chenixn/test/test/t.v
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

module t;

	// Inputs
	reg clk;
	reg reset;

	// Outputs
	wire clk_out;
	wire sync_out;
	wire din;
	wire led;
	wire clk_led;
	wire c_led;

	// Instantiate the Unit Under Test (UUT)
	test uut (
		.clk(clk), 
		.clk_out(clk_out), 
		.sync_out(sync_out), 
		.din(din), 
		.reset(reset), 
		.led(led), 
		.clk_led(clk_led), 
		.c_led(c_led)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
    always
	begin
		#50 clk = ~clk;
	end    
endmodule

