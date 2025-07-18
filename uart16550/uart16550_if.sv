interface uart16550_if(
    input  logic clk,
    input  logic rst_n
);
    // UART lines
    logic rxd; // receive data
    logic txd; // transmit data
    logic cts; // clear to send
    logic rts; // request to send

    // Simple task to drive txd
    task drive_txd(input logic val);
        txd <= val;
    endtask

    // Simple function to sample rxd
    function logic sample_rxd();
        return rxd;
    endfunction
endinterface
