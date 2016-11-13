module w_machine (
    input wire clk,
    input wire load,
    input wire [511:0] block,
    output wire [31:0] w);

reg [511:0] state;
assign w = state[511:480];
wire [31:0] w_im3 = state[95:64];
wire [31:0] w_im8 = state[255:224];
wire [31:0] w_im14 = state[447:416];
wire [31:0] w_im16 = state[511:480];
wire [31:0] w_temp = w_im3 ^ w_im8 ^ w_im14 ^ w_im16;
wire [31:0] w_next = {w_temp[30:0], w_temp[31]};

always @(posedge clk)
begin
    if (load)
        state <= block;
    else begin
        state <= {state[479:0], w_next};
    end
end

endmodule