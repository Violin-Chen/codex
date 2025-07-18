`ifndef UART_DRIVER_SV
`define UART_DRIVER_SV

class uart_driver extends uvm_driver#(uart_transaction);
    virtual uart16550_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual uart16550_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set for uart_driver")
    endfunction

    task run_phase(uvm_phase phase);
        uart_transaction tr;
        forever begin
            seq_item_port.get_next_item(tr);
            drive_byte(tr);
            seq_item_port.item_done();
        end
    endtask

    task drive_byte(uart_transaction tr);
        // Simple start bit
        vif.drive_txd(1'b0);
        @(posedge vif.clk);
        // Send data bits LSB first
        foreach(tr.data[i]) begin
            vif.drive_txd(tr.data[i]);
            @(posedge vif.clk);
        end
        // Simple stop bit(s)
        vif.drive_txd(1'b1);
        repeat(tr.stop_bits==2 ? 2 : 1) @(posedge vif.clk);
    endtask
endclass

`endif // UART_DRIVER_SV
