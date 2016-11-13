

// Code your testbench here
// or browse Examples
module tx_tb(); 
  reg CLK, RESET, WR_ENABLE, TX_RST;
  reg [159:0] TX_DATA;
  wire TX_OUT,TX_BUSY;
  wire TX_ENABLE;
  wire RDY;
  reg RDY_CLR = 0;
  wire [159:0] RXDATA;
    
  initial begin
    CLK = 0; 
    RESET = 1;  
    
    WR_ENABLE = 1; 
    TX_DATA = 160'b1111000011001010111100001100101011110000110010101111000011001010111100001100101011110000110010101111000011001010111100001100101011110000110010101111000011001010;
    $display("TX DATA: %b",TX_DATA);
    #32 RESET = 0; 
    #33 WR_ENABLE = 0; 
    end 
    
  always  
  #1 CLK = !CLK; 
 initial begin
      #1 TX_RST = 1'b1;
      #2 TX_RST = 1'b0;
      #6000 $finish;
  end

baudrategentx baud(
    .clk(CLK),
    .rst(TX_RST),
    .txclk(TX_ENABLE)
    );


    
tx_fsm tx_dut (
    .reset    (RESET)       ,
    .tx_data  (TX_DATA)     ,
    .wr_enable(WR_ENABLE)   ,
    .tx_enable(TX_ENABLE)   ,
    .tx_out   (TX_OUT)      ,
    .tx_busy  (TX_BUSY)
  );
  
  receiver uart_rx(
    	 .rx(TX_OUT),
         .rdy(RDY),
    .rdy_clr(RDY_CLR),
    .clken(CLK),
    .data(RXDATA));
  
  always @(posedge RDY) begin
	#2 RDY_CLR <= 1;
	#2 RDY_CLR <= 0;
    if (RXDATA != TX_DATA) begin
      $display("FAIL: rx data %x does not match tx %x", RXDATA, TX_DATA);
		$finish;
	end else begin
			$display("SUCCESS: all bytes verified");
      	 $display("Received data is: %b",RXDATA);
      $display("Transmitted data was: %b",TX_DATA); 
			$finish;
		end
end
 
  initial  begin
    $display("\t\Time,\ttreset,\tclk,\twr_enable, \ttx_enable, \ttx_out, \ttx_busy"); 
    $monitor("%g,\t\t%b,\t\t%b,\t\t%b,\t\t%b,\t\t%b,\t\t%b",$time, RESET, CLK, WR_ENABLE, TX_ENABLE, TX_OUT, TX_BUSY); 
    end 
  
endmodule