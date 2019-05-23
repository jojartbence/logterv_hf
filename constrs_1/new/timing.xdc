create_clock -period 2.062 -name clk -waveform {0.000 1.031} [get_ports -filter { NAME =~  "*clk*" && DIRECTION == "IN" }]
# 485 MHz