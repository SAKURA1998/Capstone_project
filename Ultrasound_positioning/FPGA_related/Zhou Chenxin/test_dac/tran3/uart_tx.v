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
 
// ϵͳʱ��200MHz��������115200����æ��ָʾ�ź�rdy
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
 
    // ��д����ʱ��rdy�ź����ף��������ݷ�������ٽ��ź���
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            rdy <= 1;
        else if(wrreq)
            rdy <= 0;
        else if(end_cnt_bit)
            rdy <= 1;
    end
    
    // ��������ṹ��cnt_clk����ÿһλ��ռ��ʱ������cnt_bit����1����ʼλ��8������λ��һ��ֹͣλ����10λ
    
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
    
    // �ȷ���һ����ʼλ0��Ȼ��8λ����λ�������ֹͣλ1
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
