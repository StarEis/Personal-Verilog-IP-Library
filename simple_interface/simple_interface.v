module simple_interface (
    input clk,
    input reset_n,
    input [7:0] rx_data,
    output error,
    input rx_valid,
    output rx_rd_en_o,
    output [7:0] bus_addr_o,
    output [31:0] bus_wr_data_o,
    output bus_wr_en_o,
    output bus_rd_en_o
);
    /*  
    This is a 8 bytes/64 bits communication interface
    1 byte start, 1 byte operation (R or W), 1 byte address, 4 bytes of information, 1 byte checksumx
    */
    
    //removed validate checksum because that can be done at the same time as getting checksum
    reg error_reg;
    reg [3:0] state; //including error and execute I have 7 states:2^2 < 7 < 2^3 = 8 so 3 bits
    reg [7:0] cmd_reg;
    reg [7:0] addr_reg;
    reg [31:0] data_reg;
    reg [7:0] cs_total; //checksum total
    reg [2:0] byte_cnt; // will go up to 4: 2^1 < 4 <= 2^2, so 2 bits
    
    reg rx_rd_en;
    reg [7:0]bus_addr;
    reg [31:0]bus_wr_data;
    reg bus_wr_en;
    reg bus_rd_en;
    assign rx_rd_en_o = rx_rd_en;
    assign bus_addr_o = bus_addr;
    assign bus_wr_data_o = bus_wr_data;
    assign bus_wr_en_o = bus_wr_en;
    assign bus_rd_en_o = bus_rd_en;

	
    localparam IDLE = 0, GET_CMD = 1, GET_ADDR = 2, GET_DATA = 3, GET_CHECKSUM = 4, EXECUTE = 5, ERROR = 6;
    localparam START = 8'hA5, READ = 8'h01, WRITE = 'h02;
    

    assign error = error_reg;

    always @(posedge clk) begin
        if(~reset_n) begin
            state <= 0;
            // cmd_reg <= 0;
            // addr_reg <= 0;
            // data_reg <= 0;
            //these three will be changed everytime before checking it so it is fine to not reset them.
            cs_total <= 0;
            byte_cnt <= 0;
            //setting outputs to 0 as I will not know WHEN the circuit is being reset.
            rx_rd_en <= 0;
            bus_addr <= 0;
            bus_wr_data <= 0;
            bus_wr_en <= 0;
            bus_rd_en <= 0;

        end else begin
            case (state) 
                IDLE: begin
                    error_reg <= 0;
                    rx_rd_en <= 0;
                    cs_total <= 0;
                    byte_cnt <= 0;
                    if (rx_valid) begin
                        rx_rd_en <= 1;
                        if (rx_data == START) begin
                            state <= GET_CMD;
                        end
                    end
                end

                GET_CMD: begin
                    rx_rd_en <= 0;
                    if(rx_valid) begin
                        rx_rd_en <= 1;
                        if (rx_data == READ || rx_data == WRITE) begin
                            state <= GET_ADDR;
                            cmd_reg <= rx_data;
                            cs_total <= cs_total + rx_data;
                        end
                    end 
                end

                GET_ADDR: begin
                    rx_rd_en <= 0;
                    if (rx_valid) begin
                        rx_rd_en <= 1;
                        state <= GET_DATA;
                        addr_reg <= rx_data;
                        cs_total <= cs_total + rx_data;
                    end
                end


                GET_DATA: begin
                    rx_rd_en <= 0;
                    if (rx_valid) begin
                        rx_rd_en <= 1;                 
                        cs_total <= cs_total + rx_data; 
                        byte_cnt <= byte_cnt + 1;       

                        case (byte_cnt)
                            0: data_reg[7:0]   <= rx_data;
                            1: data_reg[15:8]  <= rx_data;
                            2: data_reg[23:16] <= rx_data;
                            3: begin
                            data_reg[31:24] <= rx_data;
                            state <= GET_CHECKSUM;
                            end
                        endcase
                    end
                end


                GET_CHECKSUM: begin
                    rx_rd_en <= 0;
                    if (rx_valid) begin
                        rx_rd_en <= 1;
                        if(cs_total == rx_data) begin
                            state <= EXECUTE;
                        end else begin
                            state <= ERROR;
                        end
                    end
                end

                EXECUTE: begin
                    if (cmd_reg == READ) begin
                        bus_rd_en <= 1;
                        bus_addr <= addr_reg;
                        state <= IDLE;
                    end else if (cmd_reg == WRITE) begin
                        bus_wr_en <= 1;
                        bus_wr_data <= data_reg;
                        bus_addr <= addr_reg;
                        state <= IDLE;
                    end
                end

                ERROR: begin
                    error_reg <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

    
endmodule
