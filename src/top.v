`default_nettype none

module top(
    input wire i_clk,
    // verilator lint_off UNUSED
    input wire i_rst,
    // lint_on
    input wire ftdi_rx,
    output ftdi_tx,
    output LED1,
    output LED2
);

reg [20:0] counter;

assign LED1 = ftdi_rx;
assign LED2 = counter[19];
assign ftdi_tx = ftdi_rx;

always @(posedge i_clk)
begin
	counter <= counter + 1;
end

`ifdef FORMAL
// Because $past(x) is undefined on the first cycle, latch after a cycle to start using it
reg     f_past_valid;
initial f_past_valid = 0;
always @(posedge i_clk)
	f_past_valid <= 1'b1;

// Properties
initial assume(ftdi_rx);

always @(*)
	assert(ftdi_tx == ftdi_rx);

`endif
endmodule
