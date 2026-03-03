module tb_stream_fifo();

reg clk = 0;

always #5 clk = ~clk;

reg rst_n = 1;
reg wr_en = 0;
reg [7:0] wr_data = 0;
reg rd_en = 0;
wire [7:0] rd_data;
wire full;
wire empty;
wire [6:0] count;

stream_fifo DUT (
    //inputs
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .rd_en(rd_en),
    //outputs
    .rd_data(rd_data),
    .full(full),
    .empty(empty),
    .count(count)
);
//     input clk,
//     input rst_n,
//     input wr_en,
//     input [DATA_WIDTH-1:0] wr_data,
//     input rd_en,
//     output [DATA_WIDTH-1:0] rd_data,
//     output full,
//     output empty,
//     output wire [$clog2(DEPTH):0] count

initial begin

    //Case 1 START, write 4 bytes read 4 bytes.
    
    rst_n = 0; 
    repeat(2) @(negedge clk);
    rst_n = 1;
    @(negedge clk);
    wr_en = 1; 

    repeat (4) begin
        @(negedge clk); 
        wr_data = $urandom_range(0,255);
    end
    
    @(negedge clk);
    wr_en = 0;


    rd_en = 1; 
    repeat (4) @(negedge clk);
    rd_en = 0; 

    //Case 1 END
    //Case 2 START, Write 65 bytes to see what happens.

    @(negedge clk);
    wr_en = 1; 

    repeat (65) begin
        @(negedge clk); 
        wr_data = $urandom_range(0,255);
    end
    
    @(negedge clk);
    wr_en = 0;

    //Case 2 END
    //Case 3 START, Read 65 bytes to see what happens.

    rd_en = 1; 
    repeat (65) @(negedge clk);
    rd_en = 0;


    #10 $stop;
end
endmodule