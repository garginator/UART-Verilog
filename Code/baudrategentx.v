module baudrategentx

#(parameter width = 4, N = 8)
(clk, rst, txclk);            
input clk, rst;
output txclk;
reg [width - 1:0] r_reg, txclk_track;
wire [width - 1:0] r_nxt;

always @ (negedge clk or negedge rst) begin
    if (rst) begin
        r_reg <= 0;
        txclk_track <= 1'b0;
    end
    else if (r_nxt == N) begin
        r_reg <= 0;
        txclk_track <= ~txclk_track;
    end
    else 
        r_reg <= r_nxt;
end
assign r_nxt = r_reg + 1;
assign txclk = txclk_track;
endmodule