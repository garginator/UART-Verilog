module tx_fsm (
reset          ,
tx_data        ,
wr_enable      ,
tx_enable      ,
parity         ,
tx_out         ,
tx_busy       
);
// Port declarations
input        reset          ;
input  [7:0] tx_data        ;
input        tx_enable      ;
input        wr_enable      ;
input        parity         ;
output       tx_out         ;
output       tx_busy       ;

// Internal Variables 
reg [7:0]    tx_reg         ;
reg [3:0]    tx_cnt         ;
reg          tx_out         ;
reg	         tx_busy	    ;
reg          ld_tx_data     ;
reg [SIZE-1:0]    state;

parameter SIZE = 5;
parameter IDLE = 3'b000, START = 3'b001, TX = 3'b010,  PARITY = 3'b011, STOP = 3'b100;



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
            IDLE : if (wr_enable) begin
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
                        tx_cnt <= tx_cnt + 1; 
                                   end
            TX : if (!tx_enable) begin
                    tx_out <= tx_reg[tx_cnt -1];
                    $display("Counter Value: %b",tx_cnt);
                    tx_cnt <= tx_cnt +1 ;
                    if(tx_cnt == 8) begin
                        state <= PARITY;
                                    end
                                end 
            PARITY: if(!tx_enable) begin
	               tx_out <= parity;
	               state <= STOP;
	               $display("Parity Bit: %b",parity);
	                               end
            STOP :  if(!tx_enable) begin
		            ld_tx_data <=0;
                    tx_out <= 1;
                    tx_cnt <= 0;
                    state <= #1 IDLE;
		            tx_busy	<= 1;
	                $display("Counter Value: %b",tx_cnt);
	                $display("TX of data has been completed");
	            
                                    end

            default : state <= #1 IDLE;
        endcase
endmodule