VCS=vcs
VCS_FLAGS=-sverilog -timescale=1ns/1ps -debug_access+all -fsdb
SRC=src/axi4_slave.v src/axi4_master_if.sv tb/tb_axi4.sv

all: simv

simv: $(SRC)
	$(VCS) $(VCS_FLAGS) $(SRC) -o simv

run: simv
	./simv -l simv.log

verdi: simv
	verdi -sv $(SRC) -ssf wave.fsdb -ssw tb/signals.rc &

clean:
	rm -rf simv simv.daidir csrc simv.log wave.fsdb
