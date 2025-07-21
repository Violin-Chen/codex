`timescale 1ns/1ps
// Simple AXI master interface and tasks
interface axi_master_if #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32)();

    // Global signals
    logic ACLK;
    logic ARESETn;

    // Write address channel
    logic [ADDR_WIDTH-1:0] AWADDR;
    logic [7:0]            AWLEN;   // burst length - 1
    logic                  AWVALID;
    logic                  AWREADY;

    // Write data channel
    logic [DATA_WIDTH-1:0]     WDATA;
    logic [(DATA_WIDTH/8)-1:0] WSTRB;
    logic                      WLAST;
    logic                      WVALID;
    logic                      WREADY;

    // Write response channel
    logic [1:0] BRESP;
    logic BVALID;
    logic BREADY;

    // Read address channel
    logic [ADDR_WIDTH-1:0] ARADDR;
    logic [7:0]            ARLEN;   // burst length - 1
    logic                  ARVALID;
    logic                  ARREADY;

    // Read data channel
    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0]            RRESP;
    logic                  RLAST;
    logic                  RVALID;
    logic                  RREADY;

    // ------------------------------------------------------------
    // Single register write
    // ------------------------------------------------------------
    task automatic write_reg(input [ADDR_WIDTH-1:0] addr,
                             input [DATA_WIDTH-1:0] data);
        // setup address and data
        AWADDR  <= addr;
        AWLEN   <= 0;
        AWVALID <= 1'b1;
        WDATA   <= data;
        WSTRB   <= {(DATA_WIDTH/8){1'b1}};
        WLAST   <= 1'b1;
        WVALID  <= 1'b1;
        BREADY  <= 1'b1;
        // wait for slave to accept address and data
        @(posedge ACLK);
        wait (AWREADY && WREADY);
        @(posedge ACLK);
        AWVALID <= 1'b0;
        WVALID  <= 1'b0;
        // wait for response
        wait (BVALID);
        @(posedge ACLK);
        BREADY  <= 1'b0;
    endtask : write_reg

    // ------------------------------------------------------------
    // Single register read
    // ------------------------------------------------------------
    task automatic read_reg(input [ADDR_WIDTH-1:0]  addr,
                            output [DATA_WIDTH-1:0] data);
        // setup read address
        ARADDR  <= addr;
        ARLEN   <= 0;
        ARVALID <= 1'b1;
        RREADY  <= 1'b1;
        // wait for address handshake
        @(posedge ACLK);
        wait (ARREADY);
        @(posedge ACLK);
        ARVALID <= 1'b0;
        // wait for data
        wait (RVALID);
        data = RDATA;
        @(posedge ACLK);
        RREADY <= 1'b0;
    endtask : read_reg

    // ------------------------------------------------------------
    // Memory write - writes an array of data words
    // ------------------------------------------------------------
    task automatic write_mem(input [ADDR_WIDTH-1:0] addr,
                             input [DATA_WIDTH-1:0] data[]);
        int i;
        int n = data.size();
        // Issue write address with burst length
        AWADDR  <= addr;
        AWLEN   <= n-1;
        AWVALID <= 1'b1;
        @(posedge ACLK);
        wait (AWREADY);
        @(posedge ACLK);
        AWVALID <= 1'b0;

        // Write burst data
        for (i = 0; i < n; i++) begin
            WDATA  <= data[i];
            WSTRB  <= {(DATA_WIDTH/8){1'b1}};
            WLAST  <= (i == n-1);
            WVALID <= 1'b1;
            @(posedge ACLK);
            wait (WREADY);
            @(posedge ACLK);
            WVALID <= 1'b0;
        end

        // Wait for response
        BREADY <= 1'b1;
        wait (BVALID);
        @(posedge ACLK);
        BREADY <= 1'b0;
    endtask : write_mem

    // ------------------------------------------------------------
    // Memory read - reads a sequence of data words
    // ------------------------------------------------------------
    task automatic read_mem(input [ADDR_WIDTH-1:0] addr,
                            output [DATA_WIDTH-1:0] data[],
                            input int length);
        int i;
        data = new[length];

        // Issue read address
        ARADDR  <= addr;
        ARLEN   <= length-1;
        ARVALID <= 1'b1;
        @(posedge ACLK);
        wait (ARREADY);
        @(posedge ACLK);
        ARVALID <= 1'b0;

        // Read burst data
        RREADY <= 1'b1;
        for (i = 0; i < length; i++) begin
            wait (RVALID);
            data[i] = RDATA;
            @(posedge ACLK);
            if (i == length-1)
                RREADY <= 1'b0;
        end
    endtask : read_mem

endinterface

