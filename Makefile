VCS = vcs
VCS_OPTS = -sverilog -full64 -debug_access+all
FILES = filelist.f
TOP = tb_axi
SIMV = simv
VERDI = verdi
VERDI_OPTS = -f $(FILES) -ssf waves.fsdb -top $(TOP)

all: $(SIMV)

$(SIMV): $(FILES) Makefile
	$(VCS) $(VCS_OPTS) -f $(FILES) -top $(TOP) -o $(SIMV) -l compile.log

run: $(SIMV)
	./$(SIMV) -l sim.log

clean:
	rm -rf $(SIMV) csrc simv.daidir *.vpd *.log

verdi:
	$(VERDI) $(VERDI_OPTS)
