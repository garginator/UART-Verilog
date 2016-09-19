`timescale 1ns / 1ps

module parity_gen (
data        , 
oddeven     , 
parity
);

    input [7:0] data;
    input oddeven;
    output parity;

    assign parity = (^data) ^ oddeven;

endmodule