VCS = vcs
VCS_OPTS = -sverilog -full64
FILES = filelist.f
TOP = tb_axi
SIMV = simv

all: $(SIMV)

$(SIMV): $(FILES) Makefile
	$(VCS) $(VCS_OPTS) -f $(FILES) -top $(TOP) -o $(SIMV)

run: $(SIMV)
		./$(SIMV)

clean:
		rm -rf $(SIMV) csrc simv.daidir *.vpd *.log
