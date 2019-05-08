`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:06:03 10/06/2018
// Design Name:   sin
// Module Name:   C:/Users/SJTU/Desktop/test/test/tt.v
// Project Name:  test
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: sin
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tt;

	// Inputs
	reg clk;
	reg [15:0] phase_in;

	// Outputs
	wire [15:0] x_out;

	// Instantiate the Unit Under Test (UUT)
	sin uut (
		.clk(clk), 
		.x_out(x_out), 
		.phase_in(phase_in)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		phase_in = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

