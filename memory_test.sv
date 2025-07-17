module memory_testbench;
  localparam MEM_START = 32'h8000_0000;
  localparam MEM_END   = 32'h8001_0000;
  localparam MEM_DEPTH = (MEM_END - MEM_START) >> 2;

  logic [31:0] memory [0:MEM_DEPTH-1];

  task automatic write_reg(input logic [31:0] addr, input logic [31:0] data);
    if (addr < MEM_START || addr >= MEM_END) begin
      $display("WRITE ERROR: address %h out of range", addr);
    end else begin
      memory[(addr - MEM_START) >> 2] = data;
    end
  endtask

  task automatic read_reg(input logic [31:0] addr, output logic [31:0] data);
    if (addr < MEM_START || addr >= MEM_END) begin
      $display("READ ERROR: address %h out of range", addr);
      data = 'x;
    end else begin
      data = memory[(addr - MEM_START) >> 2];
    end
  endtask

  class rand_num;
    rand bit [31:0] value;
    constraint c_divisible { value % 4 == 0; value % 12 != 0; }
  endclass

  task automatic march_test();
    int i;
    logic [31:0] d;
    for (i = 0; i < MEM_DEPTH; i++) begin
      write_reg(MEM_START + (i << 2), 32'h0000_0000);
    end
    for (i = 0; i < MEM_DEPTH; i++) begin
      read_reg(MEM_START + (i << 2), d);
      if (d !== 32'h0000_0000)
        $display("MARCH ERROR step2 addr=%h expected 0 got %h", MEM_START + (i<<2), d);
      write_reg(MEM_START + (i << 2), 32'hffff_ffff);
    end
    for (i = MEM_DEPTH - 1; i >= 0; i--) begin
      read_reg(MEM_START + (i << 2), d);
      if (d !== 32'hffff_ffff)
        $display("MARCH ERROR step3 addr=%h expected 1 got %h", MEM_START + (i<<2), d);
      write_reg(MEM_START + (i << 2), 32'h0000_0000);
    end
    for (i = MEM_DEPTH - 1; i >= 0; i--) begin
      read_reg(MEM_START + (i << 2), d);
      if (d !== 32'h0000_0000)
        $display("MARCH ERROR step4 addr=%h expected 0 got %h", MEM_START + (i<<2), d);
    end
  endtask

  initial begin
    rand_num r = new();
    int i;
    logic [31:0] val;

    for (i = 0; i < 100; i++) begin
      if (!r.randomize()) begin
        $fatal("Randomization failed at iteration %0d", i);
      end
      val = r.value;
      write_reg(MEM_START + (i << 2), val);
    end

    for (i = 0; i < 100; i++) begin
      read_reg(MEM_START + (i << 2), val);
      if (val !== memory[i]) begin
        $display("ERROR: mismatch at index %0d expected %h got %h", i, memory[i], val);
      end
    end

    march_test();

    $display("Tests completed");
    $finish;
  end
endmodule
