module tx_fsm (
reset          ,
tx_data        ,
wr_enable      ,
tx_enable      ,
tx_out         ,
tx_busy       
);
// Port declarations
input        reset          ;
input  [159:0] tx_data        ;
input        tx_enable      ;
input        wr_enable      ;
output       tx_out         ;
output       tx_busy       ;

// Internal Variables 
reg [159:0]    tx_reg         ;
reg [7:0]    tx_cnt         ;
reg          tx_out         ;
reg	         tx_busy	    ;
reg          ld_tx_data     ;
reg [SIZE-1:0]    state;

parameter SIZE = 2;
parameter IDLE = 2'b00, START = 2'b01, TX = 2'b10,   STOP = 2'b11;



always @ (negedge tx_enable)
    if (reset)  begin
        tx_busy	<= 1;
        tx_reg        <= 0;
        tx_cnt        <= 0;
        ld_tx_data    <= 0;
        tx_out	<= 1;
        state <=  IDLE;
	
                end 
    else 
 
        case(state)
            IDLE : if   (wr_enable) begin
                        tx_reg <= tx_data;
      		            ld_tx_data <= 1;
                        state <= START;
		                tx_cnt <= 0;
                                  end
            START : if (!tx_enable) begin
		                tx_busy <= 0;
		                $display("TX of data has been started");
                        if(tx_cnt == 0) begin
                            $display("Counter Value : %b",tx_cnt);
                            tx_out <= 0;
                                        end
                        state <= TX;
                         end
                         
            TX : if (!tx_enable) begin
                    tx_out <= tx_reg[tx_cnt];
                    $display("Counter Value: %b",tx_cnt);
                    tx_cnt <= tx_cnt +1 ;
                    if(tx_cnt == 159) begin
                        tx_busy	<= 1;
                        state <= STOP;
                                    end
                                end 
            
            STOP :  if(!tx_enable) begin
		            ld_tx_data <=0;
                    tx_out <= 1;
                    tx_cnt <= 0;
                    state <= IDLE;
		            
	                $display("Counter Value: %b",tx_cnt);
	                $display("TX of data has been completed");
	            
                                    end

            default : state <=  IDLE;
        endcase
endmodule