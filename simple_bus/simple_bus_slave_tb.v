module bus_slave_tb (
    
);
    reg clk = 0;
    always #5 clk = ~clk;

    reg reset_n = 0;
    reg r_en = 0;
    reg w_en = 0;
    reg [7:0] w_data = 0;
    reg [7:0] addr = 0;
    wire [7:0] r_data; 
    wire r_done;

    simple_bus_slave DUT (
        .clk(clk),
        .rst_n(reset_n),
        .EN_R(r_en),
        .EN_W(w_en),
        .W_DATA(w_data),
        .ADDR(addr),
        .R_DATA(r_data),
        .R_DONE(r_done)
    );
    // input logic clk,
    // input logic rst_n,
    // input EN_R,
    // input EN_W,
    // input [7:0] W_DATA,
    // input [7:0] ADDR,
    // output [7:0] R_DATA,
    // output R_DONE

    initial begin
        #10 reset_n = 1;

        #10 w_en = 1; w_data = 8'hA5; addr = 8'h01;
        #10 w_en = 0;
    
        #10 r_en = 1;

        #10 
        if(r_data == w_data)
            $display("pass");
        else
            $display("fail");
	$stop;
    end

endmodule