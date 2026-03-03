module simple_bus_slave 
#(
    parameter DATA_WIDTH = 8,
    parameter MEMORY_SIZE = 256
)
(
    input clk,
    input rst_n,
    input EN_R,
    input EN_W,
    input  [DATA_WIDTH-1:0] W_DATA,
    input  [DATA_WIDTH-1:0] ADDR,

    output reg [DATA_WIDTH-1:0] R_DATA,
    output reg R_DONE
);

reg [DATA_WIDTH-1:0] MEM [MEMORY_SIZE-1:0];

always @(posedge clk) begin
    R_DONE <= 0;

    if (!rst_n) begin
        MEM[1] <= 0;
    end else begin
        if (EN_W && ~EN_R) begin
            MEM[ADDR] <= W_DATA;
        end else if (EN_R) begin
            R_DATA <= MEM[ADDR];
            R_DONE <= 1;
        end
    end
end
endmodule