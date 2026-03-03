module simple_synchronizer #(
    parameter WIDTH = 1
) (
    input clk_dst,
    input rst_dst_n,
    input [WIDTH-1:0] data_src,
    output wire [WIDTH-1:0] data_dst
);
    /*
    This is used to scynchronize two time domains with different frequencies to send signals between them 
    */
    (* ASYNC_REG = "TRUE" *) reg [WIDTH-1:0] SRC_IN;
    (* ASYNC_REG = "TRUE" *) reg [WIDTH-1:0] DST_OUT;

    assign data_dst = DST_OUT;

    always @(posedge clk_dst or negedge rst_dst_n) begin
        if(!rst_dst_n) begin
            SRC_IN <= 0;
            DST_OUT <= 0;
        end else begin
            SRC_IN <= data_src;
            DST_OUT <= SRC_IN;
        end
    end
endmodule