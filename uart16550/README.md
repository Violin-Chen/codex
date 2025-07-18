# UART 16550 UVM Driver Example

This directory contains a minimal example of an UART 16550 driver written in SystemVerilog using the UVM framework. The code provides a basic transaction-level driver along with a simple testbench skeleton.

## Files
- `uart16550_if.sv` – UART virtual interface used by the driver.
- `uart_transaction.sv` – Sequence item representing a UART byte transfer.
- `uart_driver.sv` – UVM driver that drives transactions onto the interface.
- `uart_sequencer.sv` – UVM sequencer associated with the driver.
- `uart_sequence.sv` – Example sequence generating random UART transfers.
- `uart_pkg.sv` – Package bundling all components.
- `uart_test.sv` – Testbench top and basic test class.

## Building
The example can be compiled with **Verilator** for linting or simulation:

```sh
verilator -sv -Wall uart_test.sv --lint-only
```

This command performs syntax checking without running a simulation.
