`ifndef UART_SEQUENCE_SV
`define UART_SEQUENCE_SV

class uart_sequence extends uvm_sequence#(uart_transaction);
    `uvm_object_utils(uart_sequence)

    function new(string name="uart_sequence");
        super.new(name);
    endfunction

    task body();
        uart_transaction tr;
        repeat(10) begin
            tr = uart_transaction::type_id::create("tr");
            assert(tr.randomize());
            start_item(tr);
            finish_item(tr);
        end
    endtask
endclass

`endif // UART_SEQUENCE_SV
