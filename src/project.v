`default_nettype none

module tt_um_1bit_cnn (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire pixel_in   = ui_in[0];
    wire data_valid = ui_in[1];

    reg [2:0] row0, row1, row2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row0 <= 3'b000;
            row1 <= 3'b000;
            row2 <= 3'b000;
        end else if (data_valid) begin
            row0 <= {row0[1:0], pixel_in};
            row1 <= {row1[1:0], row0[2]};
            row2 <= {row2[1:0], row1[2]};
        end
    end

    wire [8:0] matches;

    assign matches[0] = ~(row0[0] ^ 1'b0);
    assign matches[1] = ~(row0[1] ^ 1'b1);
    assign matches[2] = ~(row0[2] ^ 1'b0);

    assign matches[3] = ~(row1[0] ^ 1'b1);
    assign matches[4] = ~(row1[1] ^ 1'b1);
    assign matches[5] = ~(row1[2] ^ 1'b1);

    assign matches[6] = ~(row2[0] ^ 1'b0);
    assign matches[7] = ~(row2[1] ^ 1'b1);
    assign matches[8] = ~(row2[2] ^ 1'b0);

    wire [3:0] match_sum;

    assign match_sum = matches[0] + matches[1] + matches[2] +
                       matches[3] + matches[4] + matches[5] +
                       matches[6] + matches[7] + matches[8];

    reg conv_output;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            conv_output <= 1'b0;
        else if (match_sum >= 4'd5)
            conv_output <= 1'b1;
        else
            conv_output <= 1'b0;
    end

    assign uo_out[0] = conv_output;
    assign uo_out[7:1] = 7'b0000000;

    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    wire [5:0] unused_inputs;
    assign unused_inputs = ui_in[7:2];

    wire _unused;
    assign _unused = &{ena, unused_inputs, uio_in, 1'b0};

endmodule

`default_nettype wire
