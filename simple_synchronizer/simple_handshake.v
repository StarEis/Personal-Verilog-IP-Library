module simple_handshake #(
    parameter WIDTH = 6
)(
    input src_clk,
    input src_rst_n,
    input [WIDTH-1:0] src_data_in,
    input src_valid,
    output reg src_ready,

    input dst_clk,
    input dst_rst_n,
    input dst_ready,
    output [WIDTH-1:0] dst_data,
    output reg dst_valid
);
    reg src_req;
    reg dst_ack;

    reg [WIDTH-1:0] data_holding_reg;

    wire dst_req;
    wire src_ack;

    parameter S_IDLE = 0, S_REQ_HIGH = 1, S_REQ_LOW = 2;

    reg [1:0] SRC_STATE;

    parameter D_IDLE = 0, D_TRANSACTION = 1, D_ACK = 2;

    reg [1:0] DST_STATE;

    simple_synchronizer src_to_dst (
        .clk_dst(dst_clk),
        .rst_dst_n(dst_rst_n),
        .data_src(src_req),
        .data_dst(dst_req)
    );

    simple_synchronizer dst_to_src (
        .clk_dst(src_clk),
        .rst_dst_n(src_rst_n),
        .data_src(dst_ack),
        .data_dst(src_ack)
    );

    assign dst_data = data_holding_reg;
    
    always @(posedge src_clk) begin
        if (src_rst_n) begin
            case (SRC_STATE)
                S_IDLE: begin
                    src_ready <= 1;
                    src_req <= 0;
                    if (src_valid) begin
                        SRC_STATE <= S_REQ_HIGH;
                        src_ready <= 0;
                        data_holding_reg <= src_data_in;
                    end
                end

                S_REQ_HIGH: begin
                    src_req <= 1;
                    if (src_ack) begin
                        SRC_STATE <= S_REQ_LOW;
                    end
                end

                S_REQ_LOW: begin
                    src_req <= 0;
                    if (!src_ack) begin
                        SRC_STATE <= S_IDLE;
                        src_ready <= 1;
                    end
                end
            endcase
        end else begin
            src_req <= 0;
            SRC_STATE <= S_IDLE;
            src_ready <= 1;
        end
    end

    always @(posedge dst_clk) begin
        if (dst_rst_n) begin
            case (DST_STATE)
                D_IDLE: begin
                    dst_ack <= 0;
                    if (dst_req) begin
                        dst_valid <= 1;
                        DST_STATE <= D_TRANSACTION;
                    end
                end 

                D_TRANSACTION: begin
                    if (dst_ready) begin
                        DST_STATE <= D_ACK;
                    end
                end

                D_ACK: begin
                    dst_ack <= 1;
                    dst_valid <= 0;
                    if (!dst_req) begin
                        DST_STATE <= D_IDLE;
                    end
                end
            endcase
        end else begin
            dst_valid <= 0;
            DST_STATE <= 0;
            dst_ack <= 0; 
        end
    end

endmodule