module top(
    input clk,
    input rx,   // Pin 18
    output tx,  // Pin 17
    output [5:0] led 
);

    wire [7:0] rx_data;
    wire rx_done;

    reg [7:0] tx_data;
    reg tx_start;

    assign led = ~rx_data[5:0]; 

    uart_rx RX (
        .clk(clk),
        .rx(rx),
        .data_out(rx_data),
        .byte_ready(rx_done)
    );

    always @(posedge clk) begin
        tx_start <= 0;

        if (rx_done) begin
            if (rx_data >= 8'h61 && rx_data <= 8'h7A)
                tx_data <= rx_data - 8'h20;
            else
                tx_data <= rx_data; 
            tx_start <= 1;
        end
    end


    uart_tx TX (
        .clk(clk),
        .data_in(tx_data),
        .start(tx_start),
        .tx(tx),
        .led() 
    );
endmodule