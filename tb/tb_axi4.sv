`timescale 1ns/1ps



module tb_axi4;
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter MAX_BURST  = 16;

    axi4_master_if #(ADDR_WIDTH, DATA_WIDTH, MAX_BURST) axi_if();

    // Instantiate DUT
    axi4_slave #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .aclk   (axi_if.aclk),
        .aresetn(axi_if.aresetn),
        .awvalid(axi_if.awvalid),
        .awready(axi_if.awready),
        .awaddr (axi_if.awaddr),
        .awlen  (axi_if.awlen),
        .awsize (axi_if.awsize),
        .awburst(axi_if.awburst),
        .wvalid (axi_if.wvalid),
        .wready (axi_if.wready),
        .wdata  (axi_if.wdata),
        .wstrb  (axi_if.wstrb),
        .wlast  (axi_if.wlast),
        .bvalid (axi_if.bvalid),
        .bready (axi_if.bready),
        .bresp  (axi_if.bresp),
        .arvalid(axi_if.arvalid),
        .arready(axi_if.arready),
        .araddr (axi_if.araddr),
        .arlen  (axi_if.arlen),
        .arsize (axi_if.arsize),
        .arburst(axi_if.arburst),
        .rvalid (axi_if.rvalid),
        .rready (axi_if.rready),
        .rdata  (axi_if.rdata),
        .rresp  (axi_if.rresp),
        .rlast  (axi_if.rlast)
    );

    // clock generation
    initial axi_if.aclk = 0;
    always #5 axi_if.aclk = ~axi_if.aclk;

    // reset generation
    initial begin
        axi_if.aresetn = 0;
        axi_if.awvalid = 0;
        axi_if.wvalid  = 0;
        axi_if.bready  = 0;
        axi_if.arvalid = 0;
        axi_if.rready  = 0;
        repeat(5) @(posedge axi_if.aclk);
        axi_if.aresetn = 1;
    end

    // Test sequence
    initial begin
        integer i;
        reg [DATA_WIDTH-1:0] rdata;
        reg [DATA_WIDTH-1:0] burst_wdata [0:MAX_BURST-1];
        reg [DATA_WIDTH-1:0] burst_rdata [0:MAX_BURST-1];

        $display("Starting tests...");
        // register write/read
        axi_if.write_single(32'h0000_0000, 32'hDEADBEEF);
        axi_if.read_single(32'h0000_0000, rdata);
        if (rdata !== 32'hDEADBEEF) $display("Register test failed: %h", rdata);
        else $display("Register test passed");

        // burst write/read
        for(i=0;i<4;i++) burst_wdata[i] = i+1;
        axi_if.write_burst(32'h0000_0010, burst_wdata, 4);
        axi_if.read_burst(32'h0000_0010, burst_rdata, 4);
        for(i=0;i<4;i++)
            if (burst_rdata[i] !== burst_wdata[i])
                $display("Burst mismatch at %0d: wrote %h read %h", i, burst_wdata[i], burst_rdata[i]);
        $display("Burst test completed");

        #100;
        $finish;
    end

    // waveform dump
`ifndef IVERILOG
    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, tb_axi4);
    end
`else
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_axi4);
    end
`endif
endmodule
