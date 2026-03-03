module packet_parser (
    input clk,
    input rx,
    output tx,
    output [1:0] led
);

    wire [7:0] rx_data_out;
    wire rx_status;

    wire [7:0] tx_input;
    wire tx_busy;
    wire tx_start;

    uart_rx RX (
        .clk(clk),
        .rx(rx),
        .data_out(rx_data_out),
        .byte_ready(rx_status)
    );

    Custom_Data_Path dpath (
        .clk(clk),
        .RX_Ready(rx_status),
        .RX_DATA_IN(rx_data_out),
        .TX_READY(tx_start),
        .TX_DATA_IN(tx_input),
        .led()
    );

    uart_tx TX (
        .clk(clk),
        .tx(tx),
        .start(tx_start),
        .data_in(tx_input),
        .busy(tx_busy)
    );
endmodule