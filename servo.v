`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/19 19:55:44
// Design Name: 
// Module Name: servo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module servo(
input                   clk_1m,
input                   rst_n,
input           wire [31:0] angle_num,
output           reg       angle_sig

    );
reg [31:0] pwm_cnt;    
    always@(posedge clk_1m or negedge rst_n)begin
    if(!rst_n)
        pwm_cnt <= 32'd0;
        else  if(pwm_cnt == 32'd19_999) pwm_cnt <= 32'd0;
        else pwm_cnt <= pwm_cnt + 1'b1;
        end
        

    always@(posedge clk_1m or negedge rst_n)begin
    if(!rst_n)
       angle_sig <= 1'b0;
        else if(pwm_cnt == 0) angle_sig <= 1'b1;
        else if(pwm_cnt == angle_num)angle_sig <= 1'b0;
        end
endmodule
