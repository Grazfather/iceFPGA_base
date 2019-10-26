module top(
    input wire clk,
    input wire rst,
    output LED1
);

reg [20:0] counter;

assign LED1 = counter[19];

always @(posedge clk)
begin
	counter <= counter + 1;
end

endmodule
