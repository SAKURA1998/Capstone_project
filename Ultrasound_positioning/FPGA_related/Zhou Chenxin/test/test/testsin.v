`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:44:39 12/19/2018
// Design Name:   sin
// Module Name:   C:/Users/SJTU/Desktop/Zhou Chenixn/test/test/testsin.v
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

module testsin;

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
		phase_in = 16'hd980;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
    always
	begin
		#50 clk = ~clk;
	end
		always @(posedge clk)
begin
	if(phase_in == 16'h 1940)
		phase_in <= 16'hd980;
	else
		phase_in <= phase_in + 16'h00c0;
end
endmodule

