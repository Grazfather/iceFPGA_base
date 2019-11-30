
all: $(PROJ).rpt $(PROJ).bin

%.blif: $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -p 'synth_ice40 -top top -blif $@' $(ADD_SRC)

%.json: $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log -p 'synth_ice40 -top top -json $@' $(ADD_SRC)

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) --json $(filter-out $<,$^) --package $(PACKAGE) --pcf $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

%_tb: sim/%_tb.v $(ADD_SRC)
	iverilog -o $@ $^

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@

%_syn.v: %.blif
	yosys -p 'read_blif -wideports $^; write_verilog $@'

%_syntb: sim/%_tb.v %_syn.v
	iverilog -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

%_syntb.vcd: %_syntb
	vvp -N $< +vcd=$@

VINC=/usr/local/share/verilator/include
obj_dir/V%.cpp: src/%.v
	verilator -Wall --trace -cc $^

V%: sim/%.cpp obj_dir/V%.cpp
	g++ -I${VINC} -I obj_dir/ ${VINC}/verilated.cpp ${VINC}/verilated_vcd_c.cpp $< obj_dir/$@*.cpp -o $@

prog: $(PROJ).bin
	iceprog $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

clean:
	rm -rf $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).json $(PROJ).log obj_dir/ *_tb $(ADD_CLEAN)

.SECONDARY:
.PHONY: all prog clean
