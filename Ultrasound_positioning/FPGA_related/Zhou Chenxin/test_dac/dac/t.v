`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:06:18 12/20/2018
// Design Name:   dac
// Module Name:   C:/Users/SJTU/Desktop/Zhou Chenixn/test_dac/dac/t.v
// Project Name:  dac
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dac
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
	reg trigger;
	reg [15:0] value;

	// Outputs
	wire sync;
	wire din;
	wire clk_out;

	// Instantiate the Unit Under Test (UUT)
	dac uut (
		.clk(clk), 
		.sync(sync), 
		.din(din), 
		.clk_out(clk_out), 
		.value(value),
		.trigger(trigger)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		trigger = 1;
		value = 16'b0101010101010101;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
   always
		begin
		#100 clk = ~clk;
		end
	always
		begin
		#4000 trigger = ~trigger;
		end
endmodule

