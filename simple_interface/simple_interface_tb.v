module simple_interface_tb (
);
    reg clk;
    reg reset_n;
    reg [7:0] rx_data;
    reg rx_valid;
    wire rx_rd_en;
    wire [7:0] bus_addr;
    wire [31:0] bus_wr_data;
    wire bus_wr_en;
    wire bus_rd_en;
    wire error;

    simple_interface DUT (
    .clk(clk),
    .reset_n(reset_n),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .rx_rd_en_o(rx_rd_en),
    .bus_addr_o(bus_addr),
    .bus_wr_data_o(bus_wr_data),
    .bus_wr_en_o(bus_wr_en),
    .bus_rd_en_o(bus_rd_en),
	.error(error)
);  

    always #10 clk = ~clk;

    task send_byte(input [7:0] b); begin
        @(negedge clk);
        rx_data = b;
        rx_valid = 1;

        while (rx_rd_en == 0) begin
            @(negedge clk);
        end

        rx_valid = 0;
    end
    endtask

    localparam START = 8'hA5, READ = 8'h01, WRITE = 8'h02;

    initial begin
        clk = 0;
        reset_n = 0;
        @(negedge clk);
        reset_n = 1;
        @(negedge clk);
        send_byte(START);
        send_byte(WRITE);
        send_byte(8'h01);
        send_byte(8'h00);
        send_byte(8'h00);
        send_byte(8'h00);
        send_byte(8'h05);
        //check sum is gonna be 8'hAA
        send_byte(8'h08);
	repeat (5) @(negedge clk);
        #10 $stop;


    end
    
endmodule