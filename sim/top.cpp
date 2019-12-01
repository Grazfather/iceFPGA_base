#include <stdio.h>

#include "Vtop.h"
#include "testbench.h"

int main (int argc, char** argv) {
	Verilated::commandArgs(argc, argv);

	// Instantiate testbench
	TESTBENCH<Vtop> *tb = new TESTBENCH<Vtop>;

	// Create trace file
	tb->opentrace("top.vcd");

	// Run a few clocks
	for(int count = 0; count < 1000; count++) {
		tb->tick();
	}

	printf("Simulation complete\n");
}
