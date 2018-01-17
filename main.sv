/* vim: set ai et ts=4 sw=4: */
`default_nettype none

module prescaler(input logic in_clk, output logic out_clk);
    // 9600 @ 12 Mhz
    parameter counter_max = 1250;
    // = math.ceil(math.log2( counter_max ))
    parameter counter_bits = 11;

    logic [counter_bits-1:0] devider;

    always_ff @(posedge in_clk)
    begin
        if(devider == counter_max)
        begin
            devider <= 0;
            out_clk <= 1;
        end
        else
        begin
            devider <= devider + 1;
            out_clk <= 0;
        end
    end
endmodule // prescaler

module sawtooth_sig(input logic clk, output logic [0:7] sig);
    logic [0:7] counter = 0;

    assign sig = counter;

    always_ff @(posedge clk)
    begin
        if(counter == 8'b11111111)
            counter <= 0;
        else
            counter <= counter + 1;
    end
endmodule // sawtooth_sig

module top(
        input logic raw_clk,
        output logic [0:7] sig);
    logic clk678hz, clk999hz, clk_chfreq;
    logic [0:7] sig678hz;
    logic [0:7] sig999hz;
    logic use678hz = 1;

    assign sig = use678hz ? sig678hz : sig999hz;

    always_ff @(posedge clk_chfreq)
    begin
        use678hz <= !use678hz;
    end

    // 12 Mhz => 256*678 Hz
    prescaler #(.counter_max(69), .counter_bits(7))
        clk678hz_ps(
            .in_clk(raw_clk),
            .out_clk(clk678hz));

    // 12 Mhz => 256*999 Hz
    prescaler #(.counter_max(47), .counter_bits(6))
        clk999hz_ps(
            .in_clk(raw_clk),
            .out_clk(clk999hz));

    // 12 Mhz => 1 Hz
    prescaler #(.counter_max(12000000), .counter_bits(24))
        clk_chfreq_ps(
            .in_clk(raw_clk),
            .out_clk(clk_chfreq));

    sine_sig gen678hz(clk678hz, sig678hz);
    sine_sig gen999hz(clk999hz, sig999hz);
endmodule // top
