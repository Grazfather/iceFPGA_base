
all: $(PROJ).rpt $(PROJ).bin

%.blif: $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -p 'synth_ice40 -top top -blif $@' $(ADD_SRC)

%.json: $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -p 'synth_ice40 -top top -json $@' $(ADD_SRC)

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) --json $(filter-out $<,$^) --package $(PACKAGE) --pre-pack ./hooks/pre_pack.py --pcf $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@

%_syn.v: %.blif
	yosys -p 'read_blif -wideports $^; write_verilog $@'

%_syntb: sim/%_tb.v %_syn.v
	iverilog -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

%_syntb.vcd: %_syntb
	vvp -N $< +vcd=$@

# Verilator simulator
VINC=/usr/local/share/verilator/include
VFLAGS=-O3 -Wall --trace --exe
VDIRFB=./obj_dir
CC=g++
CFLAGS=-g -Wall -I${VINC} -I${VDIRFB}

# Generate verilator tb class
${VDIRFB}/V${TOPMODULE}.cpp: $(ADD_SRC)
	verilator ${VFLAGS} -cc $^

# Build the sim binary
${TOPMODULE}_tb: sim/${TOPMODULE}.cpp ${VDIRFB}/V${TOPMODULE}.cpp ${COSIMS} sim/testbench.h
	${CC} ${CFLAGS} ${VINC}/verilated.cpp ${VINC}/verilated_vcd_c.cpp $< ${VDIRFB}/V${TOPMODULE}.cpp ${VDIRFB}/V${TOPMODULE}__*.cpp ${COSIMS} -o $@

verify: sim/${TOPMODULE}.sby
	sby -f $^ -t || true

verify-%: sim/%.sby
	sby -f $^ -t || true

prog: $(PROJ).bin
	iceprog $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

clean:
	rm -rf $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).json $(PROJ).log obj_dir/ *_tb $(ADD_CLEAN)

.SECONDARY:
.PHONY: all prog clean
