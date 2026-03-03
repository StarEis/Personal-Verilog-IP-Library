module stream_fifo 
#(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 64
)
(
    input clk,
    input rst_n,
    input wr_en,
    input [DATA_WIDTH-1:0] wr_data,
    input rd_en,
    output [DATA_WIDTH-1:0] rd_data,
    output full,
    output empty,
    output wire [$clog2(DEPTH):0] count //when MSB is 1 FULL is 1 if every bit is zero empty is one
);

    reg [DATA_WIDTH-1:0] MEM [DEPTH-1:0];
    reg [$clog2(DEPTH)-1:0] wr_ptr;// 1 less than count as it will wrap around count
    reg [$clog2(DEPTH)-1:0] rd_ptr;

    reg [$clog2(DEPTH):0] fifo_cnt;
    assign count = fifo_cnt;

    assign full = fifo_cnt[$clog2(DEPTH)];
    assign empty = (fifo_cnt == 0);


    wire safe_wr = wr_en && (rd_en || ~full);
    wire safe_rd = rd_en && ~empty;



    assign rd_data = MEM[rd_ptr];

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            fifo_cnt <= 0;
        end else begin

            if(safe_wr && ~safe_rd) begin
                wr_ptr <= wr_ptr + 1;
                fifo_cnt <= fifo_cnt + 1;
                MEM[wr_ptr] <= wr_data;
            end

            if (safe_rd && ~safe_wr) begin
                rd_ptr <= rd_ptr+ 1;
                fifo_cnt <= fifo_cnt - 1;
            end

            if(safe_rd && safe_wr) begin
                wr_ptr <= wr_ptr + 1;
                rd_ptr <= rd_ptr+ 1;
                MEM[wr_ptr] <= wr_data;
            end
        end
    end
endmodule