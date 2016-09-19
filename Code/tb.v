module tx_tb(); 
  reg CLK, RESET, WR_ENABLE, TX_RST, ODDEVEN;
  reg [7:0] TX_DATA;
  wire TX_OUT,TX_BUSY;
  wire TX_ENABLE, PARITY;
    
  initial begin
    CLK = 0; 
    RESET = 1;  
    ODDEVEN <= 0;
    WR_ENABLE = 1; 
    TX_DATA = 8'b11011000;
    #32 RESET = 0; 
    #33 WR_ENABLE = 0; 
    end 
    
  always  
  #1 CLK = !CLK; 
 initial begin
      #1 TX_RST = 1'b1;
      #2 TX_RST = 1'b0;
      #1000 $finish;
  end

baudrategentx baud(
    .clk(CLK),
    .rst(TX_RST),
    .txclk(TX_ENABLE)
    );

parity_gen pp(
    .data    (TX_DATA)  ,
    .oddeven (ODDEVEN)  ,
    .parity  (PARITY)
    );
    
tx_fsm tx_dut (
    .reset    (RESET)       ,
    .tx_data  (TX_DATA)     ,
    .wr_enable(WR_ENABLE)   ,
    .tx_enable(TX_ENABLE)   ,
    .parity   (PARITY)      ,
    .tx_out   (TX_OUT)      ,
    .tx_busy  (TX_BUSY)
  );
    
  initial  begin
    $display("\t\Time,\ttreset,\tclk,\ttx_data,\twr_enable, \ttx_enable, \ttx_out, \ttx_busy"); 
    $monitor("%g, \t%b,\t%b,\t%b,\t%b,\t%b, \t%b,",$time, RESET, CLK, TX_DATA, WR_ENABLE, TX_ENABLE, TX_OUT, TX_BUSY); 
    end 
  initial 
  #4500 $finish;     
  
endmodule