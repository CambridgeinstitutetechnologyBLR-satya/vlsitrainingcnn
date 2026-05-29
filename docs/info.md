# How it works

This project implements a 1-bit 3x3 Serial CNN Accelerator using Binary Neural Network principles.

Pixels are streamed serially through ui_in[0]. A 3x3 sliding image window is created internally using shift registers.

Instead of multipliers, convolution is implemented using XNOR gates to compare incoming pixels with fixed convolution weights.

The matching bits are accumulated and passed through a threshold activation stage.

If the similarity score reaches the threshold, the accelerator outputs logic 1 on uo_out[0]. Otherwise, logic 0 is produced.

This architecture minimizes routing congestion and allows CNN functionality inside a Tiny Tapeout 1x1 tile.

# How to test

1. Apply reset by driving rst_n low.
2. Release reset by setting rst_n high.
3. Stream binary pixels serially into ui_in[0].
4. Set ui_in[1] high while streaming valid data.
5. After the 3x3 window fills, observe uo_out[0].
6. Output logic 1 indicates detected convolution pattern.
