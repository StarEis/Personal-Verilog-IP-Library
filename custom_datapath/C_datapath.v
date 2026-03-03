module Custom_Data_Path (
    input clk,
    input RX_Ready,
    input [7:0] RX_DATA_IN,
    output TX_READY,
    output reg [7:0] TX_DATA_IN,
    output [1:0] LED
);


    reg [1:0] STATE;
    parameter IDLE = 0, WAIT_LEN = 1, WAIT_PAYLOAD = 2, COMPARE_SUM = 3; 
    parameter ACK = 8'h6, NACK = 8'h15, START = 8'hAA;
    reg [7:0] LENGTH;
    reg [7:0] COUNTER; 
    reg [7:0] TOTAL_SUM;

    always @(posedge clk) begin
        case (STATE)
            IDLE: begin
                TX_READY <= 0;
                if (RX_Ready && (RX_DATA_IN == START)) begin
                    STATE <= WAIT_LEN;
                    LENGTH <= 0;
                    COUNTER <= 0;
                    TOTAL_SUM <= 0;
                end
            end 
            WAIT_LEN: begin
                if (RX_Ready) begin
                    STATE <= WAIT_PAYLOAD;
                    LENGTH <= RX_DATA_IN;
                    TOTAL_SUM <= TOTAL_SUM + RX_DATA_IN;
                end
            end
            WAIT_PAYLOAD: begin
                if (LENGTH == COUNTER) begin
                    STATE <= COMPARE_SUM;
                end else begin
                    if (RX_Ready) begin
                        COUNTER <= COUNTER + 1;
                        TOTAL_SUM <= TOTAL_SUM + RX_DATA_IN;
                    end
                end
            end
            COMPARE_SUM: begin
                if(RX_Ready) begin
                    if(TOTAL_SUM == RX_DATA_IN) begin
                        STATE <= IDLE;
                        TX_DATA_IN <= ACK;
                        TX_READY <= 1;
                    end else begin
                        STATE <= IDLE;
                        TX_DATA_IN <= NACK;
                        TX_READY <= 1;
                    end
                end
            end
        endcase 
    end 
endmodule