module testbed;

integer ticks;

reg clk;
reg start;
wire [159:0] context_initial = {32'h67452301, 32'hEFCDAB89, 32'h98BADCFE, 32'h10325476, 32'hC3D2E1F0};
wire done;
wire [159:0] context_out;

 reg CLK, RESET, WR_ENABLE, TX_RST;
  reg [159:0] TX_DATA;
  wire TX_OUT,TX_BUSY;
  wire TX_ENABLE;
  wire RDY;
  reg RDY_CLR = 0;
  wire [159:0] RXDATA;

 //zero-length data
wire [511:0] block = {8'h80, 504'h0};

// string "abc"
//wire [511:0] block = {"abc", 8'h80, 416'd0, 64'd24}; // length in *bits*

// 55-character string (largest 1-block hash)
//wire [511:0] block = {"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012", 8'h80, 64'd440}; // length in *bits*


sha1_block sha1_block (.clk(clk), .start(start), .context_in(context_initial), .block(block), .done(done), .context_out(context_out));

initial begin
  ticks = 0;
  $display("starting");
  $display("block:%h", block);
  CLK = 0; 
  RESET = 1;  
  tick;
  start = 1'b1;
  tick;
  tick;
  tick;
  start = 1'b0;
  repeat (80) begin
    tick;
  end
  $display("h0:%h h1:%h h2:%h h3:%h h4:%h",
    context_out[159:128],
    context_out[127:96],
    context_out[95:64],
    context_out[63:32],
    context_out[31:0]);
   TX_DATA = context_out;
    $display("TX DATA: %b",TX_DATA);
    WR_ENABLE = 1; 
  	$display("Time,\ttreset,\tclk,\twr_enable, \ttx_enable, \ttx_out, \ttx_busy"); 
    $monitor("%g,\t\t%b,\t\t%b,\t\t%b,\t\t%b,\t\t%b,\t\t%b",$time, RESET, CLK, WR_ENABLE, TX_ENABLE, TX_OUT, TX_BUSY); 
  
   
  	
end

task tick;
begin
  #1;
  clk = 1;
  #1;
  clk = 0;
  ticks = ticks + 1;
  dumpstate;
end
endtask

task dumpstate;
begin
  $display("%d %b %b %h", ticks, start, done, context_out);
  $display("a:%h b:%h c:%h d:%h e:%h f:%h k:%h w:%h",
    sha1_block.a,
    sha1_block.b,
    sha1_block.c,
    sha1_block.d,
    sha1_block.e,
    sha1_block.f,
    sha1_block.k,
    sha1_block.w);
end
endtask


    
  initial begin
    #168 RESET = 0; 
    #169 WR_ENABLE = 0; 
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
 

endmodule
