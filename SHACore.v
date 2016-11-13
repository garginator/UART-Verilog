// process a SHA1 block

module sha1_block (
    input wire clk,
    input wire start,
    input wire [159:0] context_in,
    input wire [511:0] block,
    output wire done,
    output wire [159:0] context_out);

reg [6:0] round;
reg [159:0] context;

wire [159:0] context_next;

assign done = round == 80;

wire [31:0] h0 = context_in[159:128];
wire [31:0] h1 = context_in[127:96];
wire [31:0] h2 = context_in[95:64];
wire [31:0] h3 = context_in[63:32];
wire [31:0] h4 = context_in[31:0];

wire [31:0] a = context[159:128];
wire [31:0] b = context[127:96];
wire [31:0] c = context[95:64];
wire [31:0] d = context[63:32];
wire [31:0] e = context[31:0];

wire [31:0] w;
wire [31:0] k = (round <= 19) ? 32'h5A827999 :
                (round <= 39) ? 32'h6ED9EBA1 :
                (round <= 59) ? 32'h8F1BBCDC :
                                32'hCA62C1D6;

reg [31:0] f;
wire [31:0] f_zero = ((b & c) | (~b & d));
wire [31:0] f_next_20;
wire [31:0] f_next_40;
wire [31:0] f_next_60;
wire [31:0] f_next_80;

assign context_out = {h0+a, h1+b, h2+c, h3+d, h4+e};

w_machine w_machine (.clk(clk), .load(start), .block(block), .w(w));
sha1_round sha1_round (
    .context_in(context),
    .w(w), .k(k), .f(f),
    .context_out(context_next),
    .f_next_20(f_next_20),
    .f_next_40(f_next_40),
    .f_next_60(f_next_60),
    .f_next_80(f_next_80));

always @(posedge clk)
begin
    if (start) begin
        round <= 0;
        context <= context_in;
        f <= f_zero;
    end else begin
        round <= (round + 1) % 128;
        context <= context_next;
        if (round+1 <= 19) // set up *next* round's f
            f <= f_next_20;
        else if (round+1 <= 39)
            f <= f_next_40;
        else if (round+1 <= 59)
            f <= f_next_60;
        else
            f <= f_next_80;
    end
end

endmodule

