`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:34:44 01/10/2019 
// Design Name: 
// Module Name:    uart_tx 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
 
// 系统时钟200MHz，波特率115200，带忙闲指示信号rdy
module uart_tx #(
    parameter BAUDRATE = 115200, 
    parameter FREQ = 200_000_000)(
    input clk, nrst,
    input wrreq,
    input [7:0] wdata,
    output reg tx,
    output reg rdy
    );
    wire end_cnt_clk;
    wire end_cnt_bit;
	 
    reg [3:0] cnt_bit;
    reg [31:0] cnt_clk;
    
    localparam T = FREQ / BAUDRATE;
 
    // 有写请求时将rdy信号拉底，待到数据发送完毕再将信号拉
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            rdy <= 1;
        else if(wrreq)
            rdy <= 0;
        else if(end_cnt_bit)
            rdy <= 1;
    end
    
    // 两层计数结构，cnt_clk计数每一位所占的时钟数，cnt_bit计数1个开始位，8个数据位，一个停止位，共10位
    
    assign end_cnt_clk = cnt_clk == T - 1;
    assign end_cnt_bit = end_cnt_clk && cnt_bit == 10 - 1;
    
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            cnt_clk <= 0;
        else if(rdy == 0) begin
            if(end_cnt_clk)
                cnt_clk <= 0;
            else
                cnt_clk <= cnt_clk + 1'b1;
        end
    end
    
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            cnt_bit <= 0;
        else if(end_cnt_clk) begin
            if(end_cnt_bit)
                cnt_bit <= 0;
            else
                cnt_bit <= cnt_bit + 1'b1;
        end
    end
    
    // 先发送一个起始位0，然后8位数据位，最后是停止位1
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            tx <= 1;
        else if(rdy == 0 && cnt_clk == 0) begin
            if(cnt_bit == 1 - 1)
                tx <= 0;
            else if(cnt_bit == 10 - 1)
                tx <= 1;
            else
                tx <= wdata[cnt_bit - 1];
        end
    end
    
endmodule
