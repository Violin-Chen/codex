interface axi4_master_if#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MAX_BURST  = 16
);
    logic aclk;
    logic aresetn;
    logic awvalid;
    logic awready;
    logic [ADDR_WIDTH-1:0] awaddr;
    logic [7:0] awlen;
    logic [2:0] awsize;
    logic [1:0] awburst;
    logic wvalid;
    logic wready;
    logic [DATA_WIDTH-1:0] wdata;
    logic [3:0] wstrb;
    logic wlast;
    logic bvalid;
    logic bready;
    logic [1:0] bresp;
    logic arvalid;
    logic arready;
    logic [ADDR_WIDTH-1:0] araddr;
    logic [7:0] arlen;
    logic [2:0] arsize;
    logic [1:0] arburst;
    logic rvalid;
    logic rready;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0] rresp;
    logic rlast;

    // Write single data
    task automatic write_single(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        awaddr  <= addr;
        awlen   <= 0;
        awsize  <= 3'b010; // 4 bytes
        awburst <= 2'b01;  // INCR
        awvalid <= 1;
        @(posedge aclk); while(!awready) @(posedge aclk);
        awvalid <= 0;
        wdata  <= data;
        wstrb  <= 4'hF;
        wvalid <= 1;
        wlast  <= 1;
        @(posedge aclk); while(!wready) @(posedge aclk);
        wvalid <= 0;
        wlast  <= 0;
        bready <= 1;
        @(posedge aclk); while(!bvalid) @(posedge aclk);
        bready <= 0;
    endtask

    // Read single data
    task automatic read_single(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
        araddr  <= addr;
        arlen   <= 0;
        arsize  <= 3'b010;
        arburst <= 2'b01;
        arvalid <= 1;
        @(posedge aclk); while(!arready) @(posedge aclk);
        arvalid <= 0;
        rready  <= 1;
        @(posedge aclk); while(!rvalid) @(posedge aclk);
        data = rdata;
        @(posedge aclk);
        rready <= 0;
    endtask

    // Burst write. Accept an open array so any sized buffer can be passed in.
    task automatic write_burst(input [ADDR_WIDTH-1:0] addr,
                               input [DATA_WIDTH-1:0] data [],
                               input int beats);
        awaddr  <= addr;
        awlen   <= beats-1;
        awsize  <= 3'b010;
        awburst <= 2'b01;
        awvalid <= 1;
        @(posedge aclk); while(!awready) @(posedge aclk);
        awvalid <= 0;
        for(int i=0;i<beats;i++) begin
            wdata  <= data[i];
            wstrb  <= 4'hF;
            wlast  <= (i==beats-1);
            wvalid <= 1;
            @(posedge aclk); while(!wready) @(posedge aclk);
            wvalid <= 0;
        end
        wlast <= 0;
        bready <= 1;
        @(posedge aclk); while(!bvalid) @(posedge aclk);
        bready <= 0;
    endtask

    // Burst read. Return results via an open array as well.
    task automatic read_burst(input [ADDR_WIDTH-1:0] addr,
                              output [DATA_WIDTH-1:0] data [],
                              input int beats);
        araddr  <= addr;
        arlen   <= beats-1;
        arsize  <= 3'b010;
        arburst <= 2'b01;
        arvalid <= 1;
        @(posedge aclk); while(!arready) @(posedge aclk);
        arvalid <= 0;
        for(int i=0;i<beats;i++) begin
            rready <= 1;
            @(posedge aclk); while(!rvalid) @(posedge aclk);
            data[i] = rdata;
        end
        rready <= 0;
    endtask

endinterface
