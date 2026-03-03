module top_handshake #(WIDTH=6)(
    input wire clk,      
    input wire btn1,
    input wire btn2,
    output wire [5:0] led 
);

    reg src_rst_n;
    reg [WIDTH-1:0] src_data_in = 6'b;


    reg dst_clk;
    reg dst_rst_n;
    reg dst_ready;


    simple_handshake DUT (
        .src_clk(src_clk),
        .src_rst_n(1),
        .src_data_in(src_data_in),
        .src_valid(!bt),
        .src_ready(src_ready),
        .dst_clk(dst_clk),
        .dst_rst_n(1),
        .dst_ready(!btn2),
        .dst_data(dst_data),
        .dst_valid(dst_valid)
    );
    
    assign src_valid = !btn1;
    assign dst_valid = !btn2;
    assign led = dst_data;
endmodule