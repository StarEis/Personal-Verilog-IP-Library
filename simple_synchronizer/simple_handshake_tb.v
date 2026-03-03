`timescale 1ns/1ps //multiply the time unit by 1ns and divide by 1ps making the unit 1ns

module simple_handshake_tb #(parameter WIDTH = 32)();

    reg src_clk;
    reg src_rst_n;
    reg [WIDTH-1:0] src_data_in;
    reg src_valid;
    wire src_ready;

    reg dst_clk;
    reg dst_rst_n;
    reg dst_ready;
    wire [WIDTH-1:0] dst_data;
    wire dst_valid;

    simple_handshake DUT (
        .src_clk(src_clk),
        .src_rst_n(src_rst_n),
        .src_data_in(src_data_in),
        .src_valid(src_valid),
        .src_ready(src_ready),
        .dst_clk(dst_clk),
        .dst_rst_n(dst_rst_n),
        .dst_ready(dst_ready),
        .dst_data(dst_data),
        .dst_valid(dst_valid)
    );

    always #5 src_clk = ~src_clk;
    always #10 dst_clk = ~dst_clk;


    initial begin
        src_clk = 0; #2 dst_clk = 0; 
        //small ns wait between setting up the clks to cause phase shift between them
        src_rst_n = 0; dst_rst_n = 0;
        @(negedge src_clk); @(negedge dst_clk);
        src_rst_n = 1; dst_rst_n = 1;
        src_data_in = 0; src_valid = 0; dst_ready = 0;
        @(negedge dst_clk);
        dst_ready = 1; src_data_in = 32'hDEAD_DEAD;
        src_valid = 1; 
        @(negedge src_clk); 
        src_valid = 0;
        #320 $stop;
    end
endmodule