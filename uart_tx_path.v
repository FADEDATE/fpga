module uart_tx

#( 
    parameter clk_fre = 100,
    parameter baud_rate = 9600
)
(

    input clk,
    input rst_n,
    input [7:0]tx_data,
    input tx_data_valid,
    
    
    output tx_pin,
    output reg tx_data_ready
    
);
//calculates the clock cycle for baud rate 
localparam cycle = clk_fre * 1000000/baud_rate;
parameter s_idle=3'b000;
parameter s_start=3'b001;
parameter s_send_byte=3'b010;
parameter s_stop=3'b011;

reg [2:0]state=0;
reg [2:0]next_state;

reg [15:0] cycle_cnt=0;
reg [2:0] bit_cnt=0;
reg [7:0] tx_data_latch;
reg tx_reg=1;
assign tx_pin = tx_reg;


always@(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        begin
            state <= s_idle;
        end
    else 
        begin
            case(state)
            s_idle:
                begin
                    if(tx_data_valid == 1'b1)
                        begin
                            state <= s_start;
                            tx_data_latch <= tx_data;
                            tx_data_ready <= 1'b0;
                        end
                    else
                        begin
                            tx_reg <= 1'b1;
                            state <=s_idle;
                            tx_data_ready <= 1'b1;
                        end
                 end
            s_start:
                begin
                    if(cycle_cnt == cycle -1)
                        begin
                            state <= s_send_byte;
                            cycle_cnt <= 16'd0;
                        end
                    else
                        begin
                            cycle_cnt <= cycle_cnt + 16'd1;
                            tx_reg <= 1'b0;
                            state <= s_start;
                            
                        end
                end
            s_send_byte:
                begin
                    if(cycle_cnt == cycle - 1)
                        //分成两种情况，达到8个bit/没到8个字节
                        begin
                            if(bit_cnt == 3'd7)
                                begin
                                    state <= s_stop;
                                    bit_cnt <= 3'd0;
                                    cycle_cnt <= 16'd0;
                                end
                            else
                                begin
                                    bit_cnt <= bit_cnt + 3'd1;
                                    cycle_cnt <= 16'd0;
                                end
                            
                        end
                    else
                        begin
                            cycle_cnt <= cycle_cnt + 16'd1;
                            tx_reg = tx_data_latch[bit_cnt];
                        end
                end
            s_stop:
                begin
                    if(cycle_cnt == cycle -1)
                        begin
                            tx_data_ready <= 1'b1;   
                            state <= s_idle;      
                            cycle_cnt <= 16'd0;    
                        end
                    else
                        begin   
                            tx_reg <= 1'b1;
                            cycle_cnt <= cycle_cnt + 16'd1;
                        end
                end
          default:
               state <= s_idle;
        endcase
    end
end

endmodule

