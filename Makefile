VCS = vcs
VCS_OPTS = -sverilog -full64 -debug_access+all
FILES = filelist.f
TOP = tb_axi
SIMV = simv

all: $(SIMV)

$(SIMV): $(FILES) Makefile
	$(VCS) $(VCS_OPTS) -f $(FILES) -top $(TOP) -o $(SIMV) -l compile.log

run: $(SIMV)
	./$(SIMV) -l sim.log

clean:
		rm -rf $(SIMV) csrc simv.daidir *.vpd *.log
