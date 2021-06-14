`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/18 17:16:45
// Design Name: 
// Module Name: CLK_1M
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


module CLK_1M(
output reg clk_1m,
input  clk_100m,
input  rst_n

    );
    reg [31:0] pwm_cnt ;
    always@(posedge clk_100m or negedge rst_n)begin
    if(!rst_n)
        begin 
        
        pwm_cnt <= 32'd0;
        end
        else  if(pwm_cnt == 32'd99) begin pwm_cnt<=0;end
        else    pwm_cnt <= pwm_cnt + 1'b1;
        end 
       always@(posedge clk_100m or negedge rst_n)begin
    if(!rst_n)
        begin 
        clk_1m <= 1'b0;

        end
        else  if(pwm_cnt == 32'd0) clk_1m<= 1'b0;
        else   if(pwm_cnt == 32'd50)clk_1m <= 1'b1;
        end  
        
    
endmodule
