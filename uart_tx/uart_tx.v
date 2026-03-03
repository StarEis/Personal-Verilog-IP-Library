module uart_tx(
    input clk,
    input [7:0] data_in,
    input start,
    output reg tx,
    output led
);
    // 27_000_000 / 115_200
    parameter rate = 234;


    reg [7:0] counter;
    reg [2:0] index;
    reg [1:0] state;
    
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    
    assign led = tx;

    always @(posedge clk) begin
        case(state)
            IDLE: begin
                tx <= 1'b1;
                if(start) begin
                    state <= START;
                    counter <= 8'b0;
                end
            end
            START: begin
                tx <= 0;
                if(counter < rate - 1)
                    counter <= counter + 1;
                else begin
                    counter <= 8'b0;
                    state <= DATA;
                    index <= 2'b0;
                end
            end
            DATA: begin
                tx <= data_in[index];
                if(counter < rate - 1)
                    counter <= counter + 1;
                else begin 
                    counter <= 8'b0;
                    if (index < 7)
                        index <= index + 1;
                    else begin
                        state <= STOP;
                    end
                end
            end
            STOP: begin  
                tx = 1'b1;
                if(counter < rate - 1)
                    counter <= counter + 1;
                else begin
                    state <= IDLE; 
                end
            end

        endcase
    end
endmodule