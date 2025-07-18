`ifndef UART_TRANSACTION_SV
`define UART_TRANSACTION_SV

class uart_transaction extends uvm_sequence_item;
    rand bit [7:0] data;
    rand bit       parity_en;
    rand bit [1:0] stop_bits; // 0:1 stop, 1:1.5 stop, 2:2 stop

    `uvm_object_utils_begin(uart_transaction)
        `uvm_field_int(data,       UVM_ALL_ON)
        `uvm_field_int(parity_en,  UVM_ALL_ON)
        `uvm_field_int(stop_bits,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="uart_transaction");
        super.new(name);
    endfunction
endclass

`endif // UART_TRANSACTION_SV
