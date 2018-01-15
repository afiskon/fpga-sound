#!/usr/bin/env python3

import math

samples = 256
scale = 127
volume = 1.0

print("""\
/* vim: set ai et ts=4 sw=4: */
`default_nettype none

module sine_sig(input logic clk, output logic [0:7] sig);
    logic [0:7] counter;

    sawtooth_sig st_sig(clk, counter);

    always_ff @(posedge clk)
    begin
        case (counter)\
""");

for i in range(0,samples):
    x = 2*math.pi*i/samples
    f = (" " * 12) + "8'b{:08b}: sig <= 8'b{:08b};"
    val = int(volume*(math.sin(x)*scale + scale))
    print(f.format(i, val))

print("""\
            default: sig <= 8'b00000000; // should never happen
        endcase
    end
endmodule
""");
