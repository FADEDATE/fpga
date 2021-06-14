
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/03 22:31:50
// Design Name: 
// Module Name: uart_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.03 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_top
(
input                           sys_clk_p,         //system clock positive
input                           sys_clk_n,         //system clock negative 
input                           rst_n,             //reset ,low active
input                           uart_rx,           //fpga receive data
output                          uart_tx ,
output                       reg led  ,
output                       wire   angle_sig_a,
output                       wire   angle_sig_b,
output                          Trig_a,
output                          Trig_b,
output                          Trig_c,
output                          Trig_d,
input                           Echo_a,
input                           Echo_b,
input                           Echo_c,
input                           Echo_d
         //fpga send data
);
parameter                       clk_fre = 100;    //Mhz
localparam                       IDLE =  0;
localparam                       SEND =  1;         //send HELLO ALINX\r\n
localparam                       WAIT =  2;         //wait 1 second and send uart received data
reg[7:0]                         tx_data;          //sending data
reg[7:0]                         tx_str;
reg                              tx_data_valid;    //sending data valid
wire                             tx_data_ready;    //singal for sending data
reg[7:0]                         tx_cnt=0; 
wire[7:0]                        rx_data;          //receiving data
wire                             rx_data_valid;    // receiving data valid
wire                             rx_data_ready;    // singal for receiving data
reg[31:0]                        wait_cnt=0;
reg[3:0]                         state=0;  
reg                             start;        
wire                             sys_clk; 
wire [31:0] sonic_dist;         //single end clock
/*************************************************************************
generate single end clock
**************************************************************************/
IBUFDS sys_clk_ibufgds   
(
.O                      (sys_clk                  ),
.I                      (sys_clk_p                ),
.IB                     (sys_clk_n                )
);
assign rx_data_ready = 1'b1;//always can receive data,
							//if HELLO ALINX\r\n is being sent, the received data is discarded
/*************************************************************************
1 second sends a packet HELLO ALINX\r\n , FPGA has been receiving state
****************************************************************************/
always@(posedge sys_clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		wait_cnt <= 32'd0;
		tx_data <= 8'd0;
		state <= IDLE;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
	end
	else
	case(state)
		IDLE:
		begin
		 
		 // if(pwm_cnt1 == 32'd18_999_999)//500ms
		 if(pwm_cnt == 32'd0 )
			state <= SEND;
			end
		SEND:
		begin
			wait_cnt <= 32'd0;
			tx_data <= tx_str;

			if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 &&( tx_cnt % 2 != 1'b1))//Send 12 bytes data
			begin
				tx_cnt <= tx_cnt + 8'd1; //Send data counter
			end
			else  if(tx_data_valid && tx_data_ready )//last byte sent is complete
			begin
			 if(tx_cnt > 6)
				tx_cnt <= 8'd0;
				else tx_cnt <= tx_cnt + 1'b1;
				tx_data_valid <= 1'b0;
				state <= IDLE;
			end
			else if(~tx_data_valid)
			begin
				tx_data_valid <= 1'b1;
			end
		end
		WAIT:
		begin
			wait_cnt <= wait_cnt + 32'd1;
            // 等待1s 数据的时候
			if(rx_data_valid == 1'b1) // 如果接收到数据
			begin
				tx_data_valid <= 1'b1; //使得发送数据使能，
				tx_data <= rx_data;   // send uart received data
			end
			else if(tx_data_valid && tx_data_ready)
			begin
				tx_data_valid <= 1'b0;
			end
			else if(wait_cnt >= clk_fre * 1000000) // wait for 1 second
				state <= SEND;
		end
		default:
			state <= IDLE;
	endcase
end
/*************************************************************************
combinational logic  Send "HELLO ALINX\r\n"
****************************************************************************/
always@(*)begin
if(!rst_n)
    led <= 1'b0;
    else
    if(rx_data_valid)
    led <= ~led;

    end
always@(*)
begin
	case(tx_cnt)
	    8'd0 :  tx_str <= 8'd101;
	    8'd1 :  tx_str <= dist_a[7:0];
	    8'd2 :  tx_str <= 8'd102;
	    8'd3 :  tx_str <= dist_b[7:0];
	    8'd4:  tx_str <= 8'd103;
	    8'd5:  tx_str <= dist_c[7:0];
	    8'd6 : tx_str <= 8'd104;
	    8'd7:  tx_str <= dist_d[7:0];

	 
	   

	 
	//	8'd1 :  tx_str <= sonic_dist_a[7:0];
	//	8'd2 :  tx_str <= 8'd002;
	//	8'd3 :  tx_str <= sonic_dist_b[7:0];
	//	8'd4 :  tx_str <= 8'd003;
	//	8'd5 :  tx_str <= sonic_dist_c[7:0];
	//	8'd6 :  tx_str <= 8'd004;
	//	8'd7 :  tx_str <= sonic_dist_d[7:0];

//		8'd4 :  tx_str <= "O";
/*		8'd5 :  tx_str <= " ";
		8'd6 :  tx_str <= "A";
		8'd7 :  tx_str <= "L";
		8'd8 :  tx_str <= "I";
		8'd9 :  tx_str <= "N";
		8'd10:  tx_str <= "X";*/
//		8'd11:  tx_str <= "\r";
//		8'd12:  tx_str <= "\n"; 
		default:;
	endcase
end

wire clk_1m;
CLK_1M u0(.clk_1m(clk_1m), .clk_100m(sys_clk), .rst_n(rst_n));
/***************************************************************************
calling uart_tx module and uart_rx module
****************************************************************************/
uart_rx#
(
.clk_fre(clk_fre),
.baud_rate(9600)
) uart_rx_inst
(
.clk                        (sys_clk                  ),
.rst_n                      (rst_n                    ),
.rx_data                    (rx_data                  ),
.rx_data_valid              (rx_data_valid            ),
.rx_data_ready              (rx_data_ready            ),
.rx_pin                     (uart_rx                  )
);

uart_tx#
(
.clk_fre(clk_fre),
.baud_rate(9600)
) uart_tx_inst
(
.clk                        (sys_clk                  ),
.rst_n                      (rst_n                    ),
.tx_data                    (tx_data                  ),
.tx_data_valid              (tx_data_valid            ),
.tx_data_ready              (tx_data_ready            ),
.tx_pin                     (uart_tx                  )
);



//   module electric machinery
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg [31:0] angle_num_a;
reg [31:0] angle_num_b;
reg [7:0] mode;
always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)
        begin
           mode <= 8'd0;
            angle_num_a <= 32'd1_499;
            angle_num_b <= 32'd1_499;
            start <= 1'b0;
            end
            else if(rx_data_valid)
                mode = rx_data; 
                   case(mode)
                 8'h01 : angle_num_a <= 32'd1_499;
                 8'h02 : angle_num_a <= 32'd2_499;
                8'h03 : angle_num_a <= 32'd499;
                8'h04 : angle_num_a <= 32'd1_999;
                8'h05 : angle_num_a <= 32'd_999;
                8'h11 : angle_num_b <= 32'd1_499;
                8'h12 : angle_num_b <= 32'd2_499;
                8'h13 : angle_num_b <= 32'd499;
                8'h14 : start <= 1'b0;
                8'h15 : start <= 1'b1;
                default :mode <= mode;
      
                    endcase
                end
                 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [31:0] angle_numa;
wire [31:0] angle_numb;
assign angle_numa = angle_num_a;
assign angle_numb = angle_num_b;

servo u9( .clk_1m(clk_1m), .rst_n(rst_n), .angle_num(angle_numa), .angle_sig(angle_sig_a));
servo u10( .clk_1m(clk_1m), .rst_n(rst_n), .angle_num(angle_numb), .angle_sig(angle_sig_b));














//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





 reg [31:0] num;


    reg [31:0] pwm_cnt;

    parameter num2 = 32'd99_999_999;
 always@(posedge sys_clk or negedge rst_n)
    begin
    if(!rst_n)begin  
    pwm_cnt <= 32'b0;
    end
    else 
    if(pwm_cnt==num2)pwm_cnt <= 1'b0;
    else  pwm_cnt <= pwm_cnt + 1'b1;
    end
 reg [31:0] num1;
 reg [7:0]  sgn;


///////////////////////////////////////////////////////////////////////////////////////////////////

wire[19:0] dis_a; // 回波高电平持续时间us 
wire [7:0] dist_a;
wire[11:0] d_a;   // 距离（单位cm）,5位十进制,包括两位小数

 // 50分频
TrigSignal u1(.clk_1m(clk_1m), .rst(rst_n), .trig(Trig_a));
PosCounter u2(.clk_1m(clk_1m), .rst(rst_n), .echo(Echo_a), .dis_count(dis_a));
assign d_a[11:8] = dis_a/10000;    // 百位
assign d_a[7:4] = dis_a/1000%10;  // 十位
assign d_a[3:0]  = dis_a/100%10;   // 个位
assign dist_a[7:0] = d_a[11:8]*100+d_a[7:4] *10+d_a[3:0];
////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire[19:0] dis_b; // 回波高电平持续时间us 
wire [7:0] dist_b;
wire[11:0] d_b;   // 距离（单位cm）,5位十进制,包括两位小数
TrigSignal u3(.clk_1m(clk_1m), .rst(rst_n), .trig(Trig_b));
PosCounter u4(.clk_1m(clk_1m), .rst(rst_n), .echo(Echo_b), .dis_count(dis_b));
assign d_b[11:8] = dis_b/10000;    // 百位
assign d_b[7:4] = dis_b/1000%10;  // 十位
assign d_b[3:0]  = dis_b/100%10;   // 个位
assign dist_b[7:0] = d_b[11:8]*100+d_b[7:4] *10+d_b[3:0];
////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire[19:0] dis_c; // 回波高电平持续时间us 
wire [7:0] dist_c;
wire[11:0] d_c;   // 距离（单位cm）,5位十进制,包括两位小数
TrigSignal u5(.clk_1m(clk_1m), .rst(rst_n), .trig(Trig_c));
PosCounter u6(.clk_1m(clk_1m), .rst(rst_n), .echo(Echo_c), .dis_count(dis_c));
assign d_c[11:8] = dis_c/10000;    // 百位
assign d_c[7:4] = dis_c/1000%10;  // 十位
assign d_c[3:0]  = dis_c/100%10;   // 个位
assign dist_c[7:0] = d_c[11:8]*100+d_c[7:4] *10+d_c[3:0];
      // 0.01
////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire[19:0] dis_d; // 回波高电平持续时间us 
wire [7:0] dist_d;
wire[11:0] d_d;   // 距离（单位cm）,5位十进制,包括两位小数
TrigSignal u7(.clk_1m(clk_1m), .rst(rst_n), .trig(Trig_d));
PosCounter u8(.clk_1m(clk_1m), .rst(rst_n), .echo(Echo_d), .dis_count(dis_d));
assign d_d[11:8] = dis_d/10000;    // 百位
assign d_d[7:4] = dis_d/1000%10; 
assign d_d[3:0]  = dis_d/100%10; // 十位
assign dist_d[7:0] = d_d[11:8]*100+d_d[7:4] *10+d_d[3:0];

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule



