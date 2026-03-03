module uart_rx (
    input clk,
    input rx,          
    output reg [7:0] data_out, 
    output reg byte_ready
);
    reg rx_sync1, rx_safe;
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_safe <= rx_sync1; 
    end

    localparam rate = 234; // 27M / 115200

    localparam half_delay = (rate / 2) - 1;

    reg [7:0] counter;
    reg [2:0] index;
    reg [2:0] state;
    reg [2:0] bit_number;
    
    localparam IDLE = 0, START = 1, DATA = 2, WAIT = 3, READ = 4, STOP = 5;

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                byte_ready <= 0;
                if (rx_safe == 0) begin
                    counter <= 0;
                    index <= 0;
                    bit_number <= 0;
                    state <= START;
                end
            end
            START: begin
                if (counter == half_delay) begin
                    state <= WAIT;
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end
            WAIT: begin
                counter <= counter + 1;
                if (counter == rate) begin
                    counter <= 0;
                    state <= READ;
                end
            end
            READ: begin
                data_out <= {rx_safe, data_out[7:1]};
                bit_number <= bit_number + 1;
                if(bit_number == 7) begin
                    state <= STOP;
                end else begin
                    state <= WAIT;
                end
            end
            STOP: begin
                counter <= counter + 1;
                if ((counter) == half_delay) begin
                    state <= IDLE;
                    counter <= 0;
                    byte_ready <= 1;
                end
            end
        endcase

    end
    
endmodule