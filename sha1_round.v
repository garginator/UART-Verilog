module sha1_round (
    input wire [159:0] context_in,
    input wire [31:0] w,
    input wire [31:0] k,
    input wire [31:0] f,
    output wire [159:0] context_out,
    output wire [31:0] f_next_20,
    output wire [31:0] f_next_40,
    output wire [31:0] f_next_60,
    output wire [31:0] f_next_80);

wire [31:0] a_in = context_in[159:128];
wire [31:0] b_in = context_in[127:96];
wire [31:0] c_in = context_in[95:64];
wire [31:0] d_in = context_in[63:32];
wire [31:0] e_in = context_in[31:0];

wire [31:0] a_out = {a_in[26:0], a_in[31:27]} + f + e_in + k + w;
wire [31:0] b_out = a_in;
wire [31:0] c_out = {b_in[1:0],b_in[31:2]};
wire [31:0] d_out = c_in;
wire [31:0] e_out = d_in;

assign f_next_20 = ((b_out & c_out) | (~b_out & d_out));
assign f_next_40 = (b_out ^ c_out ^ d_out);
assign f_next_60 = ((b_out & c_out) | (b_out & d_out) | (c_out & d_out));
assign f_next_80 = (b_out ^ c_out ^ d_out);

assign context_out = {a_out, b_out, c_out, d_out, e_out};

endmodule
