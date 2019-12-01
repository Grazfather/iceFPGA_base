#include <stdlib.h>

#include "verilated.h"
#include "verilated_vcd_c.h"

template <class VA> class TESTBENCH {
public:
	VA *core;
	VerilatedVcdC *trace;
	uint64_t tickcount;

	TESTBENCH() : trace(NULL), tickcount(0) {
		core = new VA;
		Verilated::traceEverOn(true);
		core->i_clk = 0;
		eval();
	}

	virtual ~TESTBENCH() {
		closetrace();
		delete core;
		core = NULL;
	}

	virtual void opentrace(const char *filename) {
		if (!trace) {
			trace = new VerilatedVcdC;
			core->trace(trace, 99);
			trace->open(filename);
		}
	}

	virtual void closetrace() {
		if (trace) {
			trace->close();
			delete trace;
			trace = NULL;
		}
	}

	virtual void eval() {
		core->eval();
	}

	virtual void tick() {
		tickcount++;

		// 83ns = 12MHz
		eval();
		if (trace) trace->dump((vluint64_t)(83*tickcount-2));

		core->i_clk = 1;
		eval();
		if (trace) trace->dump((vluint64_t)(83*tickcount));

		core->i_clk = 0;
		eval();
		if (trace) { // Trailing edge dump
			trace->dump((vluint64_t)(83*tickcount+41));
			trace->flush();
		}
	}
};
