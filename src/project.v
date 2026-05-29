`default_nettype none

module tt_um_1bit_cnn(
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7-segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // 1. Unused bidirectional pins safely set to inputs (0)
    assign uio_oe  = 8'b00000000;
    assign uio_out = 8'b00000000;

    // 2. Declare your CNN registers / state variables
    reg [7:0] accumulator;

    // 3. Connect outputs to your internal registers
    assign uo_out = accumulator;

    // 4. Sequential logic block (Always use synchronous reset for Tiny Tapeout workflows)
    always @(posedge clk) begin
        if (!rst_n) begin
            // Reset state
            accumulator <= 8'h00;
        end else begin
            // Example CNN MAC operation: Add incoming pixel/weight data from ui_in
            if (ui_in > 0) begin
                accumulator <= accumulator + ui_in;
            end
        end
    end

endmodule
