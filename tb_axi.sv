`timescale 1ns/1ps

module tb_axi;
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    // clock and reset
    logic ACLK = 0;
    logic ARESETn = 0;

    always #5 ACLK = ~ACLK;

    // instantiate interface
    axi_master_if #(ADDR_WIDTH, DATA_WIDTH) axi();

    // connect clock and reset
    assign axi.ACLK = ACLK;
    assign axi.ARESETn = ARESETn;

    // FSDB dump
    initial begin
        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, tb_axi);
    end

    // instantiate slave model
    axi_slave_model #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) slave(axi);

    // stimulus
    initial begin
        logic [31:0] rdata;
        logic [31:0] wdata[4];
        logic [31:0] rmem[];

        // reset
        ARESETn = 0;
        repeat(5) @(posedge ACLK);
        ARESETn = 1;

        // simple register write/read
        axi.write_reg(32'h0000_0000, 32'hDEADBEEF);
        axi.read_reg(32'h0000_0000, rdata);
        $display("Read reg data = %h", rdata);

        // burst memory write/read
        wdata[0] = 32'h11111111;
        wdata[1] = 32'h22222222;
        wdata[2] = 32'h33333333;
        wdata[3] = 32'h44444444;

        axi.write_mem(32'h0000_0100, wdata);
        axi.read_mem(32'h0000_0100, rmem, 4);
        $display("Read mem data = %h %h %h %h", rmem[0], rmem[1], rmem[2], rmem[3]);

        // finish
        #20;
        $finish;
    end
endmodule
