`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uart_pkg.sv"

module uart_testbench;
    logic clk = 0;
    logic rst_n = 0;

    always #5 clk = ~clk; // 100MHz

    uart16550_if uart_if(.clk(clk), .rst_n(rst_n));

    initial begin
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
    end

    initial begin
        run_test("uart_basic_test");
    end
endmodule

class uart_env extends uvm_env;
    uart_sequencer sqr;
    uart_driver    drv;

    `uvm_component_utils(uart_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uart_sequencer::type_id::create("sqr", this);
        drv = uart_driver   ::type_id::create("drv", this);
        uvm_config_db#(virtual uart16550_if)::set(this, "drv", "vif", uart_if);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass

class uart_basic_test extends uvm_test;
    `uvm_component_utils(uart_basic_test)

    uart_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        uart_sequence seq;
        phase.raise_objection(this);
        seq = uart_sequence::type_id::create("seq");
        seq.start(env.sqr);
        phase.drop_objection(this);
    endtask
endclass
