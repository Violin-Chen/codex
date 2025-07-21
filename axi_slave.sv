module axi_slave_model #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 256
) (axi_master_if axi);

    logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    // internal state
    logic [ADDR_WIDTH-1:0] wr_addr;
    logic [7:0]            wr_rem;
    logic                  wr_active;

    logic [ADDR_WIDTH-1:0] rd_addr;
    logic [7:0]            rd_rem;
    logic                  rd_active;

    // default assignments
    initial begin
        axi.AWREADY = 1'b1;
        axi.WREADY  = 1'b1;
        axi.BVALID  = 1'b0;
        axi.ARREADY = 1'b1;
        axi.RVALID  = 1'b0;
        axi.RLAST   = 1'b0;
        wr_active   = 1'b0;
        rd_active   = 1'b0;
    end

    // write logic
    always_ff @(posedge axi.ACLK) begin
        if (!axi.ARESETn) begin
            axi.BVALID  <= 1'b0;
            wr_active   <= 1'b0;
        end else begin
            if (axi.AWVALID && axi.AWREADY) begin
                wr_addr   <= axi.AWADDR;
                wr_rem    <= axi.AWLEN;
                wr_active <= 1'b1;
            end
            if (axi.WVALID && axi.WREADY && wr_active) begin
                mem[wr_addr[ADDR_WIDTH-1:2]] <= axi.WDATA;
                wr_addr <= wr_addr + (DATA_WIDTH/8);
                if (wr_rem == 0 || axi.WLAST) begin
                    wr_active <= 1'b0;
                    axi.BVALID <= 1'b1;
                end else begin
                    wr_rem <= wr_rem - 1;
                end
            end
            if (axi.BVALID && axi.BREADY)
                axi.BVALID <= 1'b0;
        end
    end

    // read logic
    always_ff @(posedge axi.ACLK) begin
        if (!axi.ARESETn) begin
            axi.RVALID <= 1'b0;
            axi.RLAST  <= 1'b0;
            rd_active  <= 1'b0;
        end else begin
            if (axi.ARVALID && axi.ARREADY) begin
                rd_addr  <= axi.ARADDR;
                rd_rem   <= axi.ARLEN;
                rd_active <= 1'b1;
            end
            if (rd_active && (!axi.RVALID || axi.RREADY)) begin
                axi.RDATA <= mem[rd_addr[ADDR_WIDTH-1:2]];
                axi.RVALID <= 1'b1;
                axi.RLAST  <= (rd_rem == 0);
                rd_addr <= rd_addr + (DATA_WIDTH/8);
                if (rd_rem == 0) begin
                    rd_active <= 1'b0;
                end else begin
                    rd_rem <= rd_rem - 1;
                end
            end else if (axi.RVALID && axi.RREADY && axi.RLAST) begin
                axi.RVALID <= 1'b0;
                axi.RLAST  <= 1'b0;
            end
        end
    end
endmodule
