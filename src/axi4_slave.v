module axi4_slave #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter MEM_DEPTH      = 16384  // 16K bytes
) (
    // Global signals
    input  wire                      aclk,
    input  wire                      aresetn,
    
    // Write Address Channel
    input  wire                      awvalid,
    output reg                       awready,
    input  wire [AXI_ADDR_WIDTH-1:0] awaddr,
    input  wire [7:0]                awlen,
    input  wire [2:0]                awsize,
    input  wire [1:0]                awburst,
    
    // Write Data Channel
    input  wire                      wvalid,
    output reg                       wready,
    input  wire [AXI_DATA_WIDTH-1:0] wdata,
    input  wire [3:0]                wstrb,
    input  wire                      wlast,
    
    // Write Response Channel
    output reg                       bvalid,
    input  wire                      bready,
    output reg [1:0]                 bresp,
    
    // Read Address Channel
    input  wire                      arvalid,
    output reg                       arready,
    input  wire [AXI_ADDR_WIDTH-1:0] araddr,
    input  wire [7:0]                arlen,
    input  wire [2:0]                arsize,
    input  wire [1:0]                arburst,
    
    // Read Data Channel
    output reg                       rvalid,
    input  wire                      rready,
    output reg [AXI_DATA_WIDTH-1:0]  rdata,
    output reg [1:0]                 rresp,
    output reg                       rlast
);

    // Memory array
    reg [7:0] memory [0:MEM_DEPTH-1];
    
    // FSM states
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam RESP = 2'b10;
    
    // FSM state registers
    reg [1:0] write_state;
    reg [1:0] read_state;
    
    // Transaction counters
    reg [7:0] write_count;
    reg [7:0] read_count;
    reg [AXI_ADDR_WIDTH-1:0] write_addr;
    reg [AXI_ADDR_WIDTH-1:0] read_addr;

    // Write channel logic
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            write_state <= IDLE;
            awready     <= 1'b0;
            wready      <= 1'b0;
            bvalid      <= 1'b0;
            bresp       <= 2'b00;
            write_count <= 8'b0;
        end else begin
            case (write_state)
                IDLE: begin
                    awready <= 1'b1;
                    wready  <= 1'b0;
                    if (awvalid) begin
                        awready     <= 1'b0;
                        write_addr  <= awaddr;
                        write_count <= awlen + 1;
                        write_state <= BUSY;
                    end
                end

                BUSY: begin
                    awready <= 1'b0;
                    wready  <= 1'b1;

                    if (wvalid) begin
                        // Write data to memory
                        if (wstrb[0]) memory[write_addr]   <= wdata[7:0];
                        if (wstrb[1]) memory[write_addr+1] <= wdata[15:8];
                        if (wstrb[2]) memory[write_addr+2] <= wdata[23:16];
                        if (wstrb[3]) memory[write_addr+3] <= wdata[31:24];

                        write_addr  <= write_addr + 4;
                        write_count <= write_count - 1;

                        if (write_count == 1) begin
                            wready      <= 1'b0;
                            bvalid      <= 1'b1;
                            write_state <= RESP;
                        end
                    end
                end

                RESP: begin
                    if (bready) begin
                        bvalid      <= 1'b0;
                        write_state <= IDLE;
                    end
                end
            endcase
        end
    end

    // Read channel logic
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            read_state <= IDLE;
            arready    <= 1'b0;
            rvalid     <= 1'b0;
            rlast      <= 1'b0;
            rresp      <= 2'b00;
            read_count <= 8'b0;
        end else begin
            case (read_state)
                IDLE: begin
                    arready <= 1'b1;
                    if (arvalid) begin
                        arready    <= 1'b0;
                        read_addr  <= araddr;
                        read_count <= arlen + 1;
                        read_state <= BUSY;
                    end
                end

                BUSY: begin
                    rvalid <= 1'b1;

                    // Read data from memory
                    rdata <= {memory[read_addr+3], memory[read_addr+2],
                             memory[read_addr+1], memory[read_addr]};

                    if (rready) begin
                        read_addr  <= read_addr + 4;
                        read_count <= read_count - 1;

                        if (read_count == 1) begin
                            rlast      <= 1'b1;
                            read_state <= RESP;
                        end
                    end
                end

                RESP: begin
                    if (rready) begin
                        rvalid     <= 1'b0;
                        rlast      <= 1'b0;
                        read_state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
