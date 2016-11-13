module receiver(
  		input wire rx,
		output reg rdy,
		input wire rdy_clr,
		input wire clken,
        output reg [159:0] data);

initial begin
	rdy = 0;
	data = 160'b0;
end

parameter RX_STATE_START	= 2'b00;
parameter RX_STATE_DATA		= 2'b01;
parameter RX_STATE_STOP		= 2'b10;

reg [1:0] state = RX_STATE_START;
reg [3:0] sample = 0;
 reg [7:0] bitpos = 0;
  reg [159:0] scratch = 159'b0;

  always @(posedge clken) begin
	if (rdy_clr)
		rdy <= 0;

	if (clken) begin
		case (state)
		RX_STATE_START: begin
			/*
			* Start counting from the first low sample, once we've
			* sampled a full bit, start collecting data bits.
			*/
			if (!rx || sample != 0)
				sample <= sample + 4'b1;

			if (sample == 15) begin
				state <= RX_STATE_DATA;
				bitpos <= 0;
				sample <= 0;
              $display("RX of data has been started");
				scratch <= 0;
			end
		end
		RX_STATE_DATA: begin
			sample <= sample + 4'b1;
          if (sample == 8) begin
				scratch[bitpos] <= rx;
            $display("RX_DATA: %b",scratch);
				bitpos <= bitpos + 1;
			end
          if (bitpos == 160 && sample == 15)begin
				state <= RX_STATE_STOP;
          end
		end
		RX_STATE_STOP: begin
          $display("RX of data has been completed");
				state <= RX_STATE_START;
				data <= scratch;
				rdy <= 1'b1;
				sample <= 0;
		end
		default: begin
			state <= RX_STATE_START;
		end
		endcase
	end
end
endmodule