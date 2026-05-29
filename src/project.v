/*
 * Copyright (c) 2026 Satya Roop Bankuru
 * SPDX-License-Identifier: Apache-2.0
 * Project: 1-Bit 3x3 Serial CNN Accelerator Node
 */

`default_nettype none

module tt_um_1bit_cnn (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Wire assignments for streaming input data
    wire pixel_in   = ui_in[0];  // Stream pixels in serially on bit 0
    wire data_valid = ui_in[1];  // High when a valid pixel stream is active

    // 3x3 Image Window Sliding Matrix (9 internal registers total)
    reg [2:0] row0, row1, row2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row0 <= 3'b000;
            row1 <= 3'b000;
            row2 <= 3'b000;
        end else if (data_valid) begin
            // Shift pixels through to simulate a moving sliding window matrix
            row0 <= {row0[1:0], pixel_in};
            row1 <= {row1[1:0], row0[2]};
            row2 <= {row2[1:0], row1[2]};
        end
    end

    /* * Hardcoded 1-Bit Convolution Weights (Edge Detection Filter Grid):
     * [ -1,  1, -1 ]  --> Mapped to Binary: 0 = Weight of -1
     * [  1,  1,  1 ]                          1 = Weight of +1
     * [ -1,  1, -1 ]
     */
    
    // Perform 1-bit hardware multiplication using XNOR gates
    wire [8:0] matches;
    assign matches[0] = row0[0] ~^ 1'b0; // Matrix bit 0 vs Weight (-1)
    assign matches[1] = row0[1] ~^ 1'b1; // Matrix bit 1 vs Weight (+1)
    assign matches[2] = row0[2] ~^ 1'b0; // Matrix bit 2 vs Weight (-1)
    
    assign matches[3] = row1[0] ~^ 1'b1; // Matrix bit 3 vs Weight (+1)
    assign matches[4] = row1[1] ~^ 1'b1; // Matrix bit 4 vs Weight (+1)
    assign matches[5] = row1[2] ~^ 1'b1; // Matrix bit 5 vs Weight (+1)
    
    assign matches[6] = row2[0] ~^ 1'b0; // Matrix bit 6 vs Weight (-1)
    assign matches[7] = row2[1] ~^ 1'b1; // Matrix bit 7 vs Weight (+1)
    assign matches[8] = row2[2] ~^ 1'b0; // Matrix bit 8 vs Weight (-1)

    // Combinational Accumulator: Add up the matching elements (Max score = 9)
    reg [3:0] match_sum;
    always @(*) begin
        match_sum = matches[0] + matches[1] + matches[2] +
                    matches[3] + matches[4] + matches[5] +
                    matches[6] + matches[7] + matches[8];
    end

    // Activation Function (ReLU Threshold Stage):
    // Outputs 1 if the pattern similarity matches 5 or more spots.
    reg conv_output;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            conv_output <= 1'b0;
        end else begin
            conv_output <= (match_sum >= 4'd5) ? 1'b1 : 1'b0;
        end
    end

    // External outputs (Streaming result on uo_out[0] to prevent congestion)
    assign uo_out[0]   = conv_output;
    assign uo_out[7:1] = 7'b0000000;

    // Disconnect bidirectionals and tie down unused inputs to clean linter metrics
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;
    
    wire [5:0] unused_inputs = ui_in[7:2];
    wire _unused = &{ena, unused_inputs, uio_in, 1'b0};

endmodule
