// Simple FPGA Done LED indicator
// Lights up B4 LED when programmed

module fpga_done_led (
    output wire LED
);
    // The LED is OFF as soon as the FPGA is programmed
    assign LED = 1'b0;
endmodule
